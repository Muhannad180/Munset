import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:test1/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

// --- AppStyle Definition: polished for consistency ---
class AppStyle {
  // Soft, Harmonious Pastel Palette
  static const Color primary = Color(0xFF4DB6AC); // Soft Teal
  static const Color primaryDark = Color(0xFF00897B);
  static const Color accent = Color(0xFFFFB74D); // Soft Orange
  
  // Backgrounds
  static const Color bgTop = Color(0xFFF5F7FA); // Soft White/Grey
  static const Color bgBottom = Color(0xFFE3F2FD); // Very Pale Blue

  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 2,
    )
  ];

  static BorderRadius get cardRadius => BorderRadius.circular(20);

  // Typography Hierarchy
  static TextStyle get heading => GoogleFonts.tajawal(
    fontSize: 26, 
    fontWeight: FontWeight.w800,
    color: const Color(0xFF2D3436),
    height: 1.3,
  );

  static TextStyle get cardTitle => GoogleFonts.tajawal(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF2D3436),
  );

  static TextStyle get body => GoogleFonts.tajawal(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF535C68),
    height: 1.6,
  );
  
  static TextStyle get bodySmall => GoogleFonts.tajawal(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF95A5A6),
  );

  static TextStyle get buttonText => GoogleFonts.tajawal(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

class HomePage extends StatefulWidget {
  final VoidCallback? onReload;
  final ValueNotifier<bool>? refreshNotifier;
  final Function(int)? onNavigateTo; // Added for page switching

  const HomePage({super.key, this.onReload, this.refreshNotifier, this.onNavigateTo});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  String _locale = 'ar';
  String firstName = '';

  Map<String, dynamic>? latestJournal;
  double taskProgress = 0.0;
  List<Map<String, dynamic>> userTasks = [];
  bool isLoadingData = true;

  Map<String, String> habitAdvices = {};
  Map<String, bool> loadingHabitAdvice = {};

  final List<Map<String, String>> moods = [
    {'emoji': '😭', 'name': 'حزين جداً'}, {'emoji': '😢', 'name': 'حزين'}, {'emoji': '😔', 'name': 'مكتئب'},
    {'emoji': '😞', 'name': 'خيبة أمل'}, {'emoji': '😐', 'name': 'محايد'}, {'emoji': '🙂', 'name': 'هادئ'},
    {'emoji': '😄', 'name': 'سعيد'}, {'emoji': '😍', 'name': 'محبوب'}, {'emoji': '🤩', 'name': 'متحمس'},
    {'emoji': '😎', 'name': 'واثق'}, {'emoji': '😇', 'name': 'مسترخٍ'}, {'emoji': '😤', 'name': 'غاضب'},
    {'emoji': '🥳', 'name': 'محتفل'}, {'emoji': '😴', 'name': 'متعب'},
    {'emoji': '🤔', 'name': 'أخرى'},
  ];

  final List<Map<String, String>> cbtAdvices = [
    {'title': 'تواصل مع الطبيعة', 'body': 'اقضِ وقتاً ممتعاً في الهواء الطلق، محاطاً بالخضرة والهواء النقي، لتحسين مزاجك.'},
    {'title': 'تنفس بعمق', 'body': 'خذ شهيقاً بطيئاً، احبس نفسك، ثم ازفر ببطء لتهدئة جهازك العصبي.'},
  ];
  late Map<String, String> currentAdvice;
  bool isGeneratingAdvice = false;
  String? lastAdviceJournalId; // Added to track advice persistence

  @override
  void initState() {
    super.initState();
    _setLocale();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadAllHomeData());
    widget.refreshNotifier?.addListener(loadAllHomeData);
    currentAdvice = (cbtAdvices..shuffle()).first;
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(loadAllHomeData);
    super.dispose();
  }

  void _setLocale() async {
    try {
      _locale = Platform.localeName.split('_')[0]; 
      await initializeDateFormatting(_locale, null);
    } catch (e) {
      _locale = 'ar';
      await initializeDateFormatting(_locale, null);
    }
    if (mounted) setState(() {});
  }

  void _onDaySelected(DateTime day) => setState(() => _selectedDate = day);

  Future<void> loadAllHomeData() async {
    if (!mounted) return;
    if (firstName.isEmpty && latestJournal == null) setState(() => isLoadingData = true);
    
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() { isLoadingData = false; firstName = 'ضيف'; });
      return;
    }
    await Future.wait([_loadUserData(), _loadLatestJournal(), _loadTasksProgress()]);
    
    if (latestJournal != null) {
       final currentJournalId = latestJournal!['id']?.toString() ?? latestJournal!['journal_id']?.toString() ?? '';
       if (currentJournalId.isNotEmpty && currentJournalId != lastAdviceJournalId) {
          lastAdviceJournalId = currentJournalId;
          _getPersonalizedAdvice(latestJournal!['mode_description'] ?? '');
       }
    }
    
    if (mounted) setState(() => isLoadingData = false);
  }

  Future<void> _loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase.from('users').select().eq('id', user.id).maybeSingle();
        if (response != null && mounted) setState(() => firstName = response['first_name'] ?? '');
      }
    } catch (e) { debugPrint("User Err: $e"); }
  }

  Future<void> _loadLatestJournal() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase.from('journals').select().eq('id', user.id).order('mode_date', ascending: false).limit(1).maybeSingle();
        if (mounted) setState(() => latestJournal = response);
      }
    } catch (e) { debugPrint("Journal Err: $e"); }
  }

  // ... inside HomePageState ...

  String progressMessage = "جاري تحليل أدائك...";
  bool loadingProgressMessage = false;

  // ...

  Future<void> _loadTasksProgress() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final habitsRes = await supabase.from('habits').select().eq('user_id', userId);
      final tasksRes = await supabase.from('tasks').select().eq('user_id', userId); 
      
      final List<Map<String, dynamic>> allItems = [...List<Map<String, dynamic>>.from(habitsRes), ...List<Map<String, dynamic>>.from(tasksRes)];

      if (mounted) {
        if (allItems.isEmpty) {
          setState(() { 
            taskProgress = 0.0; 
            userTasks = []; 
            progressMessage = "لا توجد مهام مسجلة اليوم. ابدأ بإضافة مهامك!";
          });
        } else {
          final completed = allItems.where((t) => t['is_completed'] == true).length;
          final double progress = allItems.isNotEmpty ? (completed / allItems.length) : 0.0;
          
          setState(() {
            taskProgress = progress;
            userTasks = allItems;
          });
          
          _generateProgressMessage(progress);
        }
      }
    } catch (e) { debugPrint("Tasks Err: $e"); }
  }

  Future<void> _generateProgressMessage(double progress) async {
    // Avoid re-generating if barely changed? For now just generate.
    // Logic: 0% -> Encouragement, 50% -> Keep going, 100% -> Congrats
    // We utilize the AI to give a unique flavored message.
    
    if (loadingProgressMessage) return;
    setState(() => loadingProgressMessage = true);

    String prompt = "النسبة المئوية لإنجازي للمهام هي ${(progress * 100).toInt()}% . أعطني جملة واحدة قصيرة جداً وملهمة (باللهجة السعودية البيضاء) بناءً على هذه النسبة.";
    
    try {
      final msg = await _callAdviceApi(prompt);
      if (msg != null && mounted) {
        setState(() => progressMessage = msg);
      }
    } finally {
      if (mounted) setState(() => loadingProgressMessage = false);
    }
  }



  Future<void> _getPersonalizedAdvice(String text) async {
    if (text.trim().isEmpty) return;
    if (mounted) setState(() => isGeneratingAdvice = true);
    
    String? adviceRaw;
    try {
      // 1. Fetch recent history to detect patterns
      final user = supabase.auth.currentUser;
      String historyContext = "";
      
      if (user != null) {
        final lastJournals = await supabase.from('journals')
            .select('mode_name')
            .eq('id', user.id)
            .order('mode_date', ascending: false)
            .limit(5);

        if (lastJournals.isNotEmpty) {
           final modes = lastJournals.map((j) => j['mode_name']).join(', ');
           historyContext = "سجل المشاعر الأخير للمستخدم: [$modes]. ";
        }
      }

      // 2. Constructed Prompt
      String prompt = """
      أنت مساعد نفسي داعم وصديق.
      المستخدم يشعر الآن بـ: '$text'.
      $historyContext
      
      المطلوب:
      1. افهم مشاعر المستخدم بدقة. إذا كان يكرر نفس الشعور (مثل الحزن المتكرر)، أشر إلى ذلك بلطف شديد (مثلاً: "لاحظت أنك تمر بفترة صعبة مؤخراً...").
      2. قدم نصيحة واحدة قصيرة جداً (جملتين إلى ثلاث)، دعمة، وعملية.
      3. كن إيجابياً ومواسياً، وتجنب النصائح الطبية أو السريرية.
      4. التنسيق: عنوان قصير # نصيحة.
      مثال: استراحة محارب # خذ وقتاً لنفسك، أنت تبذل جهداً رائعاً.
      """;
      
      adviceRaw = await _callAdviceApi(prompt);
    } catch (e) {
      debugPrint("Advice Err: $e");
    }

    if (adviceRaw == null && mounted) {
       final fallback = _getLocalAdvice(text);
       setState(() => currentAdvice = fallback);
       setState(() => isGeneratingAdvice = false);
       return;
    }
      
    if (adviceRaw != null && mounted) {
      final parts = adviceRaw.split('#');
      String title = "رسالة لك";
      String body = adviceRaw;
      
      if (parts.length >= 2) {
        title = parts[0].trim();
        body = parts[1].trim();
      } else {
          body = adviceRaw;
      }

      setState(() => currentAdvice = {'title': title, 'body': body});
    }
    
    if (mounted) setState(() => isGeneratingAdvice = false);
  }

  Map<String, String> _getLocalAdvice(String text) {
     final random = DateTime.now().millisecondsSinceEpoch % 3;
     
     if (text.contains('غاضب')) {
        if (random == 0) return {'title': 'تمرين التنفس', 'body': 'جرب تقنية التنفس 4-7-8: استنشق لـ4 ثوانٍ، احبس لـ7، وازفر لـ8. كررها 3 مرات.'};
        if (random == 1) return {'title': 'الحركة الدوائية', 'body': 'قم بالمشي السريع لمدة 5 دقائق الآن لتفريغ طاقة الغضب الجسدية.'};
        return {'title': 'الكتابة الحرة', 'body': 'اكتب كل ما يغضبك في ورقة الآن، ثم مزقها فوراً. هذا يساعد في التنفيس.'};
     }
     if (text.contains('حزين')) {
        if (random == 0) return {'title': 'تواصل مع صديق', 'body': 'اتصل بشخص تثق به الآن وتحدث معه، حتى لو لدقائق قليلة.'};
        if (random == 1) return {'title': 'الامتنان الصغير', 'body': 'اكتب 3 أشياء بسيطة أنت ممتن لها اليوم (قهوة، شمس، ابتسامة).'};
        return {'title': 'عناق الطبيعة', 'body': 'اخرج للشمس أو الهواء الطلق لمدة 10 دقائق، الضوء الطبيعي يحسن المزاج.'};
     }
     if (text.contains('قلق') || text.contains('خائف')) {
        if (random == 0) return {'title': 'قاعدة 5-4-3-2-1', 'body': 'عدد 5 أشياء تراها، 4 تلمسها، 3 تسمعها، 2 تشمها، و1 تتذوقها. هذا يعيدك للحاضر.'};
        if (random == 1) return {'title': 'كتابة المخاوف', 'body': 'حدد وقت "للقلق" لمدة 10 دقائق فقط. اكتب مخاوفك ثم أغلق الدفتر.'};
        return {'title': 'التركيز الحسي', 'body': 'اغسل وجهك بماء بارد جداً؛ الصدمة الحسية توقف دوامة التفكير.'};
     }
     if (text.contains('متحمس') || text.contains('سعيد')) {
        return {'title': 'استثمر طاقتك', 'body': 'استغل هذه الطاقة الإيجابية في إنجاز أصعب مهمة في قائمتك الآن!'};
     }
     if (text.contains('متعب')) {
        return {'title': 'قيلولة الطاقة', 'body': 'خذ قيلولة لمدة 20 دقيقة (لا تزد عنها) لتجديد نشاطك الذهني دون الشعور بالخمول.'};
     }
     
     // General / Default
     if (random == 0) return {'title': 'رتب محيطك', 'body': 'رتب مكان جلوسك أو سطح مكتبك لمدة 5 دقائق؛ التنظيم الخارجي يساعد في الهدوء الداخلي.'};
     if (random == 1) return {'title': 'شرب الماء', 'body': 'اشرب كوباً كبيراً من الماء ببطء. الجفاف يؤثر على التركيز والمزاج.'};
     return {'title': 'خطوة صغيرة', 'body': 'اختر مهمة صغيرة جداً (تستغرق دقيقتين) وأنجزها الآن.'};
  }

  Future<void> _getHabitAdvice(String itemId, String itemTitle) async {
    if (loadingHabitAdvice[itemId] == true) return;
    setState(() => loadingHabitAdvice[itemId] = true);
    try {
      String prompt = "أريد نصيحة قصيرة ومشجعة للالتزام بعادة: $itemTitle";
      final advice = await _callAdviceApi(prompt);
      if (advice != null && mounted) {
        setState(() => habitAdvices[itemId] = advice);
      }
    } finally {
      if (mounted) setState(() => loadingHabitAdvice[itemId] = false);
    }
  }

  Future<String?> _callAdviceApi(String text) async {
    try {
      const String apiUrl = 'http://127.0.0.1:10000/generate-advice';
      final response = await http.post(
        Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'emotion_text': text}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['advice'];
      }
    } catch (e) { debugPrint("API Err: $e"); }
    return null;
  }

  Future<void> _saveNewJournal(String mood, String moodName, String desc, String feelingForAdvice) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    String fullDesc = desc;
    if (feelingForAdvice.isNotEmpty) fullDesc += "\n\n[مشاعر إضافية]: $feelingForAdvice";
    setState(() {
      latestJournal = {
        'mode': mood, 'mode_name': moodName, 'mode_description': fullDesc, 'mode_date': DateTime.now().toIso8601String(), 'journal_id': -1, 
      };
    });
    try {
      final lastRec = await supabase.from('journals').select('journal_id').eq('id', user.id).order('journal_id', ascending: false).limit(1).maybeSingle();
      int newId = (lastRec != null) ? (lastRec['journal_id'] + 1) : 1;
      await supabase.from('journals').insert({
        'id': user.id, 'journal_id': newId, 'mode': mood, 'mode_name': moodName, 'mode_description': fullDesc, 'mode_date': DateTime.now().toIso8601String(),
      });
      await _loadLatestJournal(); 
      
      // Auto-trigger advice refresh
      final textToUse = feelingForAdvice.isNotEmpty ? feelingForAdvice : "$moodName. $desc";
      _getPersonalizedAdvice(textToUse);
      
    } catch (e) { debugPrint("Save Err: $e"); }
  }

  Future<void> _deleteJournal() async {
    if (latestJournal == null) return;
    bool confirm = await showDialog(context: context, builder: (ctx) => Directionality(textDirection: ui.TextDirection.rtl, child: AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("حذف"), content: const Text("تأكيد الحذف؟"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("حذف", style: TextStyle(color: Colors.red)))]))) ?? false;
    if (!confirm) return;
    try {
      await supabase.from('journals').delete().eq('id', supabase.auth.currentUser!.id).eq('journal_id', latestJournal!['journal_id']);
      setState(() { latestJournal = null; currentAdvice = cbtAdvices.first; });
      _loadLatestJournal();
    } catch (e) { debugPrint("Del Err: $e"); }
  }

  void _openAddJournalSheet() { _showJournalSheet(); }
  void _editJournal() { _showJournalSheet(isEdit: true); }

  void _showJournalSheet({bool isEdit = false}) {
    int selIndex = 4;
    final detCtrl = TextEditingController();
    final advCtrl = TextEditingController();

    if (isEdit && latestJournal != null) {
      selIndex = moods.indexWhere((m) => m['name'] == latestJournal!['mode_name']);
      if (selIndex == -1) selIndex = 4;
      detCtrl.text = latestJournal!['mode_description'] ?? '';
    }

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: StatefulBuilder(builder: (c, setSt) => SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(isEdit ? "تعديل اليومية" : "كيف تشعر اليوم؟", style: AppStyle.heading.copyWith(fontSize: 22, color: AppStyle.primary), textAlign: TextAlign.center),
            const SizedBox(height: 25),
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {ui.PointerDeviceKind.touch, ui.PointerDeviceKind.mouse}),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(moods.length, (i) {
                    bool isSelected = selIndex == i;
                    return GestureDetector(
                      onTap: () => setSt(() => selIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppStyle.primary.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? Border.all(color: AppStyle.primary, width: 2) : Border.all(color: Colors.transparent, width: 2),
                        ),
                        child: Column(children: [
                          Text(moods[i]['emoji']!, style: TextStyle(fontSize: isSelected ? 38 : 30)),
                          const SizedBox(height: 8),
                          Text(moods[i]['name']!, style: AppStyle.bodySmall.copyWith(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppStyle.primary : Colors.grey[600])),
                        ]),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: detCtrl, textAlign: TextAlign.right, maxLines: 3, decoration: InputDecoration(hintText: "ملاحظات...", filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
            if (!isEdit) ...[
              const SizedBox(height: 15),
              TextField(controller: advCtrl, textAlign: TextAlign.right, maxLines: 2, decoration: InputDecoration(hintText: "صف شعورك للنصيحة...", filled: true, fillColor: Colors.blue[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
            ],
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(gradient: AppStyle.buttonGradient, borderRadius: BorderRadius.circular(30)),
              child: ElevatedButton(
                onPressed: () async {
                  if (isEdit) {
                    await supabase.from('journals').update({'mode': moods[selIndex]['emoji'], 'mode_name': moods[selIndex]['name'], 'mode_description': detCtrl.text}).eq('id', supabase.auth.currentUser!.id).eq('journal_id', latestJournal!['journal_id']);
                    await _loadLatestJournal();
                  } else {
                    _saveNewJournal(moods[selIndex]['emoji']!, moods[selIndex]['name']!, detCtrl.text, advCtrl.text);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: Text(isEdit ? "تحديث" : "حفظ", style: AppStyle.buttonText),
              ),
            )
          ]),
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentMonth = DateFormat.MMMM(_locale).format(_selectedDate);
    var daysInWeek = _getDaysInWeek(_selectedDate);
    final safeProgress = (taskProgress.isNaN || taskProgress.isInfinite) ? 0.0 : taskProgress;
    final progressPercent = (safeProgress * 100).toInt();
    final hasJournal = latestJournal != null;
    final moodEmoji = latestJournal?['mode'] ?? '😐';
    final moodDesc = latestJournal?['mode_description'] ?? 'لم تسجل شعور اليوم.';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop,
        body: Container(
          decoration: const BoxDecoration(gradient: AppStyle.mainGradient),
          child: SafeArea(
            child: isLoadingData 
            ? const Center(child: CircularProgressIndicator(color: AppStyle.primary))
            : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Header
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 10),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         const Icon(Icons.notifications_none_rounded, size: 28, color: Colors.black87),
                         const Spacer(),
                         Text('مساء الخير، $firstName', style: AppStyle.heading),
                       ],
                     ),
                   ),
                   const SizedBox(height: 24),

                   // Calendar Card
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4))]),
                     child: Column(
                       children: [
                         Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                           IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1))),
                           Text(currentMonth, style: AppStyle.cardTitle),
                           IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1))),
                         ]),
                         const SizedBox(height: 15),
                         Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: daysInWeek.map((d) => _dayItem(d)).toList())
                       ],
                     ),
                   ),
                   const SizedBox(height: 24),

                   // --- Journal Card ---
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         colors: [
                           if (hasJournal) ...[
                              if ((latestJournal!['mode_name'] ?? '').contains('غاضب')) const Color(0xFFEF9A9A) // Red 200
                              else if ((latestJournal!['mode_name'] ?? '').contains('حزين')) const Color(0xFF90CAF9) // Blue 200
                              else if ((latestJournal!['mode_name'] ?? '').contains('قلق')) const Color(0xFFCE93D8) // Purple 200
                              else if ((latestJournal!['mode_name'] ?? '').contains('متحمس') || (latestJournal!['mode_name'] ?? '').contains('سعيد')) const Color(0xFFFFCC80) // Orange 200
                              else const Color(0xFF80CBC4) // Teal 200
                           ] else ...[const Color(0xFFAED581)], // Light Green 300
                           Colors.white
                         ], 
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight
                       ),
                       borderRadius: AppStyle.cardRadius,
                       boxShadow: AppStyle.cardShadow,
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                               decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.7),
                                 borderRadius: BorderRadius.circular(20),
                               ),
                               child: Row(
                                 children: [
                                   Text(hasJournal ? moodEmoji : '📝', style: const TextStyle(fontSize: 18)),
                                   const SizedBox(width: 8),
                                   Text(
                                     hasJournal ? (latestJournal!['mode_name'] ?? '') : 'جديد',
                                     style: AppStyle.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                                   ),
                                 ],
                               ),
                             ),
                             if (hasJournal)
                               Text(DateFormat('HH:mm').format(DateTime.parse(latestJournal!['mode_date'])), style: AppStyle.bodySmall),
                           ],
                         ),
                         const SizedBox(height: 20),
                         InkWell(
                            onTap: hasJournal ? null : _openAddJournalSheet,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasJournal ? "شعرت بـ: ${latestJournal!['mode_name']}" : "كيف كان يومك؟",
                                  style: AppStyle.heading.copyWith(fontSize: 24),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasJournal ? moodDesc : "سجل مشاعرك الآن...",
                                  style: AppStyle.body.copyWith(color: Colors.black54),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                         ),
                         if (hasJournal) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                 InkWell(onTap: _editJournal, child: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54)),
                                 const SizedBox(width: 16),
                                 InkWell(onTap: _deleteJournal, child: Icon(Icons.delete_outline, size: 20, color: Colors.red[400])),
                              ],
                            )
                         ]
                       ],
                     ),
                   ),

                   const SizedBox(height: 20),

                   // --- Advice Card ---
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       gradient: const LinearGradient(
                         colors: [Color(0xFFFFF59D), Colors.white], // Yellow 200
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight
                       ),
                       borderRadius: AppStyle.cardRadius,
                       boxShadow: AppStyle.cardShadow,
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.lightbulb_outline, size: 20, color: Colors.orange),
                              ),
                              const SizedBox(width: 12),
                              Text("نصيحة اليوم", style: AppStyle.cardTitle),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 20, color: Colors.black45),
                                onPressed: () {
                                   if (latestJournal != null) {
                                       _getPersonalizedAdvice(latestJournal!['mode_name'] ?? '');
                                   } else {
                                       _getPersonalizedAdvice('عام');
                                   }
                                },
                              )
                          ]),
                          const SizedBox(height: 16),
                          Text(
                            currentAdvice['body']!,
                            style: AppStyle.body.copyWith(height: 1.6),
                          )
                       ],
                     ),
                   ),

                   const SizedBox(height: 20),

                   // --- Tasks Progress Card (Lighter) ---
                   Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)], // Soft Indigo
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight
                        ),
                        borderRadius: AppStyle.cardRadius,
                        boxShadow: AppStyle.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(progressMessage, style: AppStyle.cardTitle.copyWith(fontSize: 16, color: const Color(0xFF1A237E))),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => widget.onNavigateTo?.call(3),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1A237E),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                                  ),
                                  icon: const Icon(Icons.check_circle_outline, size: 20),
                                  label: const Text("مهامي"),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Stack(alignment: Alignment.center, children: [
                             SizedBox(width: 80, height: 80, child: CircularProgressIndicator(value: safeProgress, color: const Color(0xFF1A237E), backgroundColor: Colors.white54, strokeWidth: 8, strokeCap: StrokeCap.round)),
                             Text("$progressPercent%", style: AppStyle.heading.copyWith(fontSize: 18, color: const Color(0xFF1A237E)))
                          ])
                        ],
                      ),
                   ),

                    const SizedBox(height: 24),

                    // --- Habits List ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppStyle.cardRadius,
                        boxShadow: AppStyle.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                           Row(
                             children: [
                               const Icon(Icons.track_changes, color: AppStyle.primary),
                               const SizedBox(width: 10),
                               Text("تتبع العادات", style: AppStyle.cardTitle),
                             ],
                           ),
                           const SizedBox(height: 16),
                           if (userTasks.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text("أضف عادة جديدة تساعدك على تحسين يومك 🌟", style: AppStyle.bodySmall, textAlign: TextAlign.center),
                                )
                              )
                           else
                              ...userTasks.map((task) => _buildHabitItem(task)).toList(),
                              
                           const SizedBox(height: 10),
                           TextButton(
                             onPressed: () => widget.onNavigateTo?.call(3),
                             child: const Text("إدارة العادات +", style: TextStyle(fontWeight: FontWeight.bold)),
                           )
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitItem(Map<String, dynamic> task) {
    String id = task['id'] ?? (task['task_id'] ?? '').toString();
    String title = task['title'] ?? task['task'] ?? 'بدون عنوان';
    bool isCompleted = task['is_completed'] ?? task['task_completion'] ?? false;
    double progress = isCompleted ? 1.0 : 0.4; 
    String? localAdvice = habitAdvices[id];
    bool isLoadingAdv = loadingHabitAdvice[id] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.bgTop, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.03))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined, color: isCompleted ? Colors.green : Colors.grey, size: 22),
               const SizedBox(width: 10),
               Expanded(child: Text(title, style: AppStyle.body.copyWith(decoration: isCompleted ? TextDecoration.lineThrough : null, color: isCompleted ? Colors.grey : Colors.black87))),
               IconButton(
                 icon: isLoadingAdv ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.lightbulb_outline, color: localAdvice != null ? Colors.orange : Colors.grey[400], size: 20),
                 onPressed: () => _getHabitAdvice(id, title),
                 constraints: const BoxConstraints(),
                 padding: EdgeInsets.zero,
               ),
             ],
           ),
           if (localAdvice != null) ...[
             const SizedBox(height: 10),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
               child: Text(localAdvice, style: AppStyle.bodySmall.copyWith(color: Colors.brown)),
             )
           ]
        ],
      ),
    );
  }

  Widget _dayItem(DateTime date) {
    bool isSelected = date.day == _selectedDate.day;
    return GestureDetector(
      onTap: () => _onDaySelected(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
             Text(DateFormat.E(_locale).format(date), style: AppStyle.bodySmall.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
             const SizedBox(height: 8),
             Container(
               width: 36, height: 36,
               decoration: BoxDecoration(
                 color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent, // Cyan for selection
                 shape: BoxShape.circle,
                 boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF00BCD4).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null,
               ),
               child: Center(child: Text(DateFormat.d(_locale).format(date), style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
             )
          ],
        ),
      ),
    );
  }

  List<DateTime> _getDaysInWeek(DateTime date) {
    var start = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }
}