import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_style.dart';

class AchievementsView extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> habits;

  const AchievementsView({
    super.key,
    required this.tasks,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Data
    final int totalTasks = tasks.length;
    final int completedTasks = tasks.where((t) => t['is_completed'] == true).length;

    final int totalHabits = habits.length;
    final int effectiveHabitCompletions = habits.where((h) => (h['completion_count'] ?? 0) > 0).length;

    final int totalItems = (totalTasks + totalHabits) > 0 ? (totalTasks + totalHabits) : 1;
    final int totalCompleted = completedTasks + effectiveHabitCompletions;
    
    int incomplete = (totalTasks + totalHabits) - totalCompleted;
    if (incomplete < 0) incomplete = 0;

    final double percentageVal = (totalTasks + totalHabits) > 0 
        ? (totalCompleted / (totalTasks + totalHabits)) * 100 
        : 0;
    final int percentage = percentageVal.round();

    // 2. Define Colors (Standard App Theme)
    final Color segment1 = AppStyle.primary; // 0xFF4DB6AC
    final Color segment2 = AppStyle.accent;  // 0xFFFFB74D
    
    // Adaptive colors
    final bool isDark = AppStyle.isDark(context);
    final Color incompleteSegment = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final Color textColor = AppStyle.textMain(context);
    final Color subTextColor = AppStyle.textSmall(context);

    // Values
    final double valTasks = completedTasks.toDouble();
    final double valHabits = effectiveHabitCompletions.toDouble();
    final double valIncomplete = incomplete.toDouble();
    final bool isEmpty = (valTasks + valHabits + valIncomplete) == 0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chart Section
            SizedBox(
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 0,
                      centerSpaceRadius: 100,
                      sections: isEmpty ? [
                         PieChartSectionData(
                          value: 1,
                          color: incompleteSegment,
                          radius: 50,
                          showTitle: false,
                        )
                      ] : [
                        // Segment 1: Tasks
                        if (valTasks > 0)
                          PieChartSectionData(
                            value: valTasks,
                            color: segment1,
                            radius: 50,
                            showTitle: false,
                          ),
                        // Segment 2: Habits
                        if (valHabits > 0)
                          PieChartSectionData(
                            value: valHabits,
                            color: segment2,
                            radius: 50,
                            showTitle: false,
                          ),
                        // Segment 3: Incomplete
                        if (valIncomplete > 0)
                          PieChartSectionData(
                            value: valIncomplete,
                            color: incompleteSegment,
                            radius: 50,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                  // Center Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$percentage%",
                        style: GoogleFonts.cairo(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        "اكتمل",
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          color: subTextColor,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Legend Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppStyle.cardBg(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppStyle.cardShadow(context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _buildLegendItem(context, "المهام", segment1),
                   _buildLegendItem(context, "العادات", segment2),
                   _buildLegendItem(context, "لم تكتمل", isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: AppStyle.textMain(context),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
