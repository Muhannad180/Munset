import 'package:flutter/material.dart';
import 'package:test1/core/theme/app_style.dart';

class HabitList extends StatelessWidget {
  final List<Map<String, dynamic>> userTasks;
  final Map<String, String> habitAdvices;
  final Map<String, bool> loadingHabitAdvice;
  final void Function(int)? onNavigateTo;
  final Function(String title) onHabitAdviceReq;

  const HabitList({
    super.key,
    required this.userTasks,
    required this.habitAdvices,
    required this.loadingHabitAdvice,
    this.onNavigateTo,
    required this.onHabitAdviceReq,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: AppStyle.cardRadius,
        boxShadow: AppStyle.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           Row(
             children: [
               const Icon(Icons.track_changes, color: AppStyle.primary),
               const SizedBox(width: 10),
               Text("تتبع العادات", style: AppStyle.cardTitle(context)),
             ],
           ),
           const SizedBox(height: 16),
           if (userTasks.isEmpty)
               Center(
                 child: Padding(
                   padding: const EdgeInsets.all(20),
                   child: Text("أضف عادة جديدة تساعدك على تحسين يومك 🌟", style: AppStyle.bodySmall(context), textAlign: TextAlign.center),
                 )
               )
           else
               ...userTasks.map((task) => _buildHabitItem(context, task)).toList(),
               
           const SizedBox(height: 10),
           TextButton(
             onPressed: () => onNavigateTo?.call(3),
             child: const Text("إدارة العادات +", style: TextStyle(fontWeight: FontWeight.bold)),
           )
        ],
      ),
    );
  }

  Widget _buildHabitItem(BuildContext context, Map<String, dynamic> task) {
    String id = (task['id'] ?? task['task_id'] ?? '').toString();
    String title = (task['title'] ?? task['task'] ?? 'بدون عنوان').toString();
    bool isCompleted = task['is_completed'] ?? task['task_completion'] ?? false;
    String? localAdvice = habitAdvices[id];
    bool isLoadingAdv = loadingHabitAdvice[id] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context), 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withOpacity(0.1),
            blurRadius: 20, 
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppStyle.isDark(context) ? Colors.white10 : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               // Custom Animated Checkbox Effect
               AnimatedContainer(
                 duration: const Duration(milliseconds: 300),
                 width: 28,
                 height: 28,
                 decoration: BoxDecoration(
                   color: isCompleted ? AppStyle.primary : Colors.transparent,
                   borderRadius: BorderRadius.circular(10), // Squircle
                   border: Border.all(
                     color: isCompleted ? AppStyle.primary : Colors.grey.withOpacity(0.5),
                     width: 2,
                   ),
                 ),
                 child: isCompleted 
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
               ),
               const SizedBox(width: 16),
               
               Expanded(
                 child: Text(
                   title, 
                   style: AppStyle.body(context).copyWith(
                     decoration: isCompleted ? TextDecoration.lineThrough : null, 
                     color: isCompleted ? Colors.grey : AppStyle.textMain(context),
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
               
               // AI Advice Trigger
               IconButton(
                 icon: isLoadingAdv 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.lightbulb_outline, color: Colors.orangeAccent.withOpacity(0.8)),
                 onPressed: () => onHabitAdviceReq(title),
               ),
             ],
           ),
           
           if (localAdvice != null) ...[
             const SizedBox(height: 12),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: AppStyle.primary.withOpacity(0.08),
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Icon(Icons.auto_awesome, size: 16, color: AppStyle.primary),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       localAdvice,
                       style: TextStyle(color: AppStyle.primary, fontSize: 13, height: 1.4),
                     ),
                   ),
                 ],
               ),
             ),
           ],
        ],
      ),
    );
  }
}
