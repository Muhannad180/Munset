import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/data/services/auth_service.dart';
import 'dart:ui' as ui;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final authService = AuthService();
  final Color primaryColor = const Color(0xFF5E9E92);
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> habits = [];
  bool isLoading = true;
  late AnimationController _btnController;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;
    try {
      final response = await supabase.from('tasks').select().eq('id', userId).order('task_id');
      final allItems = List<Map<String, dynamic>>.from(response);
      if(mounted) setState(() { habits = allItems.where((t) => t['is_habit'] == true).toList(); tasks = allItems.where((t) => t['is_habit'] != true).toList(); isLoading = false; });
    } catch (e) { if(mounted) setState(() => isLoading = false); }
  }

  Future<void> _toggleTask(int taskId, bool currentVal) async {
    try {
      setState(() {
        int index = tasks.indexWhere((t) => t['task_id'] == taskId);
        if (index != -1) { tasks[index]['task_completion'] = !currentVal; } 
        else { index = habits.indexWhere((t) => t['task_id'] == taskId); if (index != -1) habits[index]['task_completion'] = !currentVal; }
      });
      await supabase.from('tasks').update({'task_completion': !currentVal}).eq('task_id', taskId);
    } catch (e) { _loadTasks(); }
  }

  Future<void> _addTask(String title, bool isHabit) async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;
    try {
      await supabase.from('tasks').insert({'id': userId, 'task': title, 'task_completion': false, 'is_habit': isHabit});
      _loadTasks();
    } catch (e) { debugPrint("$e"); }
  }

  void _openAddDialog() {
    final ctrl = TextEditingController();
    bool isHabit = false;
    showDialog(context: context, builder: (ctx) => Directionality(textDirection: ui.TextDirection.rtl, child: StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: const Text("إضافة جديدة", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: ctrl, decoration: const InputDecoration(hintText: "العنوان")),
        const SizedBox(height: 20),
        Row(children: [const Text("هل هي عادة يومية؟"), const Spacer(), Switch(value: isHabit, activeColor: primaryColor, onChanged: (val) => setDialogState(() => isHabit = val))])
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")), ElevatedButton(onPressed: () { _addTask(ctrl.text, isHabit); Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: primaryColor), child: const Text("إضافة", style: TextStyle(color: Colors.white)))]
    ))));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('مهامي وعاداتي', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: primaryColor, centerTitle: true, elevation: 0),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0, left: 10),
          child: GestureDetector(
            onTapDown: (_) => _btnController.forward(),
            onTapUp: (_) { _btnController.reverse(); _openAddDialog(); },
            onTapCancel: () => _btnController.reverse(),
            child: ScaleTransition(scale: Tween<double>(begin: 1.0, end: 0.9).animate(_btnController), child: Container(width: 56, height: 56, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]), child: const Icon(Icons.add, color: Colors.white))),
          ),
        ),
        body: isLoading ? Center(child: CircularProgressIndicator(color: primaryColor)) : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionHeader("العادات اليومية 🌟"),
            if (habits.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("لا توجد عادات مضافة", style: TextStyle(color: Colors.grey)))) else ...habits.map((t) => _taskTile(t)),
            const SizedBox(height: 30),
            _sectionHeader("قائمة المهام ✅"),
            if (tasks.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("لا توجد مهام مضافة", style: TextStyle(color: Colors.grey)))) else ...tasks.map((t) => _taskTile(t)),
          ]),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)));
  }

  Widget _taskTile(Map<String, dynamic> t) {
    final isDone = t['task_completion'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: isDone ? Border.all(color: primaryColor.withOpacity(0.3)) : null),
      child: ListTile(
        leading: Checkbox(value: isDone, activeColor: primaryColor, onChanged: (_) => _toggleTask(t['task_id'], isDone)),
        title: Text(t['task'], style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null, color: isDone ? Colors.grey : Colors.black)),
      ),
    );
  }
}