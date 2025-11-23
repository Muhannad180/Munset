import 'package:flutter/material.dart';
import 'package:test1/features/chat/presentation/screens/chat_session_page.dart';

class Sessions extends StatelessWidget {
  const Sessions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light teal background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: Center(
          child: Text(
            'الجلسات',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Session 1 - Completed (with checkmark)
            _buildSessionCard(
              title: 'الجلسة رقم 1',
              subtitle: 'موعد الجلسة 20/4/25 - الحالة منتهية',
              icon: Icons.check,
              iconColor: Colors.white,
              iconBackgroundColor: Color(0xFF8FD3C7),
              isCompleted: true,
              context,
              sessionId: '1',
            ),

            SizedBox(height: 16),

            // Session 2 - Create new session
            _buildSessionCard(
              title: 'الجلسة رقم 2',
              subtitle: 'موعد الجلسة 27/4/25 - الحالة اليوم',
              isCompleted: false,
              isCreateNew: true,
              buttonText: 'إنشاء جلسة',
              context,
              sessionId: '2',
            ),

            SizedBox(height: 16),

            // Session 3 - Locked
            _buildSessionCard(
              title: 'الجلسة رقم 3',
              subtitle: 'موعد الجلسة 27/4/25 - الحالة قادم',
              icon: Icons.lock,
              iconColor: Colors.grey[600]!,
              iconBackgroundColor: Color.fromARGB(255, 105, 147, 139),
              isCompleted: false,
              isLocked: true,
              context,
              sessionId: '3',
            ),

            SizedBox(height: 16),

            // Session 4 - Locked
            _buildSessionCard(
              title: 'الجلسة رقم 4',
              subtitle: 'موعد الجلسة 27/4/25 - الحالة قادم',
              icon: Icons.lock,
              iconColor: Colors.grey[600]!,
              iconBackgroundColor: Color.fromARGB(255, 105, 147, 139),
              isCompleted: false,
              isLocked: true,
              context,
              sessionId: '4',
            ),

            SizedBox(height: 16),

            // Session 5 - Locked
            _buildSessionCard(
              title: 'الجلسة رقم 5',
              subtitle: 'موعد الجلسة 27/4/25 - الحالة قادم',
              icon: Icons.lock,
              iconColor: Colors.grey[600]!,
              iconBackgroundColor: Color.fromARGB(255, 105, 147, 139),
              isCompleted: false,
              isLocked: true,
              context,
              sessionId: '5',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String sessionId,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
    required bool isCompleted,
    bool isCreateNew = false,
    bool isLocked = false,
    String? buttonText,
  }) {
    return GestureDetector(
      onTap: () {
        if (isCreateNew) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatSessionPage(sessionTitle: title, sessionId:''), //session id is null for now, TODO: make code fetch it from data base or assign a unique one
            ),
          );
        } else if (isLocked || isCompleted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('هذه الجلسة مقفلة')));
        }
      },

      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF6BB6AB), // Darker teal for cards
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            //create an if statement here to change the icon button to the text button only for new sessions
            // Left icon
            if (isCreateNew && buttonText != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 24),
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),

            SizedBox(width: 16),

            // Middle content
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Align text to right for Arabic
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),

            // Right side button (only for create new session)
          ],
        ),
      ),
    );
  }
}
