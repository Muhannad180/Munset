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
    // Calculations
    final allTasks = [...habits, ...tasks]; // Or just tasks? Screenshot implied both or separate.
    // Logic from tasks.dart: mixed habits and tasks for completion count?
    // Actually tasks.dart used "items which have 'is_completed' == true". Habits don't strictly have is_completed in the same way usually, but the simplified code in tasks.dart seemed to treat them similarly or just tracked tasks.
    // Let's stick to: Tasks -> is_completed. Habits -> completion_count.

    final completedTasksCount = tasks.where((t) => t['is_completed'] == true).length;
    
    final totalHabitCompletions = habits.fold<int>(0, (sum, habit) {
      final count = habit['completion_count'];
      return sum + (count is int ? count : (count is double ? count.toInt() : 0));
    });

    final maxHabitCompletion = habits.isEmpty
        ? 10.0
        : habits.fold<double>(10.0, (max, habit) {
            final count = habit['completion_count'];
            final val = count is int
                ? count.toDouble()
                : (count is double ? count : 0.0);
            return val > max ? val : max;
          });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "ملخص نشاطك",
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppStyle.textMain(context),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 20),

          // 1. Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: "المهام المنجزة",
                  value: "$completedTasksCount",
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF4DB6AC), // Primary Teal
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: "إنجاز العادات",
                  value: "$totalHabitCompletions",
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFFFB74D), // Accent Orange
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 2. Bar Chart Section (Habits)
          _buildSectionContainer(
            context,
            title: "أداء العادات",
            child: habits.isEmpty
                ? _buildEmptyState(context, "لا توجد عادات لعرض الرسم البياني")
                : AspectRatio(
                    aspectRatio: 1.5,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxHabitCompletion + 2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                (rod.toY.toInt()).toString(),
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < 0 || value.toInt() >= habits.length) {
                                  return const SizedBox();
                                }
                                final habit = habits[value.toInt()];
                                String title = (habit['title'] ?? '').toString();
                                if (title.length > 5) title = "${title.substring(0, 4)}..";
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: AppStyle.textSmall(context),
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(habits.length, (index) {
                          final habit = habits[index];
                          final count = habit['completion_count'] ?? 0;
                          final val = count is int ? count.toDouble() : (count is double ? count : 0.0);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: val > 0 ? val : 0.2, // Min height for visibility
                                color: AppStyle.primary,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxHabitCompletion + 2,
                                  color: AppStyle.isDark(context) ? Colors.white10 : Colors.grey.shade100,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          // 3. Pie Chart (Tasks)
          _buildSectionContainer(
            context,
            title: "حالة المهام",
            child: tasks.isEmpty
                ? _buildEmptyState(context, "لا توجد مهام حالياً")
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             _buildLegendItem(context, "منجزة", const Color(0xFF4CAF50), completedTasksCount),
                             const SizedBox(height: 10),
                             _buildLegendItem(context, "غير منجزة", const Color(0xFFFF7043), tasks.length - completedTasksCount),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: [
                              if (completedTasksCount > 0)
                                PieChartSectionData(
                                  value: completedTasksCount.toDouble(),
                                  color: const Color(0xFF4CAF50),
                                  radius: 20,
                                  showTitle: false,
                                ),
                              if ((tasks.length - completedTasksCount) > 0)
                                PieChartSectionData(
                                  value: (tasks.length - completedTasksCount).toDouble(),
                                  color: const Color(0xFFFF7043),
                                  radius: 20,
                                  showTitle: false,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppStyle.textMain(context),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppStyle.textSmall(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppStyle.textMain(context),
                ),
              ),
              Icon(Icons.more_horiz, color: AppStyle.textSmall(context)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          msg,
          style: TextStyle(color: AppStyle.textSmall(context)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          "$label ($count)",
          style: GoogleFonts.cairo(
            color: AppStyle.textMain(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
