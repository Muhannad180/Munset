import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/data/services/auth_service.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final authService = AuthService();
  final Color primaryColor = const Color(0xFF5E9E92);
  
  // قوائم البيانات المنفصلة
  List<Map<String, dynamic>> tasks = [];  // مهام قادمة من الـ AI
  List<Map<String, dynamic>> habits = []; // عادات يضيفها المستخدم
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // تحميل البيانات من الجدولين
  Future<void> _loadAllData() async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;
    
    // منع تحديث الحالة إذا خرجنا من الصفحة
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // 1. جلب العادات من جدول habits
      final habitsRes = await supabase
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      // 2. جلب المهام من جدول tasks (الخاصة بالـ AI)
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

  // تغيير حالة العادة (إنجاز/عدم إنجاز)
  Future<void> _toggleHabit(int id, bool currentVal) async {
    try {
      // تحديث متفائل للواجهة (Optimistic Update)
      setState(() {
        int index = habits.indexWhere((h) => h['id'] == id);
        if (index != -1) habits[index]['is_completed'] = !currentVal;
      });
      // إرسال للقاعدة
      await supabase.from('habits').update({'is_completed': !currentVal}).eq('id', id);
    } catch (e) {
      // في حال الفشل نعيد التحميل
      _loadAllData();
    }
  }

  // تغيير حالة المهمة
  Future<void> _toggleTask(int id, bool currentVal) async {
    try {
      setState(() {
        int index = tasks.indexWhere((t) => t['id'] == id);
        if (index != -1) tasks[index]['is_completed'] = !currentVal;
      });
      await supabase.from('tasks').update({'is_completed': !currentVal}).eq('id', id);
    } catch (e) {
      _loadAllData();
    }
  }

  // إضافة عادة جديدة (خاص بالمستخدم)
  Future<void> _addHabit(String title, BuildContext dialogContext) async {
    if (title.trim().isEmpty) return;

    final userId = authService.getCurrentUserId();
    if (userId == null) return;
    
    try {
      await supabase.from('habits').insert({
        'user_id': userId, 
        'title': title.trim(), 
        'is_completed': false
      });
      
      if (mounted) {
        Navigator.pop(dialogContext); // إغلاق النافذة
        _loadAllData(); // تحديث القائمة
      }
    } catch (e) { 
      debugPrint("Error adding habit: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل الإضافة", style: GoogleFonts.cairo())));
    }
  }

  // نافذة إضافة عادة جديدة
  void _openAddHabitDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context, 
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl, 
        child: AlertDialog(
          title: Text("إضافة عادة جديدة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl, 
            decoration: InputDecoration(
              hintText: "اسم العادة (مثلاً: شرب ماء)", 
              hintStyle: GoogleFonts.cairo(fontSize: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () => _addHabit(ctrl.text, ctx), 
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor), 
              child: Text("إضافة", style: GoogleFonts.cairo(color: Colors.white))
            ),
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text('مهامي وعاداتي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: primaryColor,
          centerTitle: true,
          elevation: 0
        ),
        
        // زر الإضافة (للعادات فقط) - مرفوع عن البار السفلي
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0, left: 10),
          child: FloatingActionButton(
            onPressed: _openAddHabitDialog,
            backgroundColor: primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        
        body: isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryColor)) 
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- قسم العادات ---
                  _sectionHeader("عاداتي اليومية 🌟"),
                  if (habits.isEmpty) 
                    _emptyState("أضف عاداتك اليومية لتتابعها")
                  else 
                    ...habits.map((h) => _itemTile(h, isHabit: true)),

                  const SizedBox(height: 30),

                  // --- قسم مهام الـ AI ---
                  _sectionHeader("مهام الجلسات 🤖"),
                  if (tasks.isEmpty) 
                    _emptyState("لا توجد مهام من منصت حتى الآن")
                  else 
                    ...tasks.map((t) => _itemTile(t, isHabit: false)),
                ],
              ),
            ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
    );
  }

  Widget _emptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(text, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14)),
      ),
    );
  }

  Widget _itemTile(Map<String, dynamic> item, {required bool isHabit}) {
    final isDone = item['is_completed'] == true;
    final int id = item['id']; // المعرف (BigInt في الداتابيس يقرأ كـ int هنا)
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDone ? Border.all(color: primaryColor.withOpacity(0.3)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]
      ),
      child: ListTile(
        leading: Checkbox(
          value: isDone, 
          activeColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (_) => isHabit ? _toggleHabit(id, isDone) : _toggleTask(id, isDone)
        ),
        title: Text(
          item['title'], 
          style: GoogleFonts.cairo(
            decoration: isDone ? TextDecoration.lineThrough : null, 
            color: isDone ? Colors.grey : Colors.black
          )
        ),
        subtitle: !isHabit && item['session_number'] != null 
            ? Text("من الجلسة رقم ${item['session_number']}", style: GoogleFonts.cairo(fontSize: 10, color: primaryColor)) 
            : null,
      ),
    );
  }
}