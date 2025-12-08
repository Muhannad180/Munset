import 'package:flutter/material.dart';
import 'package:test1/core/theme/app_style.dart';

class AdviceCard extends StatelessWidget {
  final Map<String, String> currentAdvice;
  final VoidCallback onRefresh;

  const AdviceCard({
    super.key,
    required this.currentAdvice,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppStyle.isDark(context) 
            ? [const Color(0xFFF9A825).withOpacity(0.5), const Color(0xFF424242)] 
            : [const Color(0xFFFFF59D), Colors.white], 
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
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                 child: const Icon(Icons.lightbulb_outline, size: 20, color: Colors.orange),
               ),
               const SizedBox(width: 12),
               Text("نصيحة اليوم", style: AppStyle.cardTitle(context)),
               const Spacer(),
               IconButton(
                 icon: Icon(Icons.refresh, size: 20, color: AppStyle.textSmall(context)),
                 onPressed: onRefresh,
               )
           ]),
           const SizedBox(height: 16),
           Text(
             currentAdvice['body']!,
             style: AppStyle.body(context).copyWith(height: 1.6),
           )
        ],
      ),
    );
  }
}
