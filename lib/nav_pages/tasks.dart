import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/login/auth_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final supabase = Supabase.instance.client;
  final authService = AuthService();
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // 🔹 جلب المهام
  Future<void> _loadTasks() async {
    try {
      final response = await supabase.from('tasks').select().order('task_id');
      setState(() {
        tasks = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل المهام: $e');
      setState(() => isLoading = false);
    }
  }

  // 🔹 إضافة مهمة جديدة
  Future<void> _addTask(String taskText) async {
    try {
      // توليد task_id جديد (أكبر قيمة موجودة + 1)
      int newTaskId = 1;
      if (tasks.isNotEmpty) {
        final ids = tasks.map((t) => t['task_id'] as int).toList();
        newTaskId = ids.reduce((a, b) => a > b ? a : b) + 1;
      }

      final uuid = authService.getCurrentUserId();

      await supabase.from('tasks').insert({
        'id': uuid,
        'task_id': newTaskId,
        'task': taskText,
        'task_completion': false,
      });

      await _loadTasks();
    } catch (e) {
      print('❌ خطأ أثناء إضافة المهمة: $e');
    }
  }

  // 🔹 تغيير حالة المهمة
  Future<void> _toggleTaskCompletion(int taskId, bool currentState) async {
    try {
      await supabase
          .from('tasks')
          .update({'task_completion': !currentState})
          .eq('task_id', taskId);
      await _loadTasks();
    } catch (e) {
      print('❌ خطأ أثناء تحديث المهمة: $e');
    }
  }

  // 🔹 نافذة إضافة مهمة
  void _openAddTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('أضف مهمة جديدة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اكتب المهمة هنا'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addTask(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'المهام',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5E9E92),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(child: Text('لا توجد مهام بعد ✨'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (ctx, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: task['task_completion']
                      ? Colors.lightGreen
                      : Colors.orange[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      task['task'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: task['task_completion'] ?? false,
                        onChanged: (_) => _toggleTaskCompletion(
                          task['task_id'],
                          task['task_completion'],
                        ),
                        activeColor: Color(0xFF5E9E92),
                        checkColor: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          onPressed: _openAddTaskDialog,
          backgroundColor: const Color(0xFF5E9E92),
          child: const Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
