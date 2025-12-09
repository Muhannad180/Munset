import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:test1/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'package:test1/core/theme/app_style.dart';
import 'package:test1/features/home/presentation/widgets/home_header.dart';
import 'package:test1/features/home/presentation/widgets/calendar_card.dart';
import 'package:test1/features/home/presentation/widgets/journal_card.dart';
import 'package:test1/features/home/presentation/widgets/advice_card.dart';
import 'package:test1/features/home/presentation/widgets/progress_card.dart';
import 'package:test1/features/home/presentation/widgets/habit_list.dart';
import 'package:test1/features/home/presentation/widgets/journal_sheet_content.dart';
import 'package:test1/features/tasks/presentation/screens/add_habit_screen.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onReload;
  final ValueNotifier<bool>? refreshNotifier;
  final Function(int)? onNavigateTo; // Added for page switching
  final VoidCallback? onHabitUpdated; // Callback when habits are changed

  const HomePage({super.key, this.onReload, this.refreshNotifier, this.onNavigateTo, this.onHabitUpdated});

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

      // 1. Fetch Session Tasks (for Progress Card)
      final tasksRes = await supabase.from('tasks').select().eq('user_id', userId); 
      final tasks = List<Map<String, dynamic>>.from(tasksRes).map((t) {
          final id = (t['id'] ?? t['task_id']).toString();
          return {
             ...t,
             'id': 'task_$id',
             'original_id': id,
             'type': 'task',
             'title': t['title'] ?? t['task_name'] ?? 'Task',
             'is_completed': t['is_completed'] ?? t['task_completion'] ?? false,
          };
      }).toList();

      // Calculate Progress ONLY from tasks
      if (mounted) {
         if (tasks.isEmpty) {
            taskProgress = 0.0;
            progressMessage = "لا توجد مهام جلسات حالياً.";
         } else {
            final completed = tasks.where((t) => t['is_completed'] == true).length;
            taskProgress = tasks.isNotEmpty ? (completed / tasks.length) : 0.0;
            _generateProgressMessage(taskProgress);
         }
      }

      // 2. Fetch Habits (For Daily Tracker)
      final habitsRes = await supabase.from('habits').select().eq('user_id', userId);
      final now = DateTime.now();
      
      final habits = List<Map<String, dynamic>>.from(habitsRes).map((h) {
          final id = (h['id'] ?? h['habit_id']).toString();
          
          // Safety: Default goal to 7 (daily) if 0 or null
          int goal = h['Goal'] ?? 0;
          if (goal <= 0) goal = 7;
          
          // History Logic for "Last 7 Days"
          // We expect a 'history' column (JSONB array of ISO strings)
          // If missing, we fallback to completion_count
          List<DateTime> historyDates = [];
          if (h['history'] != null && h['history'] is List) {
             historyDates = (h['history'] as List).map((e) => DateTime.tryParse(e.toString())).whereType<DateTime>().toList();
          }

          // Calculate "Last 7 Days" count
          // Calculate "Last 7 Days" count
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          final int last7DaysCount = historyDates.where((d) => d.isAfter(sevenDaysAgo)).length;
          
          final int currentCount = (historyDates.isNotEmpty) 
              ? last7DaysCount 
              : (h['completion_count'] ?? 0); // Fallback

          // Fix: Define isDoneToday
          bool isDoneToday = false;
          final today = DateTime(now.year, now.month, now.day);
          if (historyDates.isNotEmpty) {
             isDoneToday = historyDates.any((d) {
                final local = d.toLocal();
                return local.year == today.year && local.month == today.month && local.day == today.day;
             });
          } else {
             if (h['last_done_at'] != null) {
                 final last = DateTime.tryParse(h['last_done_at'].toString())?.toLocal();
                 isDoneToday = (last != null && last.year == today.year && last.month == today.month && last.day == today.day);
             }
          }

          return {
             ...h,
             'id': 'habit_$id',
             'original_id': id,
             'type': 'habit',
             'title': h['title'] ?? h['habit_name'] ?? 'Habit',
             'is_completed': isDoneToday, // Show as done if completed TODAY
             'weekly_goal': goal, 
             'weekly_current': currentCount,
             'history': historyDates.map((e) => e.toIso8601String()).toList(),
          };
      }).toList();

      if (mounted) {
        setState(() {
          userTasks = habits; // HabitList now only receives habits!
          // taskProgress calculated above is preserved
        });
      }

    } catch (e) { debugPrint("Tasks Err: $e"); }
  }

  Future<void> _handleTaskToggle(String compoundId, bool currentStatus) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final parts = compoundId.split('_');
    if (parts.length < 2) return;
    final type = parts[0];
    final originalId = parts.sublist(1).join('_');

    if (type == 'habit') {
        // Find local habit to update UI
        final index = userTasks.indexWhere((t) => t['id'] == compoundId);
        if (index == -1) return;
        
        final oldHabit = userTasks[index];
        final newStatus = !currentStatus;
        int newCount = oldHabit['weekly_current'] ?? 0;
        
        // Manage History
        List<String> history = List<String>.from(oldHabit['history'] ?? []);
        final now = DateTime.now();
        
        if (newStatus) {
            newCount++; // Increment for optimisic UI (fallback)
            history.add(now.toUtc().toIso8601String());
        } else {
            if (newCount > 0) newCount--;
            // Remove the entry for today if exists (Undo)
            final today = DateTime(now.year, now.month, now.day);
            history.removeWhere((ts) {
               final dt = DateTime.tryParse(ts)?.toLocal();
               if (dt == null) return false;
               return dt.year == today.year && dt.month == today.month && dt.day == today.day;
            });
        }

        // Calculate new "Last 7 Days" count for UI
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        final realWeeklyCount = history.where((ts) {
            final dt = DateTime.tryParse(ts);
            return dt != null && dt.isAfter(sevenDaysAgo);
        }).length;
        
        final displayCount = (oldHabit['history'] != null) ? realWeeklyCount : newCount;

        setState(() {
          userTasks[index] = {
            ...oldHabit,
            'is_completed': newStatus,
            'weekly_current': displayCount,
            'last_done_at': newStatus ? DateTime.now().toIso8601String() : oldHabit['last_done_at'],
            'history': history,
            'completion_count': (oldHabit['completion_count'] ?? 0) + (newStatus ? 1 : -1),
          };
        });
       
       try {
          final Map<String, dynamic> updateData = {
            'completion_count': (oldHabit['completion_count'] ?? 0) + (newStatus ? 1 : -1),
            'history': history,
          };
          if (newStatus) {
            updateData['last_done_at'] = DateTime.now().toUtc().toIso8601String();
          }
          await supabase.from('habits').update(updateData).eq('id', originalId).eq('user_id', userId);
          widget.onHabitUpdated?.call(); 
       } catch (e) {
          debugPrint("Habit Toggle Err: $e");
          if (mounted) setState(() => userTasks[index] = oldHabit);
          String msg = "خطأ في تحديث العادة";
          if (e.toString().contains("column") && e.toString().contains("history")) {
             msg = "Missing 'history' column in DB. Please add it.";
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
       }

    } else {
        // Session Task Logic
        try {
           await supabase.from('tasks').update({'is_completed': !currentStatus}).eq('id', originalId).eq('user_id', userId);
           await _loadTasksProgress(); 
        } catch (e) {
           debugPrint("Task Toggle Err: $e");
        }
    }
  }

  Future<void> _openAddHabitPage({Map<String, dynamic>? habitToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHabitPage(habit: habitToEdit),
      ),
    );

    if (result == true) {
      _loadTasksProgress();
      widget.onHabitUpdated?.call(); // Notify tasks screen to refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(habitToEdit == null ? "تمت إضافة العادة" : "تم تحديث العادة")),
      );
    }
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
        if (random == 0) return {'title': 'قاعدة 5-4-3-2-1', 'body': 'عدد 5 أشياء تراها، 4 تلمسها، 3 تسمعها، 2 تشمها، 2 تتذوقها. هذا يعيدك للحاضر.'};
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
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: AppStyle.cardBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => JournalSheetContent(
        isEdit: isEdit,
        existingJournal: latestJournal,
        moods: moods,
        onSave: _saveNewJournal,
        onUpdate: (mood, moodName, desc) async {
             await supabase.from('journals').update({'mode': mood, 'mode_name': moodName, 'mode_description': desc}).eq('id', supabase.auth.currentUser!.id).eq('journal_id', latestJournal!['journal_id']);
             await _loadLatestJournal();
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        body: Container(
          decoration: BoxDecoration(gradient: AppStyle.mainGradient(context)),
          child: SafeArea(
            child: isLoadingData 
            ? const Center(child: CircularProgressIndicator(color: AppStyle.primary))
            : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   HomeHeader(
                     firstName: firstName,
                     onThemeToggle: () {
                         themeNotifier.value = AppStyle.isDark(context) ? ThemeMode.light : ThemeMode.dark;
                     },
                   ),
                   const SizedBox(height: 24),

                   CalendarCard(
                     selectedDate: _selectedDate,
                     locale: _locale,
                     onDateSelected: _onDaySelected,
                   ),
                   const SizedBox(height: 24),

                   JournalCard(
                     latestJournal: latestJournal,
                     onAddPressed: _openAddJournalSheet,
                     onEditPressed: _editJournal,
                     onDeletePressed: _deleteJournal,
                   ),
                   const SizedBox(height: 20),

                   AdviceCard(
                     currentAdvice: currentAdvice,
                     onRefresh: () {
                       if (latestJournal != null) {
                           _getPersonalizedAdvice(latestJournal!['mode_name'] ?? '');
                       } else {
                           _getPersonalizedAdvice('عام');
                       }
                     },
                   ),
                   const SizedBox(height: 20),

                   const SizedBox(height: 10),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 4),
                     child: Text(
                       "مهام الجلسات", 
                       style: GoogleFonts.cairo(
                         fontSize: 18, 
                         fontWeight: FontWeight.bold,
                         color: AppStyle.isDark(context) ? Colors.white : AppStyle.primary
                       )
                     ),
                   ),
                   const SizedBox(height: 10),

                   ProgressCard(
                     progressMessage: progressMessage,
                     taskProgress: taskProgress,
                     onNavigateTo: widget.onNavigateTo,
                   ),
                   const SizedBox(height: 24),

                   HabitList(
                     userTasks: userTasks,
                     habitAdvices: habitAdvices,
                     loadingHabitAdvice: loadingHabitAdvice,
                     onNavigateTo: widget.onNavigateTo,
                     onHabitAdviceReq: _fetchAndShowHabitPopup,
                     onToggle: _handleTaskToggle,
                     onEdit: (habit) => _openAddHabitPage(habitToEdit: habit),
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
  Future<void> _fetchAndShowHabitPopup(String id, String title) async {
      setState(() => loadingHabitAdvice[id] = true);
      try {
         // Using the same API call logic as HabitCard
         const String apiUrl = 'http://127.0.0.1:10000/habit-advice';
         final response = await http.post(
           Uri.parse(apiUrl),
           headers: {'Content-Type': 'application/json'},
           body: jsonEncode({'habit_name': title})
         );
         
         if (!mounted) return;
         
         if (response.statusCode == 200) {
            final data = jsonDecode(utf8.decode(response.bodyBytes));
            final advice = data['advice'] ?? 'استمر في المحاولة!';
            _showHabitAdviceDialog(title, advice);
         } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${response.statusCode}")));
         }
      } catch (e) {
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
         if(mounted) setState(() => loadingHabitAdvice[id] = false);
      }
  }

  void _showHabitAdviceDialog(String title, String advice) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppStyle.cardBg(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "نصيحة لـ $title",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppStyle.textMain(context),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            advice,
            style: GoogleFonts.cairo(
              fontSize: 16, 
              height: 1.5,
              color: AppStyle.textMain(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("حسناً", style: GoogleFonts.cairo(color: AppStyle.primary)),
            ),
          ],
        ),
      ),
    );
  }
}