import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_style.dart';

class HabitCard extends StatelessWidget {
  final Map<String, dynamic> habit;
  final VoidCallback onIncrement;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    
    final title = (habit['title'] ?? '').toString();
    final description = (habit['description'] ?? '').toString();
    final completionCount = habit['completion_count'] ?? 0;

    final dynamic iconVal = habit['icon_name'];
    int? codePoint;
    if (iconVal is int) {
      codePoint = iconVal;
    } else if (iconVal is String) {
      codePoint = int.tryParse(iconVal);
    } else if (iconVal is double) {
      codePoint = iconVal.toInt();
    }

    final IconData icon = codePoint != null
        ? IconData(codePoint, fontFamily: 'MaterialIcons')
        : Icons.star;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppStyle.isDark(context) ? Colors.white10 : Colors.white60,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon Container with subtle gradient
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppStyle.primary.withOpacity(0.15),
                  AppStyle.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppStyle.primary, size: 28),
          ),
          const SizedBox(width: 16),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppStyle.textMain(context),
                  ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Counter and Add Button
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppStyle.isDark(context) ? Colors.grey[800] : const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$completionCount",
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppStyle.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppStyle.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppStyle.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
