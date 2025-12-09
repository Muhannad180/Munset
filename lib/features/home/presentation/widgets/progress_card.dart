import 'package:flutter/material.dart';
import 'package:test1/core/theme/app_style.dart';

class ProgressCard extends StatelessWidget {
  final String progressMessage;
  final double taskProgress;
  final void Function(int)? onNavigateTo;

  const ProgressCard({
    super.key,
    required this.progressMessage,
    required this.taskProgress,
    this.onNavigateTo,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = (taskProgress.isNaN || taskProgress.isInfinite) ? 0.0 : taskProgress;
    final progressPercent = (safeProgress * 100).toInt();

    return Container(
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
         gradient: LinearGradient(
           colors: AppStyle.isDark(context) 
             ? [const Color(0xFF283593).withOpacity(0.8), const Color(0xFF424242)]
             : [const Color(0xFF7986CB), const Color(0xFFC5CAE9)], 
           begin: Alignment.topLeft,
           end: Alignment.bottomRight
         ),
         borderRadius: AppStyle.cardRadius,
         boxShadow: AppStyle.cardShadow(context),
       ),
       child: Row(
         children: [
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(progressMessage, style: AppStyle.cardTitle(context).copyWith(fontSize: 16, color: AppStyle.isDark(context) ? Colors.white : const Color(0xFF1A237E))),
                 const SizedBox(height: 20),
                 ElevatedButton.icon(
                   onPressed: () => onNavigateTo?.call(3),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppStyle.isDark(context) ? Colors.grey[800] : Colors.white,
                     foregroundColor: AppStyle.isDark(context) ? Colors.white : const Color(0xFF1A237E),
                     elevation: 0,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                   ),
                   icon: const Icon(Icons.check_circle_outline, size: 20),
                   label: const Text("مهامي"),
                 )
               ],
             ),
           ),
           const SizedBox(width: 12),
           Stack(alignment: Alignment.center, children: [
              SizedBox(width: 80, height: 80, child: CircularProgressIndicator(value: safeProgress, color: AppStyle.isDark(context) ? Colors.indigoAccent : const Color(0xFF1A237E), backgroundColor: Colors.white54, strokeWidth: 8, strokeCap: StrokeCap.round)),
              Text("$progressPercent%", style: AppStyle.heading(context).copyWith(fontSize: 18, color: AppStyle.isDark(context) ? Colors.white : const Color(0xFF1A237E)))
           ])
         ],
       ),
    );
  }
}
