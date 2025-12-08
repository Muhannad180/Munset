import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/core/theme/app_style.dart';
import 'package:test1/data/services/auth_service.dart';
import 'package:test1/features/tasks/presentation/screens/add_habit_screen.dart';
import 'package:test1/features/tasks/presentation/widgets/achievements_view.dart';
import 'package:test1/features/tasks/presentation/widgets/habit_card.dart';
import 'package:test1/features/tasks/presentation/widgets/task_tile.dart';
import 'dart:ui' as ui;

class TasksScreen extends StatefulWidget {
  final VoidCallback? onDataUpdated;
  const TasksScreen({super.key, this.onDataUpdated});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with TickerProviderStateMixin {
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

  Future<void> _incrementHabitCount(Map<String, dynamic> habit) async {
    final habitId = habit['id'];
    final currentCount = habit['completion_count'] ?? 0;
    final newCount = currentCount + 1;

    try {
      setState(() {
        int index = habits.indexWhere((h) => h['id'] == habitId);
        if (index != -1) {
          habits[index]['completion_count'] = newCount;
        }
      });

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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "الأنشطة",
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppStyle.textMain(context),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Custom Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppStyle.isDark(context) ? Colors.black26 : Colors.white,
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Content using TabBarView
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: AppStyle.primary))
                    : TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildTasksList(),
                          _buildHabitsList(),
                          AchievementsView(tasks: tasks, habits: habits),
                        ],
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _tabController.animation!,
          builder: (ctx, child) {
            // Only show FAB on Habits tab (index 1)
            // TabController animation value is double, e.g. 0.0 -> 1.0
            // We want to show when near 1.0. 
            // Better to rely on index if using onTap, but swiping is dynamic.
            // Let's just use a simple Visibility based on index if we assume onTap mostly
            return _tabController.index == 1 ? _addHabitButton() : const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHabitsList() {
    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 60, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "لا توجد عادات بعد",
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 80), // offset for fab
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return HabitCard(
          habit: habit,
          onIncrement: () => _incrementHabitCount(habit),
        );
      },
    );
  }

  Widget _buildTasksList() {
    // Reusing the weekly logic but with TaskTile
    List<Widget> weekWidgets = [];

    // Week logic - simplified to just show relevant info cleanly
    for (int i = 1; i <= 8; i++) {
        DateTime weekStart = startDate.add(Duration(days: (i - 1) * 7));
        DateTime weekEnd = weekStart.add(const Duration(days: 7));
        bool isAvailable = DateTime.now().isAfter(weekStart);
        // bool isExpired = DateTime.now().isAfter(weekEnd);

        // Filter tasks? The previous logic just dumped ALL tasks into every week which was weird,
        // or wait, `tasks.map` was done inside. If tasks aren't date-filtered, then they duplicate?
        // Looking at previous code...
        // `...tasks.map` was inside the loop. YES, it duplicated 8 times!
        // That seems like a bug in the previous code or a placeholder.
        // I will fix this to just show ONE list of tasks for "Current Week" or just "All Tasks".
        // The user asked for an overhaul, so fixing logic is valid.
        // I'll assume they want a simple list of tasks for now.
    }

    // Since the previous code duplicated tasks for 8 weeks (likely a template),
    // I will replace it with a proper single list of tasks.
    if (tasks.isEmpty) {
        return Center(
          child: Text("لا توجد مهام حالياً", style: GoogleFonts.cairo(color: Colors.grey)),
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
        ...tasks.map((t) => TaskTile(task: t, onToggle: () => _toggleTask(t, false))),
      ],
    );
  }

  Widget _addHabitButton() {
    return GestureDetector(
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
            color: AppStyle.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppStyle.primary.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
