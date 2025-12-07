import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/data/services/auth_service.dart';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:test1/features/tasks/presentation/screens/add_habit_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep this import as it was in the original file and might be used by other parts of the app or implicitly by the new code.

class TasksScreen extends StatefulWidget {
  final VoidCallback? onDataUpdated;
  const TasksScreen({super.key, this.onDataUpdated});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final authService = AuthService();
  final Color primaryColor = const Color(0xFF5E9E92);

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> habits = [];
  bool isLoading = true;

  late AnimationController _btnController;
  late PageController _pageController;
  late TabController _tabController;

  int currentPage = 0;

  /// الأسابيع – انت حر تغير التواريخ لاحقاً
  final DateTime startDate = DateTime.now(); // بداية الأسبوع الأول

  void _openAddHabitPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitPage()),
    );

    if (result != null) {
      await _addHabitToDatabase(result);
    }
  }

  Future<void> _addHabitToDatabase(Map data) async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    try {
      await supabase.from('habits').insert({
        'user_id': userId,
        'title': data["name"],
        'is_completed': false,
        // We might lose description/days/freq if columns don't exist, but this keeps the app running.
      });

      _loadAllData(); // Use our load method that fetches both
      widget.onDataUpdated?.call(); // IMPORTANT: Added back this line
    } catch (e) {
      debugPrint("Add Habit Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  // Refactored to fetch from both tables like before
  Future<void> _loadAllData() async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;
    
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // 1. Fetch Habits
      final habitsRes = await supabase
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at');
      
      // 2. Fetch Tasks
      final tasksRes = await supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      if (mounted) {
        setState(() {
          habits = List<Map<String, dynamic>>.from(habitsRes);
          tasks = List<Map<String, dynamic>>.from(tasksRes);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleTask(dynamic item, bool isHabit) async {
    // item is the map. needed id.
    final id = item['id'];
    final currentVal = item['is_completed'] ?? false; // Friend code used task_completion. Our DB uses is_completed.

    try {
      setState(() {
        if (isHabit) {
          int index = habits.indexWhere((h) => h['id'] == id);
          if (index != -1) habits[index]['is_completed'] = !currentVal;
        } else {
          int index = tasks.indexWhere((t) => t['id'] == id);
          if (index != -1) tasks[index]['is_completed'] = !currentVal;
        }
      });

      final tableName = isHabit ? 'habits' : 'tasks';
      await supabase
          .from(tableName)
          .update({'is_completed': !currentVal})
          .eq('id', id);
          
      widget.onDataUpdated?.call(); // IMPORTANT: Added back this line

    } catch (e) {
      _loadAllData();
    }
  }

  /// =============== واجهة إضافة عنصر ===============
  // Replaced by _openAddHabitPage

  /// =============== صفحة المهام + الأسابيع ===============
  Widget _tasksPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("قوائم المهام"),
          const SizedBox(height: 10),
          weeklyTasksSection(), // <<<<<<<< الأسابيع هنا
        ],
      ),
    );
  }

  /// =============== صفحة العادات ===============
  Widget _habitsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("العادات اليومية"),
          if (habits.isEmpty) const Center(child: Text("لا توجد عادات")),
          ...habits.map((e) => _taskTile(e, true)),
        ],
      ),
    );
  }

  /// =============== صفحة الإحصائيات (Dashboard) ===============
  Widget _chartPage() {
    // 1. حسابات البيانات
    final allItems = [...habits, ...tasks];
    final completedCount = allItems.where((t) => t['is_completed'] == true).length;
    final pendingCount = allItems.length - completedCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان: نظرة عامة
          Text("نظرة عامة على المهام", 
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),

          // 1. البطاقات العلوية (المكتملة vs العالقة)
          Row(
            children: [
              Expanded(child: _statCard("المهام المكتملة", "$completedCount", Colors.blue[50]!)),
              const SizedBox(width: 15),
              Expanded(child: _statCard("المهام العالقة", "$pendingCount", Colors.blue[50]!)),
            ],
          ),
          const SizedBox(height: 20),

          // 2. الرسم البياني العمودي (Bar Chart)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50], // خلفية سماوية فاتحة
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("إنجاز المهمة اليومية", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                    const Icon(Icons.bar_chart, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide right (since RTL, left is Y)
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
                              if (value.toInt() < 0 || value.toInt() >= days.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(days[value.toInt()], style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey)),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        // Mock data distribution based on index (just for viz)
                        // In real app, aggregate by day
                        double yVal = (index == 5) ? completedCount.toDouble() : 0; 
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: yVal,
                              color: yVal > 0 ? const Color(0xFF64B5F6) : Colors.transparent, // Blue for active
                              width: 15,
                              borderRadius: BorderRadius.circular(4),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 10,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. المهام القادمة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("المهام في 7 أيام القادمة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                // Placeholder count
                Text("0", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.grey[700])), 
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. الدائرة (Pie Chart) - افتح المهام في الفئات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50], // Same bg
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("افتح المهام في الفئات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                    DropdownButton<String>(
                      value: "في 30 يوم",
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
                      items: const [DropdownMenuItem(value: "في 30 يوم", child: Text("في 30 يوم"))],
                      onChanged: (_) {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     // Legend
                     Expanded(
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF4285F4), borderRadius: BorderRadius.circular(2))),
                           const SizedBox(width: 8),
                           Flexible(
                             child: Text(
                               "لا تصنيف ${allItems.length}", 
                               style: GoogleFonts.cairo(color: Colors.grey[700]),
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                         ],
                       ),
                     ),
                     // Chart
                     SizedBox(
                       width: 120,
                       height: 120,
                       child: PieChart(
                         PieChartData(
                           centerSpaceRadius: 35,
                           sectionsSpace: 0,
                           startDegreeOffset: -90,
                           sections: [
                             PieChartSectionData(
                               value: 100, // Full circle for design match concept
                               color: const Color(0xFF4285F4), // Google Blue
                               radius: 25,
                               showTitle: false,
                             ),
                           ],
                         ),
                       ),
                     ),
                  ],
                ),
              ],
            ),
          ),
           const SizedBox(height: 80), // Bottom padding
        ],
      ),
    );
  }

  // بطاقة إحصائية
  Widget _statCard(String title, String count, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(count, style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 5),
          Text(title, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _taskTile(Map<String, dynamic> t, bool isHabit) {
    final isDone = t['is_completed'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDone
            ? Border.all(color: primaryColor.withOpacity(0.3))
            : null,
      ),
      child: ListTile(
        leading: Checkbox(
          value: isDone,
          activeColor: primaryColor,
          onChanged: (_) => _toggleTask(t, isHabit),
        ),
        title: Text(
          t['title'] ?? t['task'] ?? '', // Handle both potential key names
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

  /// =============== عنوان قسم ===============
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );
  }

  /// =============== الأسابيع 1–8 ===============
  Widget weeklyTasksSection() {
    List<Widget> weekWidgets = [];

    for (int i = 1; i <= 8; i++) {
      DateTime weekStart = startDate.add(Duration(days: (i - 1) * 7));
      DateTime weekEnd = weekStart.add(const Duration(days: 7));

      bool isAvailable = DateTime.now().isAfter(weekStart);
      bool isExpired = DateTime.now().isAfter(weekEnd);

      weekWidgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.white : Colors.grey.shade300, // مغلق
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isAvailable ? primaryColor : Colors.grey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// عنوان الأسبوع + التاريخ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "قائمة مهام الأسبوع $i",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isAvailable ? primaryColor : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    "ينتهي: ${weekEnd.toString().substring(0, 10)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpired ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// لو الاسبوع غير مفعل
              if (!isAvailable)
                const Text(
                  "سيتم فتح مهام هذا الأسبوع لاحقاً",
                  style: TextStyle(color: Colors.black54),
                ),

              /// لو مفعل
              if (isAvailable) ...tasks.map((e) => _taskTile(e, false)).toList(),
            ],
          ),
        ),
      );
    }

    return Column(children: weekWidgets);
  }

  Widget buildTab(String title, int index) {
    final bool isSelected = _tabController.index == index;
    return Tab(
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /// =============== الواجهة ===============
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text(
            "الأنشطة",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: const Color(0xFFB2BEC3),
            child: TabBar(
              controller: _tabController,
                indicator: const BoxDecoration(),
              onTap: (index) {
                _pageController.jumpToPage(index);
              },
                tabs: [
                  buildTab("المهام", 0),
                  buildTab("العادات", 1),
                  buildTab("الإنجازات", 2),
              ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : PageView(
                controller: _pageController,
                onPageChanged: (i) {
                  setState(() => currentPage = i);
                  _tabController.animateTo(i);
                },
                children: [_tasksPage(), _habitsPage(), _chartPage()],
              ),
        floatingActionButton: currentPage == 1 ? _addHabitButton() : null,
      ),
    );
  }

  /// =============== زر الإضافة ===============
  Widget _addHabitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0, left: 10),
      child: GestureDetector(
        onTapDown: (_) => _btnController.forward(),
        onTapUp: (_) {
          _btnController.reverse();
          _openAddHabitPage();
        },
        onTapCancel: () => _btnController.reverse(),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.9).animate(_btnController),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}