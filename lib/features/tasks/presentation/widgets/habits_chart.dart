import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/core/theme/app_style.dart';

class HabitsChart extends StatefulWidget {
  final List<Map<String, dynamic>> habits;

  const HabitsChart({super.key, required this.habits});

  @override
  State<HabitsChart> createState() => _HabitsChartState();
}

class _HabitsChartState extends State<HabitsChart> {
  int _selectedIndex = -1; // -1 means "Overall Average"

  @override
  void initState() {
    super.initState();
    _selectedIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) return const SizedBox();

    // Calculate individual progress
    final List<_HabitProgress> habitProgresses = widget.habits.map((h) {
      final int goal = h['Goal'] ?? 7;
      final int current = h['weekly_current'] ?? h['completion_count'] ?? 0;
      final double progress = (goal > 0)
          ? (current / goal).clamp(0.0, 1.0)
          : 0.0;
      // Parse Color
      Color color = AppStyle.primary;
      if (h['color'] != null && h['color'] is int) {
        color = Color(h['color']);
      } else {
        final index = widget.habits.indexOf(h);
        final distinctColors = [
          const Color(0xFF42A5F5), // Blue
          const Color(0xFFFFA726), // Orange
          const Color(0xFF66BB6A), // Green
          const Color(0xFFAB47BC), // Purple
          const Color(0xFFEF5350), // Red
          const Color(0xFF26C6DA), // Cyan
        ];
        color = distinctColors[index % distinctColors.length];
      }

      // Parse Icon
      IconData icon = Icons.star;
      if (h['icon_name'] != null) {
        int? codePoint = int.tryParse(h['icon_name'].toString());
        if (codePoint != null) {
          icon = IconData(codePoint, fontFamily: 'MaterialIcons');
        }
      }

      return _HabitProgress(
        title: h['title'] ?? 'Habit',
        progress: progress,
        color: color,
        icon: icon,
      );
    }).toList();

    // Determine what to show in center
    String centerPercent = "0";
    String centerLabel = "المعدل العام";
    IconData centerIcon = Icons.pie_chart;
    Color centerColor = AppStyle.primary;

    if (_selectedIndex >= 0 && _selectedIndex < habitProgresses.length) {
      final selected = habitProgresses[_selectedIndex];
      centerPercent = "${(selected.progress * 100).toInt()}"; // No % sign yet
      centerLabel = selected.title;
      centerIcon = selected.icon;
      centerColor = selected.color;
    } else {
      // Average
      double totalP = 0;
      if (habitProgresses.isNotEmpty) {
        double sum = 0;
        for (var hp in habitProgresses) sum += hp.progress;
        totalP = sum / habitProgresses.length;
      }
      centerPercent = "${(totalP * 100).toInt()}";
    }

    int doneVal = int.tryParse(centerPercent) ?? 0;
    int undoneVal = 100 - doneVal;

    return Column(
      children: [
        // 1. Title
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ), // Reduced vertical padding
          child: Column(
            children: [
              Text(
                "العادات",
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppStyle.isDark(context)
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Text(
                "آخر 7 أيام",
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Removed SizedBox(height: 10) to move chart up

        // 2. Circular Chart
        SizedBox(
          height: 200, // Reduced height (was 220, originally 240)
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The segmented chart
              SizedBox(
                width: 180, // Slightly reduced width to match height
                height: 180,
                child: CustomPaint(
                  painter: _SegmentedRingPainter(
                    segments: habitProgresses,
                    trackColor: AppStyle.isDark(context)
                        ? const Color(0xFF2C2C2C)
                        : Colors.grey[200]!,
                    selectedIndex: _selectedIndex,
                  ),
                ),
              ),
              // Center Text
              Container(
                width: 130, // Constrain width
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(centerIcon, color: centerColor, size: 28),
                    Text(
                      centerLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const SizedBox(height: 2),
                    // Done Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$doneVal%",
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppStyle.isDark(context)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "منجز",
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Undone Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$undoneVal%",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey, // Reverted to Grey
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "غير منجز", // Undone/Not Finished
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ), // Reverted to Grey
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30), // Increased to 30 as requested
        const SizedBox(height: 30), // Increased to 30 as requested
        // 3. Mini Cards Row - Interactive
        Container(
          height: 130, // Increased height for labels
          margin: const EdgeInsets.only(bottom: 20),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: habitProgresses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = habitProgresses[index];
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedIndex == index) {
                      _selectedIndex = -1; // Deselect to show average
                    } else {
                      _selectedIndex = index;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 85,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item.color.withOpacity(0.15)
                        : (AppStyle.isDark(context)
                              ? const Color(0xFF2C2C2C)
                              : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: item.color, width: 2)
                        : Border.all(color: Colors.transparent, width: 2),
                    boxShadow: [
                      if (!AppStyle.isDark(context) && !isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: item.color, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? item.color
                              : (AppStyle.isDark(context)
                                    ? Colors.white70
                                    : Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${(item.progress * 100).toInt()}%",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppStyle.isDark(context)
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HabitProgress {
  final String title;
  final double progress;
  final Color color;
  final IconData icon;

  _HabitProgress({
    required this.title,
    required this.progress,
    required this.color,
    required this.icon,
  });
}

class _SegmentedRingPainter extends CustomPainter {
  final List<_HabitProgress> segments;
  final Color trackColor;
  final int selectedIndex;
  _SegmentedRingPainter({
    required this.segments,
    required this.trackColor,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final double strokeWidth = 18.0;

    final Paint trackPaint = Paint()
      ..color = trackColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Previously: canvas.drawCircle(center, radius, trackPaint);
    // Now: We draw segment tracks individually below.

    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Divide circle into N equal segments
    final int count = segments.length;
    final double gap = (count > 1) ? 0.15 : 0; // Radian gap
    final double totalAvailableAngle = (2 * pi);
    final double segmentArc = (totalAvailableAngle / count);
    // Start from top
    double startAngle = -pi / 2;

    for (int i = 0; i < count; i++) {
      final segment = segments[i];
      final bool isSelected = (i == selectedIndex);
      // The visual space for this segment
      final double availableSweep = segmentArc - gap;

      // 1. Draw the grey "track" for this specific segment
      trackPaint.color = Colors.grey.withOpacity(0.2);
      trackPaint.strokeWidth = strokeWidth;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gap / 2,
        availableSweep,
        false,
        trackPaint,
      );

      // 2. Draw the progress
      double fillSweep = availableSweep * segment.progress;
      if (fillSweep < 0.05 && segment.progress > 0) fillSweep = 0.05;

      if (segment.progress > 0) {
        progressPaint.color = isSelected
            ? segment.color
            : segment.color.withOpacity(0.8);
        progressPaint.strokeWidth = isSelected
            ? strokeWidth + 4
            : strokeWidth; // Pop out

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + gap / 2,
          fillSweep,
          false,
          progressPaint,
        );
      }

      startAngle += segmentArc;
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedRingPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.segments != segments;
  }
}
