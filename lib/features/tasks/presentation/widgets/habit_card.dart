import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/theme/app_style.dart';

class HabitCard extends StatefulWidget {
  final Map<String, dynamic> habit;
  final VoidCallback onIncrement;
  final VoidCallback? onEdit;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onIncrement,
    this.onEdit,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _isLoadingAdvice = false;

  Future<void> _fetchAndShowAdvice(BuildContext context) async {
    final title = widget.habit['title'] ?? 'Habit';
    print("DEBUG: Requesting advice for $title");
    setState(() => _isLoadingAdvice = true);

    try {
      final url = Uri.parse('https://munset-backend.onrender.com/habit-advice');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'habit_name': title}),
      );

      print("DEBUG: Response Code ${response.statusCode}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final advice = data['advice'] ?? 'استمر في المحاولة!';
        print("DEBUG: Advice parsed: $advice");
        _showAdviceDialog(context, title, advice);
      } else {
        print("DEBUG: Error status ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("DEBUG: Exception $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get advice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingAdvice = false);
    }
  }

  void _showAdviceDialog(BuildContext context, String title, String advice) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppStyle.cardBg(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "نصيحة لـ $title",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppStyle.textMain(context),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            advice,
            style: GoogleFonts.cairo(
              fontSize: 16,
              height: 1.5,
              color: AppStyle.textMain(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "حسناً",
                style: GoogleFonts.cairo(color: AppStyle.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final title = (habit['title'] ?? '').toString();
    final description = (habit['description'] ?? '').toString();

    // Parse new fields with fallbacks
    final completionCount = habit['completion_count'] ?? 0;
    final int goalTarget = (habit['Goal'] is int)
        ? habit['Goal']
        : 7; // Use 'Goal' column
    final String goalUnit = (habit['frequency'] ?? 'يومي').toString();
    final String priority = (habit['priority'] ?? 'متوسط').toString();

    // Parse Color
    final dynamic colorVal = habit['color'];
    Color habitColor = AppStyle.primary;
    if (colorVal is int) {
      habitColor = Color(colorVal);
    }

    // Parse Icon
    final dynamic iconVal = habit['icon_name'];
    int? codePoint;
    if (iconVal is int) {
      codePoint = iconVal;
    } else if (iconVal is String) {
      codePoint = int.tryParse(iconVal);
    }
    final IconData icon = codePoint != null
        ? IconData(codePoint, fontFamily: 'MaterialIcons')
        : Icons.star;

    // Progress
    double progress = (completionCount / goalTarget).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: habitColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: habitColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      habitColor.withOpacity(0.2),
                      habitColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: habitColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Title & Desc & Priority Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        // Priority Badge
                        if (priority != "متوسط")
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: priority == "عالية"
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: priority == "عالية"
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.green.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              priority,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: priority == "عالية"
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppStyle.textSmall(context),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Bulb Icon Action
              IconButton(
                onPressed: _isLoadingAdvice
                    ? null
                    : () => _fetchAndShowAdvice(context),
                icon: _isLoadingAdvice
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lightbulb, color: Colors.amber),
                tooltip: "نصيحة ذكية",
              ),

              // Edit Action
              if (widget.onEdit != null)
                IconButton(
                  onPressed: widget.onEdit,
                  icon: Icon(Icons.edit, color: AppStyle.primary),
                  tooltip: "تعديل العادة",
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress & Action
          Row(
            children: [
              // Progress Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$completionCount / $goalTarget $goalUnit",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppStyle.textSmall(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: habitColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppStyle.isDark(context)
                            ? Colors.white10
                            : Colors.grey[200],
                        color: habitColor,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Increment Button
              InkWell(
                onTap: (completionCount >= goalTarget)
                    ? null
                    : widget.onIncrement,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (completionCount >= goalTarget)
                        ? Colors.grey
                        : habitColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (completionCount >= goalTarget)
                            ? Colors.grey.withOpacity(0.4)
                            : habitColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    (completionCount >= goalTarget) ? Icons.check : Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
