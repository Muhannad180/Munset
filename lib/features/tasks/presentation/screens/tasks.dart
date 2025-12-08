import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/data/services/auth_service.dart';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:test1/features/tasks/presentation/screens/add_habit_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final DateTime startDate = DateTime.now();

  void _openAddHabitPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitPage()),
    );

    if (result != null) {
      _loadAllData();
      widget.onDataUpdated?.call();
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

  Future<void> _loadAllData() async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final habitsRes = await supabase
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at');

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

  /// زيادة عداد إنجاز العادة
  Future<void> _incrementHabitCount(Map<String, dynamic> habit) async {
    final habitId = habit['id'];
    final currentCount = habit['completion_count'] ?? 0;
    final newCount = currentCount + 1;

    try {
      // تحديث محلي فوري
      setState(() {
        int index = habits.indexWhere((h) => h['id'] == habitId);
        if (index != -1) {
          habits[index]['completion_count'] = newCount;
        }
      });

      // تحديث في قاعدة البيانات
      await supabase
          .from('habits')
          .update({'completion_count': newCount})
          .eq('id', habitId);

      widget.onDataUpdated?.call();
    } catch (e) {
      debugPrint("Error incrementing habit: $e");
      _loadAllData();
    }
  }

  Future<void> _toggleTask(dynamic item, bool isHabit) async {
    final id = item['id'];
    final currentVal = item['is_completed'] ?? false;

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

      widget.onDataUpdated?.call();
    } catch (e) {
      _loadAllData();
    }
  }

  Widget _tasksPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("قوائم المهام"),
          const SizedBox(height: 10),
          weeklyTasksSection(),
        ],
      ),
    );
  }

  Widget _habitsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("العادات اليومية"),
          const SizedBox(height: 15),
          if (habits.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  "لا توجد عادات\nاضغط + لإضافة عادة جديدة",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ...habits.map((e) => _habitCard(e)),
          const SizedBox(height: 160),
        ],
      ),
    );
  }

  Widget _chartPage() {
    final allItems = [...habits, ...tasks];
    final completedCount = allItems
        .where((t) => t['is_completed'] == true)
        .length;

    // حساب مجموع completion_count لكل العادات
    final totalCompletions = habits.fold<int>(0, (sum, habit) {
      final count = habit['completion_count'];
      return sum +
          (count is int ? count : (count is double ? count.toInt() : 0));
    });

    // حساب أعلى قيمة completion_count للرسم البياني
    final maxHabitCompletion = habits.isEmpty
        ? 10.0
        : habits.fold<double>(10.0, (max, habit) {
            final count = habit['completion_count'];
            final val = count is int
                ? count.toDouble()
                : (count is double ? count : 0.0);
            return val > max ? val : max;
          });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "نظرة عامة على المهام والعادات",
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  "المهام المكتملة",
                  "$completedCount",
                  Colors.blue[50]!,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _statCard(
                  "إنجازات العادات",
                  "$totalCompletions",
                  Colors.green[50]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // الرسم البياني العمودي للعادات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "إنجاز العادات",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Icon(Icons.bar_chart, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 20),
                if (habits.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "لا توجد عادات لعرضها",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxHabitCompletion + 2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= habits.length) {
                                  return const SizedBox();
                                }
                                final habit = habits[index];
                                final count = habit['completion_count'];
                                final countVal = count is int
                                    ? count
                                    : (count is double ? count.toInt() : 0);

                                // إظهار الرقم فقط إذا كان أكبر من 0
                                if (countVal > 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      '$countVal',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 35,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < 0 ||
                                    value.toInt() >= habits.length) {
                                  return const SizedBox();
                                }
                                final habit = habits[value.toInt()];
                                final title = habit['title'] ?? '';
                                // أول 5 أحرف من العنوان
                                final shortTitle = title.length > 5
                                    ? title.substring(0, 5)
                                    : title;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    shortTitle,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(habits.length, (index) {
                          final habit = habits[index];
                          final count = habit['completion_count'];
                          final yVal = count is int
                              ? count.toDouble()
                              : (count is double ? count : 0.0);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: yVal > 0 ? yVal : 0.5,
                                color: yVal > 0
                                    ? primaryColor
                                    : Colors.grey.shade300,
                                width: habits.length > 5 ? 12 : 18,
                                borderRadius: BorderRadius.circular(6),
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

          // الدائرة (Pie Chart) - المهام المنجزة وغير المنجزة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "المهام المنجزة والغير منجزة",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                if (allItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "لا توجد مهام لعرضها",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Legend
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "منجزة: $completedCount",
                                    style: GoogleFonts.cairo(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9800),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "غير منجزة: ${allItems.length - completedCount}",
                                    style: GoogleFonts.cairo(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
                            sectionsSpace: 2,
                            startDegreeOffset: -90,
                            sections: [
                              if (completedCount > 0)
                                PieChartSectionData(
                                  value: completedCount.toDouble(),
                                  color: const Color(0xFF4CAF50),
                                  radius: 25,
                                  showTitle: false,
                                ),
                              if (allItems.length - completedCount > 0)
                                PieChartSectionData(
                                  value: (allItems.length - completedCount)
                                      .toDouble(),
                                  color: const Color(0xFFFF9800),
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
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _statCard(String title, String count, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// بطاقة العادة الجديدة مع عداد الإنجاز
  Widget _habitCard(Map<String, dynamic> habit) {
    final title = habit['title'] ?? '';
    final description = habit['description'] ?? '';
    final completionCount = habit['completion_count'] ?? 0;

    final dynamic iconVal = habit['icon_name'];
    int? codePoint;
    if (iconVal is int) {
      codePoint = iconVal;
    } else if (iconVal is String) {
      codePoint = int.tryParse(iconVal);
    } else if (iconVal is double) {
      codePoint = iconVal.toInt();
    }

    final IconData icon = codePoint != null
        ? IconData(codePoint, fontFamily: 'MaterialIcons')
        : Icons.star;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة العادة
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 15),

          // النصوص (العنوان والوصف)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // عداد الإنجاز
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$completionCount",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // زر + لزيادة العدد
              GestureDetector(
                onTap: () => _incrementHabitCount(habit),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
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
          t['title'] ?? t['task'] ?? '',
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

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
            color: isAvailable ? Colors.white : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isAvailable ? primaryColor : Colors.grey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              if (!isAvailable)
                const Text(
                  "سيتم فتح مهام هذا الأسبوع لاحقاً",
                  style: TextStyle(color: Colors.black54),
                ),

              if (isAvailable)
                ...tasks.map((e) => _taskTile(e, false)).toList(),
            ],
          ),
        ),
      );
    }

    return Column(children: weekWidgets);
  }

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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              onTap: (index) {
                _pageController.jumpToPage(index);
              },
              tabs: const [
                Tab(text: "المهام"),
                Tab(text: "العادات"),
                Tab(text: "الإنجازات"),
              ],
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