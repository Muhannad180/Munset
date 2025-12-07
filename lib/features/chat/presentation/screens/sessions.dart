import 'package:flutter/material.dart';
import 'package:test1/features/chat/presentation/screens/chat_session_page.dart';
import 'dart:io';

class Sessions extends StatelessWidget {
  const Sessions({super.key});
  final Color primaryColor = const Color(0xFF5E9E92);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('الجلسات', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: ListView(
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryColor, // Solid Teal
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('$date - $status', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
            Icon(icon, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}