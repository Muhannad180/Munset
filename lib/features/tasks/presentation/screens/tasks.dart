import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/core/theme/app_style.dart';
import 'package:test1/data/services/auth_service.dart';
import 'package:test1/features/tasks/presentation/screens/add_habit_screen.dart';
import 'package:test1/features/tasks/presentation/widgets/achievements_view.dart';
import 'package:test1/features/tasks/presentation/widgets/habit_card.dart';
import 'package:test1/features/tasks/presentation/widgets/task_tile.dart';
import 'package:test1/features/tasks/presentation/widgets/habits_chart.dart';
import 'dart:ui' as ui;

import 'package:test1/features/assessment/presentation/screens/results.dart';
import 'package:test1/features/assessment/presentation/screens/test_screen.dart';

class TasksScreen extends StatefulWidget {
  final VoidCallback? onDataUpdated;
  final ValueNotifier<bool>?
  refreshNotifier; // Listen for refresh from other screens
  const TasksScreen({super.key, this.onDataUpdated, this.refreshNotifier});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final authService = AuthService();

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> habits = [];
  bool isLoading = true;

  late AnimationController _btnController;
  late TabController _tabController;
  final DateTime startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _tabController = TabController(
      length: 4,
      vsync: this,
    ); // Updated length to 4
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to update background
      }
    });
    // Listen for refresh requests from other screens
    widget.refreshNotifier?.addListener(_loadAllData);
    _loadAllData();
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_loadAllData);
    _btnController.dispose();
    _tabController.dispose();
    super.dispose();
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
          habits = List<Map<String, dynamic>>.from(habitsRes).map((h) {
            // Process History for Last 7 Days
            List<DateTime> historyDates = [];
            if (h['history'] != null && h['history'] is List) {
              historyDates = (h['history'] as List)
                  .map((e) => DateTime.tryParse(e.toString()))
                  .whereType<DateTime>()
                  .toList();
            }
            final now = DateTime.now();
            final sevenDaysAgo = now.subtract(const Duration(days: 7));
            final int last7DaysCount = historyDates
                .where((d) => d.isAfter(sevenDaysAgo))
                .length;

            return {
              ...h,
              'weekly_current': historyDates.isNotEmpty
                  ? last7DaysCount
                  : (h['completion_count'] ?? 0),
            };
          }).toList();
          tasks = List<Map<String, dynamic>>.from(tasksRes);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _incrementHabitCount(Map<String, dynamic> habit) async {
    final habitId = habit['id'];
    final currentCount = habit['completion_count'] ?? 0;
    final newCount = currentCount + 1;

    try {
      setState(() {
        int index = habits.indexWhere((h) => h['id'] == habitId);
        if (index != -1) {
          // Update History locally
          List<String> history = List<String>.from(
            habits[index]['history'] ?? [],
          );
          history.add(DateTime.now().toUtc().toIso8601String());

          final now = DateTime.now();
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          final int realWeeklyCount = history.where((ts) {
            final dt = DateTime.tryParse(ts);
            return dt != null && dt.isAfter(sevenDaysAgo);
          }).length;

          habits[index] = {
            ...habits[index],
            'completion_count': newCount,
            'last_done_at': DateTime.now().toIso8601String(),
            'history': history,
            'weekly_current': realWeeklyCount,
          };
        }
      });

      final dbHabit = habits.firstWhere((h) => h['id'] == habitId);

      await supabase
          .from('habits')
          .update({
            'completion_count': newCount,
            'last_done_at': DateTime.now().toUtc().toIso8601String(),
            'history': dbHabit['history'],
          })
          .eq('id', habitId);

      widget.onDataUpdated?.call();
    } catch (e) {
      debugPrint("Error incrementing habit: $e");
      String msg = "خطأ في تحديث العادة";
      if (e.toString().contains("column") && e.toString().contains("history")) {
        msg = "Missing 'history' column in DB. Please add it.";
      }
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
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

  void _openAddHabitPage({Map<String, dynamic>? habitToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHabitPage(habit: habitToEdit)),
    );

    if (result != null) {
      _loadAllData();
      widget.onDataUpdated?.call();
    }
  }

  String _sortOption = 'default';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الأنشطة",
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppStyle.textMain(context),
                      ),
                    ),
                    Text(
                      "تابع تقدمك اليومي",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: AppStyle.textSmall(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Custom Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppStyle.isDark(context)
                      ? Colors.black26
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppStyle.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppStyle.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppStyle.textSmall(context),
                  labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "المهام"),
                    Tab(text: "العادات"),
                    Tab(text: "الإنجازات"),
                    Tab(text: "PHQ-9"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Content using TabBarView
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppStyle.primary,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildTasksList(),
                          _buildHabitsList(),
                          AchievementsView(tasks: tasks, habits: habits),
                          _buildPhq9Tab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhq9Tab() {
    return ResultsScreen(
      showBackButton: false,
      onRetakeTest: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TestScreen()),
        );
        // Reload the tab after test completion
        if (result != null || mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildHabitsList() {
    List<Map<String, dynamic>> sortedHabits = List.from(habits);
    if (_sortOption == 'priority') {
      final priorityMap = {'عالية': 3, 'متوسطة': 2, 'منخفضة': 1, 'متوسط': 2};
      sortedHabits.sort((a, b) {
        int pA = priorityMap[a['priority'] ?? 'متوسط'] ?? 1;
        int pB = priorityMap[b['priority'] ?? 'متوسط'] ?? 1;
        return pB.compareTo(pA);
      });
    } else if (_sortOption == 'alpha') {
      sortedHabits.sort(
        (a, b) => (a['title'] ?? '').toString().compareTo(b['title'] ?? ''),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "عاداتك اليومية",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppStyle.textMain(context),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: sortedHabits.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildAddHabitCard();
              final habit = sortedHabits[index - 1];
              return GestureDetector(
                onLongPress: () => _openAddHabitPage(habitToEdit: habit),
                child: HabitCard(
                  habit: habit,
                  onIncrement: () => _incrementHabitCount(habit),
                  onEdit: () => _openAddHabitPage(habitToEdit: habit),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddHabitCard() {
    return GestureDetector(
      onTap: () {
        _openAddHabitPage();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: AppStyle.isDark(context)
              ? Colors.white10
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppStyle.primary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppStyle.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppStyle.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppStyle.primary),
            ),
            const SizedBox(width: 12),
            Text(
              "إضافة عادة جديدة",
              style: GoogleFonts.cairo(
                color: AppStyle.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          "لا توجد مهام حالياً",
          style: GoogleFonts.cairo(color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "مهامك الحالية",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppStyle.primary,
          ),
        ),
        const SizedBox(height: 15),
        ...tasks.map(
          (t) => TaskTile(task: t, onToggle: () => _toggleTask(t, false)),
        ),
      ],
    );
  }
}
