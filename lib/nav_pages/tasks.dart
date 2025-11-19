import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/login/auth_service.dart';

class TasksScreen extends StatefulWidget {
  final VoidCallback? onUpdated;
  const TasksScreen({super.key, this.onUpdated});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final authService = AuthService();

  late TabController _tabController;

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> habits = [];

  bool isLoadingTasks = true;
  bool isLoadingHabits = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _loadTasks();
    _loadHabits();
  }

  // -------------------------
  //    Load Tasks
  // -------------------------
  Future<void> _loadTasks() async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    setState(() => isLoadingTasks = true);

    final response = await supabase
        .from('tasks')
        .select()
        .eq('id', userId)
        .order('task_id');

    setState(() {
      tasks = List<Map<String, dynamic>>.from(response);
      isLoadingTasks = false;
    });
  }

  Future<void> _toggleTask(int taskId, bool state) async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    await supabase
        .from('tasks')
        .update({'task_completion': !state})
        .eq('id', userId)
        .eq('task_id', taskId);

    _loadTasks();
    widget.onUpdated?.call();
  }

  Future<void> _addTask(String text) async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    int newId = 1;
    if (tasks.isNotEmpty) {
      newId =
          tasks
              .map((e) => e['task_id'] as int)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }

    await supabase.from('tasks').insert({
      'id': userId,
      'task_id': newId,
      'task': text,
      'task_completion': false,
    });

    _loadTasks();
    widget.onUpdated?.call();
  }

  // -------------------------
  //    Load Habits + Daily Status
  // -------------------------
  Future<void> _loadHabits() async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    setState(() => isLoadingHabits = true);

    final habitsData = await supabase
        .from('habits')
        .select()
        .eq('id', userId)
        .order('habit_id');

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final logs = await supabase
        .from('habit_log')
        .select()
        .eq('id', userId)
        .eq('date', today);

    final logMap = {for (var l in logs) l['habit_id']: l};

    setState(() {
      habits = List<Map<String, dynamic>>.from(habitsData)
          .map((h) => {...h, 'done_today': logMap[h['habit_id']] != null})
          .toList();

      isLoadingHabits = false;
    });
  }

  Future<void> _toggleHabitToday(int habitId, bool currentState) async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (!currentState) {
      await supabase.from('habit_log').insert({
        'habit_id': habitId,
        'id': userId,
        'date': today,
        'done': true,
      });
    } else {
      await supabase
          .from('habit_log')
          .delete()
          .eq('habit_id', habitId)
          .eq('id', userId)
          .eq('date', today);
    }

    _loadHabits();
    widget.onUpdated?.call();
  }

  Future<void> _addHabit(String text) async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    int newId = 1;
    if (habits.isNotEmpty) {
      newId =
          habits
              .map((e) => e['habit_id'] as int)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }

    await supabase.from('habits').insert({
      'id': userId,
      'habit_id': newId,
      'habit': text,
    });

    _loadHabits();
    widget.onUpdated?.call();
  }

  // -------------------------
  //     Progress
  // -------------------------
  double _calculateDailyProgress() {
    if (habits.isEmpty) return 0;
    final doneCount = habits.where((h) => h['done_today'] == true).length;
    return doneCount / habits.length;
  }

  // -------------------------
  //     Dialog Add
  // -------------------------
  void _addDialog(String title, Function(String) onSave) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: "اكتب هنا..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onSave(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // -------------------------
  //      Widget Build
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final progress = _calculateDailyProgress();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF5E9E92),
          automaticallyImplyLeading: false,
          centerTitle: true,
          toolbarHeight: 60,
          titleSpacing: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: const Color(0xFF5E9E92),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 155, 214, 199),
                      const Color(0xFF5E9E92),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.task_alt), text: "المهام"),
                  Tab(icon: Icon(Icons.track_changes), text: "العادات"),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          controller: _tabController,
          children: [
            // -------------------  TASKS TAB  -------------------
            isLoadingTasks
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                ? const Center(child: Text("لا توجد مهام ✨"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      final t = tasks[i];
                      return Card(
                        color: t['task_completion']
                            ? Colors.green.shade100
                            : Colors.orange.shade200,
                        child: ListTile(
                          title: Text(
                            t['task'],
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Checkbox(
                            value: t['task_completion'],
                            activeColor: const Color(0xFF5E9E92),
                            onChanged: (_) =>
                                _toggleTask(t['task_id'], t['task_completion']),
                          ),
                        ),
                      );
                    },
                  ),

            // -------------------  HABITS TAB  -------------------
            isLoadingHabits
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220, // تكبير الدائرة
                        width: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 12,
                              color: Colors.grey.shade300,
                            ),
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              color: Colors.green,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${(progress * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "إنجاز اليوم",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: habits.isEmpty
                            ? const Center(child: Text("لا توجد عادات ✨"))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: habits.length,
                                itemBuilder: (ctx, i) {
                                  final h = habits[i];
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        h['habit'],
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Checkbox(
                                        value: h['done_today'],
                                        activeColor: const Color(0xFF5E9E92),
                                        onChanged: (_) => _toggleHabitToday(
                                          h['habit_id'],
                                          h['done_today'],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ],
        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF5E9E92),
            onPressed: () {
              if (_tabController.index == 0) {
                _addDialog("أضف مهمة", _addTask);
              } else {
                _addDialog("أضف عادة", _addHabit);
              }
            },
            child: const Icon(Icons.add, size: 33, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
