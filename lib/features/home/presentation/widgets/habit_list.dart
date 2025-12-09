import 'package:flutter/material.dart';
import 'package:test1/core/theme/app_style.dart';

class HabitList extends StatelessWidget {
  final List<Map<String, dynamic>> userTasks;
  final Map<String, String> habitAdvices;
  final Map<String, bool> loadingHabitAdvice;
  final void Function(int)? onNavigateTo;
  final Function(String id, String title) onHabitAdviceReq;
  final Function(String id, bool currentStatus) onToggle;
  final Function(Map<String, dynamic> habit)? onEdit;

  const HabitList({
    super.key,
    required this.userTasks,
    required this.habitAdvices,
    required this.loadingHabitAdvice,
    this.onNavigateTo,
    required this.onHabitAdviceReq,
    required this.onToggle,
    this.onEdit,
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
             onPressed: () => onNavigateTo?.call(3), // Index 3 is TasksScreen
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
    bool isLoadingAdv = loadingHabitAdvice[id] == true;

    // Extract Color
    final dynamic colorVal = task['color'];
    Color habitColor = AppStyle.primary;
    if (colorVal is int) habitColor = Color(colorVal);

    // Extract Icon
    final dynamic iconVal = task['icon_name'];
    int? codePoint;
    if (iconVal is int) {
      codePoint = iconVal;
    } else if (iconVal is String) {
      codePoint = int.tryParse(iconVal);
    }
    final IconData icon = codePoint != null
        ? IconData(codePoint, fontFamily: 'MaterialIcons')
        : Icons.star;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context), 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: habitColor.withOpacity(0.1),
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
               // Habit Icon (Swapped position to start)
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: habitColor.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Icon(icon, color: habitColor, size: 24),
               ),
               const SizedBox(width: 12),
               
               // Title & Weekly Progress
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       title, 
                       style: AppStyle.body(context).copyWith(
                         color: isCompleted ? Colors.grey : AppStyle.textMain(context),
                         fontWeight: FontWeight.bold,
                         fontSize: 16,
                       ),
                     ),
                     const SizedBox(height: 4),
                     // Weekly Progress Text
                     Text(
                       "الأسبوع: ${(task['weekly_current'] ?? 0)} / ${(task['weekly_goal'] ?? 1)}",
                       style: TextStyle(
                         color: AppStyle.textSmall(context), 
                         fontSize: 12,
                       ),
                     ),
                   ],
                 ),
               ),

                // AI Advice Trigger
                IconButton(
                  icon: isLoadingAdv 
                     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                     : const Icon(Icons.lightbulb_outline, color: Colors.amber), 
                  onPressed: () => onHabitAdviceReq(id, title),
                ),
                
                // Edit Trigger
                if (onEdit != null)
                   IconButton(
                     icon: Icon(Icons.edit, color: AppStyle.primary, size: 24),
                     onPressed: () => onEdit!(task),
                     tooltip: "تعديل العادة",
                   ),
              ],
            ),
           const SizedBox(height: 12),
           
           // Daily "Done" Button
           // Daily "Done" Button
           // Logic: If completed today -> Allow undo (Active Button)
           // If NOT completed today BUT quota reached -> Disable Button
           // Else -> Allow do (Active Button)
           
           Builder(builder: (context) {
             final int current = task['weekly_current'] ?? 0;
             final int goal = task['weekly_goal'] ?? 7;
             final bool quotaMet = current >= goal;
             final bool canInteract = isCompleted || !quotaMet;
             
             return GestureDetector(
               onTap: canInteract ? () => onToggle(id, isCompleted) : null,
               child: AnimatedContainer(
                 duration: const Duration(milliseconds: 300),
                 width: double.infinity,
                 padding: const EdgeInsets.symmetric(vertical: 10),
                 decoration: BoxDecoration(
                   color: isCompleted ? habitColor : (canInteract ? Colors.transparent : Colors.grey.withOpacity(0.1)),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(
                     color: isCompleted ? habitColor : (canInteract ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.1)),
                     width: 1.5,
                   ),
                   boxShadow: isCompleted 
                     ? [BoxShadow(color: habitColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                     : [],
                 ),
                 alignment: Alignment.center,
                 child: Text(
                   isCompleted 
                      ? "تم الإنجاز لليوم" 
                      : (quotaMet ? "اكتمل الهدف الأسبوعي!" : "تسجيل إنجاز اليوم"),
                   style: TextStyle(
                     color: isCompleted ? Colors.white : (canInteract ? Colors.grey : Colors.grey.withOpacity(0.5)),
                     fontWeight: FontWeight.bold,
                     fontSize: 14,
                   ),
                 ),
               ),
             );
           }),
        ],
      ),
    );
  }
}
