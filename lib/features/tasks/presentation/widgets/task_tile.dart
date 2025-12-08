import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_style.dart';

class TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggle;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task['is_completed'] == true;
    final title = (task['title'] ?? task['task'] ?? '').toString();

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDone 
              ? (AppStyle.isDark(context) ? Colors.white.withOpacity(0.05) : Colors.grey[50]) 
              : AppStyle.cardBg(context),
          borderRadius: BorderRadius.circular(16),
          // Subtle border for done state or shadow for active state
          border: isDone 
              ? Border.all(color: Colors.transparent) 
              : Border.all(color: AppStyle.isDark(context) ? Colors.white10 : Colors.black.withOpacity(0.05)),
          boxShadow: isDone
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Custom Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? AppStyle.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppStyle.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: isDone ? FontWeight.normal : FontWeight.w600,
                  color: isDone 
                      ? (AppStyle.isDark(context) ? Colors.white38 : Colors.grey)
                      : AppStyle.textMain(context),
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: AppStyle.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
