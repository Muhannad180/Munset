import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:test1/main.dart'; // Assumes this provides 'supabase' client
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  // Callback is used to trigger reloads from other pages (Journal/Tasks)
  final VoidCallback? onReload;
  const HomePage({super.key, this.onReload});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  String _locale = 'ar'; // Set Arabic as default locale for display
  String firstName = '';

  // 🔹 Data Variables
  Map<String, dynamic>? latestJournal;
  double taskProgress = 0.0;
  List<Map<String, dynamic>> userTasks = [];
  bool isLoadingData = true;

  // 🔹 Part 2 Data (CBT Advice List)
  final List<Map<String, String>> cbtAdvices = [
    {
      'title': 'تواصل مع الطبيعة',
      'body':
          'اقضِ وقتاً ممتعاً في الهواء الطلق، محاطاً بالخضرة والهواء النقي، لتحسين مزاجك.',
    },
    {
      'title': 'تمرين التنفس العميق',
      'body':
          'خذ شهيقاً بطيئاً من الأنف، ثم احبس نفسك لمدة ٤ ثوانٍ، وازفر ببطء من الفم. كرر ٥ مرات لتهدئة الأعصاب.',
    },
    {
      'title': 'تدوين الانتصارات الصغيرة',
      'body':
          'اكتب شيئاً واحداً أنجزته اليوم، حتى لو كان بسيطاً. التركيز على الإيجابيات يعزز الشعور بالرضا.',
    },
    {
      'title': 'تحديد الفكرة السلبية واستبدالها',
      'body':
          'عندما تخطر ببالك فكرة سلبية، حددها، ثم ابحث عن دليل يدعمها ودليل يدحضها لتكوين فكرة أكثر واقعية.',
    },
    {
      'title': 'المساواة في التقييم',
      'body':
          'فكر: هل سأحكم على صديقي بنفس القسوة التي أحكم بها على نفسي في نفس الموقف؟',
    },
  ];

  late Map<String, String> currentAdvice;

  @override
  void initState() {
    super.initState();
    _setLocale();
    _loadAllHomeData();
    // Select a random CBT advice on initialization
    currentAdvice = (cbtAdvices..shuffle()).first;
  }

  void _setLocale() async {
    try {
      _locale = Platform.localeName;
      await initializeDateFormatting(_locale, null);
    } catch (e) {
      _locale = 'ar'; // Fallback to Arabic if localeName is not supported
      await initializeDateFormatting(_locale, null);
    }
    setState(() {});
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
  }

  // 🔹 Global method to load all home screen data (Called by external pages via callback)
  Future<void> _loadAllHomeData() async {
    setState(() => isLoadingData = true);
    await _loadUserData();
    await _loadLatestJournal();
    await _loadTasksProgress();
    setState(() => isLoadingData = false);
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return;

    setState(() {
      firstName = response['first_name'] ?? '';
    });
  }

  // 🔹 Part 1: Load the latest journal entry
  Future<void> _loadLatestJournal() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('journals')
          .select()
          .eq('id', user.id)
          .order('mode_date', ascending: false) // Latest first
          .limit(1)
          .maybeSingle();

      setState(() {
        latestJournal = response;
      });
    } catch (e) {
      print('❌ Error loading latest journal: $e');
    }
  }

  // ===============================================
  // 💡 INLINE TASK UTILITY METHODS (Part 3 Logic)
  // -----------------------------------------------

  // 🔹 INLINE: Calculate Task Completion Percentage
  Future<double> _calculateTaskProgress(String? userId) async {
    if (userId == null) return 0.0;

    try {
      final response = await supabase
          .from('tasks')
          .select('task_completion')
          .eq('id', userId);

      final tasks = List<Map<String, dynamic>>.from(response);

      if (tasks.isEmpty) {
        return 0.0;
      }

      final completedTasks = tasks
          .where((task) => task['task_completion'] == true)
          .length;
      final totalTasks = tasks.length;

      return completedTasks / totalTasks;
    } catch (e) {
      print('❌ Error calculating task progress: $e');
      return 0.0;
    }
  }

  // 🔹 INLINE: Load Task List
  Future<List<Map<String, dynamic>>> _loadTasksList(String? userId) async {
    if (userId == null) return [];
    try {
      final response = await supabase
          .from('tasks')
          .select()
          .eq('id', userId)
          .order('task_id');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error loading tasks: $e');
      return [];
    }
  }

  // 🔹 Part 3: Load and calculate task progress (Uses INLINE methods)
  Future<void> _loadTasksProgress() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    // Use INLINE method to calculate progress
    final progress = await _calculateTaskProgress(userId);

    // Use INLINE method to load tasks
    final tasksList = await _loadTasksList(userId);

    setState(() {
      taskProgress = progress;
      // Show the top 4 tasks on the home screen
      userTasks = tasksList.take(4).toList();
    });
  }

  // -----------------------------------------------
  // 💡 END OF INLINE TASK UTILITY METHODS
  // ===============================================

  // Helper function to get color based on mood emoji
  Color _getMoodColor(String? moodEmoji) {
    final moodColors = {
      '😭': Colors.red,
      '😢': Colors.orange,
      '😔': Colors.orangeAccent,
      '😞': Colors.deepOrangeAccent,
      '😐': Colors.grey,
      '🙂': Colors.lightBlueAccent,
      '😄': Colors.green,
      '😍': Colors.pinkAccent,
      '🤩': Colors.amberAccent,
      '😎': Colors.blue,
      '😇': Colors.tealAccent,
      '😤': Colors.redAccent,
      '🥳': Colors.purpleAccent,
      '😴': Colors.indigo,
    };
    if (moodEmoji != null && moodColors.containsKey(moodEmoji)) {
      return moodColors[moodEmoji]!;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    var currentMonth = DateFormat.MMMM(_locale).format(_selectedDate);
    var daysInWeek = _getDaysInWeek(_selectedDate);

    final hasJournal = latestJournal != null;
    final moodEmoji = latestJournal?['mode'] ?? '😐';
    final moodName = latestJournal?['mode_name'] ?? 'محايد';
    final moodDescription =
        latestJournal?['mode_description'] ?? 'لم تقم بتسجيل يومية بعد.';
    final progressPercent = (taskProgress * 100).toInt();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF5F5F5),
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(
              // "مرحبا [First Name]"
              '👋 مرحبا $firstName',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        body: isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 🗓️ CALENDAR WIDGET (Restored)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Month navigation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = DateTime(
                                        _selectedDate.year,
                                        _selectedDate.month - 1,
                                        1,
                                      );
                                    });
                                  },
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 16,
                                  ),
                                ),
                                Text(
                                  currentMonth,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = DateTime(
                                        _selectedDate.year,
                                        _selectedDate.month + 1,
                                        1,
                                      );
                                    });
                                  },
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Days of week
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ...daysInWeek
                                    .map((date) => _buildDayColumn(date, now))
                                    .toList(),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Part 1: Latest Journal Entry
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mood Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getMoodColor(
                                  moodEmoji,
                                ).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  moodEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Mood Name
                                      Text(
                                        hasJournal
                                            ? 'آخر مزاج: $moodName'
                                            : 'لم تسجل شعور اليوم',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Edit/Delete Buttons (Placeholder)
                                      if (hasJournal) ...[
                                        const Text(
                                          'حذف',
                                          style: TextStyle(
                                            color: Colors.pink,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'تعديل',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Journal Description (Truncated)
                                  Text(
                                    moodDescription.length > 80
                                        ? '${moodDescription.substring(0, 80)}...'
                                        : moodDescription,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔹 Part 2: Random CBT Advice/Tip
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentAdvice['title']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5E9E92),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentAdvice['body']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 12),
                            // "Read More" Button (Placeholder)
                            const Text(
                              'اقرأ المزيد',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔹 Part 3: Task Progress Bar
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C3E50),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(
                                    'عظيم! لقد أنجزت ${progressPercent}% من مهامك.',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$progressPercent%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Visual Progress Bar
                            Container(
                              height: 8,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: taskProgress,
                                  backgroundColor: Colors.white38,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.greenAccent,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔹 Part 3: Active Tasks List (Targeted Habits)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المهام النشطة اليوم',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Display tasks from the database
                            if (userTasks.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('لا توجد مهام نشطة حالياً.'),
                                ),
                              )
                            else
                              ...userTasks.map((task) {
                                return _buildTaskItem(
                                  task['task'] as String,
                                  task['task_completion'] as bool,
                                );
                              }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Helper methods (Calendar & Task Item)

  Widget _buildDayColumn(DateTime date, DateTime today) {
    DateTime now =
        DateTime.now(); // Defined again inside this function to be safe

    var isSelectedDay =
        date.day == _selectedDate.day &&
        date.month == _selectedDate.month &&
        date.year == _selectedDate.year;

    var isToday =
        date.day == now.day && date.month == now.month && date.year == now.year;

    // Dynamically get the Arabic day name from the date object
    var dayName = DateFormat.E(_locale).format(date);

    return GestureDetector(
      onTap: () {
        _onDaySelected(date);
      },
      child: Column(
        children: [
          Text(
            dayName,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelectedDay
                  ? const Color(0xFF5E9E92)
                  : (isToday ? Colors.grey[300] : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                DateFormat.d(_locale).format(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelectedDay ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💡 Task Item Widget (replaces old _buildHabitItem)
  Widget _buildTaskItem(String title, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.green.shade800 : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  List<DateTime> _getDaysInWeek(DateTime date) {
    List<DateTime> days = [];
    var startOfWeek = _getStartOfWeek(date);
    for (int i = 0; i < 7; i++) {
      days.add(startOfWeek.add(Duration(days: i)));
    }
    return days;
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Start week on Sunday (weekday 7 or 0)
    var day = date.weekday;
    var daysToSubtract = day % 7;
    return date.subtract(Duration(days: daysToSubtract));
  }
}
