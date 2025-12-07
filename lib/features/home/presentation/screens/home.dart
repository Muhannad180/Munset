import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:test1/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final VoidCallback? onReload;
  final ValueNotifier<bool>? refreshNotifier;
  const HomePage({super.key, this.onReload, this.refreshNotifier});

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

  final Color primaryColor = const Color(0xFF5E9E92);
  final Color bgColor = const Color(0xFFF8F9FA);

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
    {'title': 'تمرين التنفس العميق', 'body': 'خذ شهيقاً بطيئاً من الأنف، ثم احبس نفسك لمدة ٤ ثوانٍ، وازفر ببطء من الفم.'},
    {'title': 'تدوين الانتصارات الصغيرة', 'body': 'اكتب شيئاً واحداً أنجزته اليوم، حتى لو كان بسيطاً. التركيز على الإيجابيات يعزز الشعور بالرضا.'},
    {'title': 'تحديد الفكرة السلبية', 'body': 'عندما تخطر ببالك فكرة سلبية، حددها، ثم ابحث عن دليل يدعمها ودليل يدحضها.'},
  ];
  late Map<String, String> currentAdvice;
  TextEditingController _emotionController = TextEditingController();
  bool isGeneratingAdvice = false;

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
    
    // Only show full loading if we have no data yet (first load)
    if (firstName.isEmpty && latestJournal == null) {
      setState(() => isLoadingData = true);
    }
    
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() { isLoadingData = false; firstName = 'ضيف'; });
      return;
    }
    await Future.wait([_loadUserData(), _loadLatestJournal(), _loadTasksProgress()]);
    
    // Generate advice based on the latest journal if available
    if (latestJournal != null) {
       _getPersonalizedAdvice(latestJournal!['mode_description'] ?? '');
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

  Future<void> _loadTasksProgress() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Fetch habits
      final habitsRes = await supabase.from('habits').select().eq('user_id', userId);
      final List<Map<String, dynamic>> habitsList = List<Map<String, dynamic>>.from(habitsRes);

      // 2. Fetch tasks
      final tasksRes = await supabase.from('tasks').select().eq('user_id', userId); 
      final List<Map<String, dynamic>> tasksList = List<Map<String, dynamic>>.from(tasksRes);

      // Combine
      final allItems = [...habitsList, ...tasksList];

      if (mounted) {
        if (allItems.isEmpty) {
          setState(() { taskProgress = 0.0; userTasks = []; });
        } else {
          final completed = allItems.where((t) => t['is_completed'] == true).length;
          setState(() {
            taskProgress = allItems.isNotEmpty ? (completed / allItems.length) : 0.0;
            // Take top 4 to display
            userTasks = allItems.take(4).toList();
          });
        }
      }
    } catch (e) { debugPrint("Tasks Err: $e"); }
  }

  // --- دوال الحذف والتعديل والإضافة ---

  Future<void> _saveNewJournal(String mood, String moodName, String desc, String feelingForAdvice) async {
    debugPrint("Saving Journal. Mood: $mood, AdviceText: $feelingForAdvice");
    final user = supabase.auth.currentUser;
    if (user == null) return;
    
    // Optimistic Update: Update UI immediately
    String fullDesc = desc;
    if (feelingForAdvice.isNotEmpty) {
      fullDesc += "\n\n[مشاعر إضافية]: $feelingForAdvice";
    }
    
    setState(() {
      latestJournal = {
        'mode': mood,
        'mode_name': moodName,
        'mode_description': fullDesc,
        'mode_date': DateTime.now().toIso8601String(),
         // Temporary ID, will be refreshed
        'journal_id': -1, 
      };
    });

    try {
      final lastRec = await supabase.from('journals').select('journal_id').eq('id', user.id).order('journal_id', ascending: false).limit(1).maybeSingle();
      int newId = (lastRec != null) ? (lastRec['journal_id'] + 1) : 1;

      await supabase.from('journals').insert({
        'id': user.id, 'journal_id': newId, 'mode': mood, 'mode_name': moodName, 'mode_description': fullDesc, 'mode_date': DateTime.now().toIso8601String(),
      });
      
      await _loadLatestJournal(); 
      
      String textToUse = feelingForAdvice.isNotEmpty ? feelingForAdvice : desc;
      if (textToUse.isNotEmpty) {
        debugPrint("Triggering advice generation for: $textToUse");
        // Don't await this, let it run in background/UI
        _getPersonalizedAdvice(textToUse);
      } else {
        debugPrint("No text available for advice generation.");
      }

    } catch (e) { debugPrint("Save Err: $e"); }
  }

    void _openAddJournalSheet() {
    int selectedMoodIndex = 4;
    final detailsCtrl = TextEditingController();
    final adviceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: StatefulBuilder(builder: (c, setSt) => SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("كيف تشعر اليوم؟", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            
             // Mood Selector
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  ui.PointerDeviceKind.touch,
                  ui.PointerDeviceKind.mouse,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(moods.length, (i) {
                    bool isSelected = selectedMoodIndex == i;
                    return GestureDetector(
                      onTap: () => setSt(() => selectedMoodIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: isSelected ? Border.all(color: primaryColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                              ),
                              child: Text(moods[i]['emoji']!, style: TextStyle(fontSize: isSelected ? 36 : 28)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              moods[i]['name']!, 
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? primaryColor : Colors.grey[600]
                              )
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Container(width: 5, height: 5, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle))
                            ]
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
             // Display selected mood name prominently
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(moods[selectedMoodIndex]['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            ),
            const SizedBox(height: 20),
            
            // First Field: General Notes
            TextField(
              controller: detailsCtrl, 
              textAlign: TextAlign.right, 
              maxLines: 3, 
              decoration: InputDecoration(
                hintText: "اكتب ما بخاطرك (ملاحظات عامة)...", 
                filled: true, 
                fillColor: Colors.grey[100], 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
              )
            ),
            const SizedBox(height: 15),

            // Second Field: For Advice
            TextField(
              controller: adviceCtrl, 
              textAlign: TextAlign.right, 
              maxLines: 2, 
              decoration: InputDecoration(
                hintText: "صف شعورك للحصول على نصيحة (اختياري)...", 
                filled: true, 
                fillColor: Colors.blue[50], 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
              )
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () { 
                _saveNewJournal(
                  moods[selectedMoodIndex]['emoji']!, 
                  moods[selectedMoodIndex]['name']!, 
                  detailsCtrl.text,
                  adviceCtrl.text
                ); 
                Navigator.pop(ctx); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("حفظ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ]),
        )),
      ),
    );
  }

  Future<void> _deleteJournal() async {
    if (latestJournal == null) return;
    bool confirm = await showDialog(context: context, builder: (ctx) => Directionality(textDirection: ui.TextDirection.rtl, child: AlertDialog(title: const Text("حذف"), content: const Text("تأكيد الحذف؟"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("حذف", style: TextStyle(color: Colors.red)))]))) ?? false;
    if (!confirm) return;
    try {
      await supabase.from('journals').delete().eq('id', supabase.auth.currentUser!.id).eq('journal_id', latestJournal!['journal_id']);
      _loadLatestJournal();
    } catch (e) { debugPrint("Del Err: $e"); }
  }

  void _editJournal() {
    if (latestJournal == null) return;
    int selectedMoodIndex = moods.indexWhere((m) => m['name'] == latestJournal!['mode_name']);
    if (selectedMoodIndex == -1) selectedMoodIndex = 4;
    final detailsCtrl = TextEditingController(text: latestJournal!['mode_description']);

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
      child: StatefulBuilder(builder: (c, setSt) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("تعديل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 20),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(moods.length, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: InkWell(onTap: () => setSt(() => selectedMoodIndex = i), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: selectedMoodIndex == i ? primaryColor.withOpacity(0.2) : Colors.grey[200], shape: BoxShape.circle), child: Text(moods[i]['emoji']!, style: TextStyle(fontSize: selectedMoodIndex == i ? 30 : 24)))))))),
        const SizedBox(height: 20),
        TextField(controller: detailsCtrl, textAlign: TextAlign.right, maxLines: 3, decoration: InputDecoration(filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await supabase.from('journals').update({'mode': moods[selectedMoodIndex]['emoji'], 'mode_name': moods[selectedMoodIndex]['name'], 'mode_description': detailsCtrl.text}).eq('id', supabase.auth.currentUser!.id).eq('journal_id', latestJournal!['journal_id']);
            Navigator.pop(ctx);
            _loadLatestJournal();
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("تحديث", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ])),
    ));
  }

  Future<void> _getPersonalizedAdvice(String text) async {
    debugPrint("Getting advice for: $text");
    if (text.trim().isEmpty) return;
    if (mounted) setState(() => isGeneratingAdvice = true);

    try {
      const String apiUrl = 'http://127.0.0.1:10000/generate-advice';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emotion_text': text}),
      );

      if (response.statusCode == 200) {
        debugPrint("Advice response: ${response.body}");
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            currentAdvice = {
              'title': 'نصيحة مخصصة لك',
              'body': data['advice'] ?? 'لا توجد نصيحة متاحة.',
            };
          });
          // Not showing snackbar as per user request
        }
      } else {
         debugPrint("Error generating advice: ${response.body}");
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء توليد النصيحة'), backgroundColor: Colors.red));
      }
    } catch (e) {
      debugPrint("Connection error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل الاتصال بالخادم'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isGeneratingAdvice = false);
    }
  }


  void _showAdviceDialog() {
    showDialog(context: context, builder: (ctx) => Directionality(textDirection: ui.TextDirection.rtl, child: Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(alignment: Alignment.topLeft, child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))),
      Text(currentAdvice['title']!, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 10),
      Text(currentAdvice['body']!, style: const TextStyle(fontSize: 16, height: 1.5)),
    ])))));
  }

  @override
  Widget build(BuildContext context) {
    var currentMonth = DateFormat.MMMM(_locale).format(_selectedDate);
    var daysInWeek = _getDaysInWeek(_selectedDate);
    final safeProgress = (taskProgress.isNaN || taskProgress.isInfinite) ? 0.0 : taskProgress;
    final progressPercent = (safeProgress * 100).toInt();
    final hasJournal = latestJournal != null;
    final moodEmoji = latestJournal?['mode'] ?? '😐';
    final moodName = latestJournal?['mode_name'] ?? 'محايد';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(backgroundColor: primaryColor, elevation: 0, automaticallyImplyLeading: false, title: Text('مرحباً بك، $firstName 👋', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), centerTitle: false),
        body: isLoadingData 
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
                  // التقويم
                  _container(child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 18), onPressed: () => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1))),
                      Text(currentMonth, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1))),
                    ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: daysInWeek.map((d) => _dayItem(d)).toList())
                  ])),
                  const SizedBox(height: 20),

                  // المزاج (قابل للضغط للإضافة)
                  _container(child: Column(children: [
                    // 🟢 جعلنا الـ Row قابلة للضغط إذا لم يكن هناك يومية
                    InkWell(
                      onTap: hasJournal ? null : _openAddJournalSheet, // فتح النافذة إذا لم يوجد سجل
                      child: Row(children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: Text(moodEmoji, style: const TextStyle(fontSize: 24))),
                        const SizedBox(width: 15),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(hasJournal ? 'مزاجك: $moodName' : 'كيف تشعر اليوم؟', style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (!hasJournal) const Text('لم تسجل يومية بعد، اضغط للإضافة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ]))
                      ]),
                    ),
                    if (hasJournal) ...[
                      const Divider(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton.icon(onPressed: _editJournal, icon: const Icon(Icons.edit, size: 18, color: Colors.blue), label: const Text("تعديل", style: TextStyle(color: Colors.blue))),
                        TextButton.icon(onPressed: _deleteJournal, icon: const Icon(Icons.delete, size: 18, color: Colors.red), label: const Text("حذف", style: TextStyle(color: Colors.red))),
                      ])
                    ]
                  ])),
                  const SizedBox(height: 20),

                  // النصيحة
                  _container(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.lightbulb_rounded, color: Colors.orange, size: 22), 
                      const SizedBox(width: 8), 
                      Text('نصيحة لك', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                        onPressed: () {
                           if (latestJournal != null) {
                             String desc = latestJournal!['mode_description'] ?? '';
                             _getPersonalizedAdvice(desc);
                           }
                        },
                        tooltip: "تحديث النصيحة",
                      )
                    ]),
                    const SizedBox(height: 10),
                    
                    if (isGeneratingAdvice) 
                      const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
                    else ...[
                      Text(currentAdvice['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(currentAdvice['body']!, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _showAdviceDialog, 
                        child: const Text("اقرأ المزيد", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold))
                      ),
                    ]
                  ])),
                  const SizedBox(height: 20),

                  // المهام
                  _container(child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('إنجاز اليوم', style: TextStyle(fontWeight: FontWeight.bold)), Text('$progressPercent%', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: safeProgress, backgroundColor: Colors.grey[200], color: primaryColor, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                    const SizedBox(height: 15),
                    if (userTasks.isEmpty) const Text("لا توجد مهام نشطة", style: TextStyle(color: Colors.grey)) else ...userTasks.map((t) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Row(children: [Icon(t['is_completed'] == true ? Icons.check_circle : Icons.circle_outlined, color: primaryColor, size: 20), const SizedBox(width: 10), Text(t['title'] ?? '')]))),
                  ])),
                ],
              ),
            ),
      ),
    );
  }

  Widget _container({required Widget child}) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: child);
  }

  Widget _dayItem(DateTime date) {
    bool isSelected = date.day == _selectedDate.day;
    return GestureDetector(onTap: () => _onDaySelected(date), child: Column(children: [Text(DateFormat.E(_locale).format(date), style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 5), CircleAvatar(radius: 18, backgroundColor: isSelected ? primaryColor : Colors.transparent, child: Text(DateFormat.d(_locale).format(date), style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)))]));
  }

  List<DateTime> _getDaysInWeek(DateTime date) {
    var start = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }
}