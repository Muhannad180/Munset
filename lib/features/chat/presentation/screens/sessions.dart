import 'package:flutter/material.dart';
import 'package:test1/features/chat/presentation/screens/chat_session_page.dart';
import 'dart:io';
import 'package:test1/features/home/presentation/screens/home.dart';
import 'package:test1/core/theme/app_style.dart';

class Sessions extends StatelessWidget {
  const Sessions({super.key});
  final Color primaryColor = const Color(0xFF5E9E92);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),

        body: Column(
          children: [
             SizedBox(
               height: 150,
               child: Stack(
                 alignment: Alignment.topCenter,
                 children: [
                   Container(
                     height: 120,
                     width: double.infinity,
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter, end: Alignment.bottomCenter,
                         colors: AppStyle.isDark(context) 
                           ? [const Color(0xFF1F2E2C), AppStyle.bgTop(context)] 
                           : [AppStyle.primary, AppStyle.primary.withOpacity(0.6)],
                       ),
                       borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                     ),
                   ),
                   Positioned(
                     top: 60,
                     child: Column(
                       children: [
                         const Text("الجلسات", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                         const Text("جلسات علاجية مخصصة لك", style: TextStyle(color: Colors.white70, fontSize: 12)),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
             Expanded(
               child: ListView(
                 padding: const EdgeInsets.all(20),
                 children: [
                   _sessionCard(context, 'الجلسة 1', '20/4/2025', 'منتهية', Icons.check_circle, isDone: true),
                   const SizedBox(height: 15),
                   _sessionCard(context, 'جلسة جديدة', 'اليوم', 'ابدأ الآن', Icons.add_circle, isNew: true),
                   const SizedBox(height: 15),
                   _sessionCard(context, 'الجلسة 3', '4/5/2025', 'قادمة', Icons.lock, isLocked: true),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(BuildContext ctx, String title, String date, String status, IconData icon, {bool isNew = false, bool isLocked = false, bool isDone = false}) {
    return InkWell(
      onTap: () {
        if (isNew) {
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ChatSessionPage(sessionTitle: 'جلسة جديدة', sessionId: '', sessionNumber: 1, isCompleted: false,)));
        } else if (isLocked) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('الجلسة مقفلة حالياً')));
        } else {
          Navigator.push(ctx, MaterialPageRoute(builder: (_) => ChatSessionPage(sessionTitle: title, sessionId: '1', sessionNumber: 1, isCompleted: isDone,)));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5E9E92), Color(0xFF80CBC4)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: const Color(0xFF5E9E92).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(isLocked ? Icons.lock_outline : (isDone ? Icons.check_circle_outline : Icons.access_time), size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text('$date - $status', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}