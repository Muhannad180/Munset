import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test1/core/theme/app_style.dart';

class JournalCard extends StatelessWidget {
  final Map<String, dynamic>? latestJournal;
  final VoidCallback onAddPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const JournalCard({
    super.key,
    this.latestJournal,
    required this.onAddPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasJournal = latestJournal != null;
    final moodEmoji = latestJournal?['mode'] ?? '😐';
    final moodDesc = latestJournal?['mode_description'] ?? 'لم تسجل شعور اليوم.';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            if (hasJournal) ...[
              if ((latestJournal!['mode_name'] ?? '').contains('غاضب')) const Color(0xFFEF9A9A) 
              else if ((latestJournal!['mode_name'] ?? '').contains('حزين')) const Color(0xFF90CAF9) 
              else if ((latestJournal!['mode_name'] ?? '').contains('قلق')) const Color(0xFFCE93D8) 
              else if ((latestJournal!['mode_name'] ?? '').contains('متحمس') || (latestJournal!['mode_name'] ?? '').contains('سعيد')) const Color(0xFFFFCC80) 
              else const Color(0xFF80CBC4) 
            ] else ...[const Color(0xFFAED581)], 
            AppStyle.isDark(context) ? const Color(0xFF424242) : Colors.white
          ], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
        borderRadius: AppStyle.cardRadius,
        boxShadow: AppStyle.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(hasJournal ? moodEmoji : '📝', style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      hasJournal ? (latestJournal!['mode_name'] ?? '') : 'جديد',
                      style: AppStyle.bodySmall(context).copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              if (hasJournal)
                Text(DateFormat('HH:mm').format(DateTime.parse(latestJournal!['mode_date'])), style: AppStyle.bodySmall(context).copyWith(color: AppStyle.isDark(context) ? Colors.white70 : Colors.black54)),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
             onTap: hasJournal ? null : onAddPressed,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   hasJournal ? "شعرت بـ: ${latestJournal!['mode_name']}" : "كيف كان يومك؟",
                   style: AppStyle.heading(context).copyWith(fontSize: 24, color: AppStyle.isDark(context) ? Colors.white : Colors.black87),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   hasJournal ? moodDesc : "سجل مشاعرك الآن...",
                   style: AppStyle.body(context).copyWith(color: AppStyle.isDark(context) ? Colors.white70 : Colors.black54),
                   maxLines: 3,
                   overflow: TextOverflow.ellipsis,
                 ),
               ],
             )
          ),
          if (hasJournal) ...[
             const SizedBox(height: 20),
             Row(
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                  InkWell(onTap: onEditPressed, child: Icon(Icons.edit_outlined, size: 20, color: AppStyle.isDark(context) ? Colors.white60 : Colors.black54)),
                  const SizedBox(width: 16),
                  InkWell(onTap: onDeletePressed, child: Icon(Icons.delete_outline, size: 20, color: Colors.red[400])),
               ],
             )
          ]
        ],
      ),
    );
  }
}
