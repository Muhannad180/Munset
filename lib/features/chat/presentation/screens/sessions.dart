import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/features/chat/presentation/screens/chat_session_page.dart';

class Sessions extends StatefulWidget {
  const Sessions({super.key});

  @override
  State<Sessions> createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchSessions();
  }

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    // New Supabase API: no `.execute()`, awaiting the query returns a List
    final data = await supabase
        .from('Sessions')
        .select()
        .eq('user_id', user.id)
        .order('session_number');

    if (data == null) return [];

    final list = data as List;
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الجلسات',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('حدث خطأ ما، حاول مرة أخرى لاحقاً'),
            );
          }

          final sessions = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                for (int i = 1; i <= 8; i++) ...[
                  _buildSessionCardForNumber(context, i, sessions),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 96),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds one card (1..8) using data from Supabase + locking rules.
  Widget _buildSessionCardForNumber(
    BuildContext context,
    int sessionNumber,
    List<Map<String, dynamic>> sessions,
  ) {
    final now = DateTime.now().toUtc();

    // Find this session row (if it exists)
    Map<String, dynamic>? currentRow;
    for (final row in sessions) {
      if (row['session_number'] == sessionNumber) {
        currentRow = row;
        break;
      }
    }

    // Find previous session row for lock logic
    Map<String, dynamic>? prevRow;
    if (sessionNumber > 1) {
      for (final row in sessions) {
        if (row['session_number'] == sessionNumber - 1) {
          prevRow = row;
          break;
        }
      }
    }

    final String status = (currentRow?['status'] as String?) ?? '';
    final bool isCompleted = status == 'completed';

    // 7-day unlock logic based on previous session
    bool unlocked = true;
    if (sessionNumber > 1) {
      if (prevRow == null) {
        unlocked = false;
      } else if (prevRow['status'] != 'completed' ||
          prevRow['ended_at'] == null) {
        unlocked = false;
      } else {
        try {
          final endedAt =
              DateTime.parse(prevRow['ended_at'] as String).toUtc();
          if (endedAt.isAfter(now.subtract(const Duration(days: 7)))) {
            unlocked = false;
          }
        } catch (_) {
          // If parsing fails, be safe and lock
          unlocked = false;
        }
      }
    }

    final bool isLocked = !unlocked;
    final bool isCreateNew = unlocked && !isCompleted;
    final dynamic rawSessionId = currentRow?['session_id'];
    final String sessionId = rawSessionId?.toString() ?? '';


    // Basic subtitle based on state (you can customize later)
    final String subtitle;
    if (isCompleted) {
      subtitle = 'الحالة منتهية';
    } else if (isLocked) {
      subtitle = 'الحالة قادم';
    } else {
      subtitle = 'الحالة اليوم';
    }

    final String title = 'الجلسة رقم $sessionNumber';

    return _buildSessionCard(
      context,
      title: title,
      subtitle: subtitle,
      sessionId: sessionId,
      sessionNumber: sessionNumber,
      icon: isCompleted
          ? Icons.check
          : (isLocked ? Icons.lock : Icons.chat_bubble_outline),
      iconColor: isLocked ? Colors.grey[200] : Colors.white,
      iconBackgroundColor: isLocked
          ? const Color.fromARGB(255, 105, 147, 139)
          : const Color(0xFF8FD3C7),
      isCompleted: isCompleted,
      isLocked: isLocked,
      isCreateNew: isCreateNew,
      buttonText: isCreateNew ? 'ابدأ الجلسة' : null,
    );
  }
}

Widget _buildSessionCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String sessionId,
  required int sessionNumber,
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
      if (isLocked) {
        // Locked: show message, do not navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'هذه الجلسة لم تُفتح بعد. ستتوفر بعد إكمال الجلسة السابقة.',
            ),
          ),
        );
        return;
      }

      // Available: either new or ongoing session
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatSessionPage(
            sessionTitle: title,
            sessionId: sessionId, // '' if fresh session
            sessionNumber: sessionNumber,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8FD3C7),
            Color.fromARGB(255, 105, 147, 139),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left icon area
          if (!isCreateNew) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconBackgroundColor ??
                        const Color.fromARGB(255, 105, 147, 139))
                    .withOpacity(isLocked ? 0.6 : 1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? (isCompleted ? Icons.check : Icons.lock),
                color: iconColor ?? Colors.white,
                size: 26,
              ),
            ),
          ] else ...[
            // For "create new" show a more active icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF8FD3C7).withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],

          const SizedBox(width: 16),

          // Text side (right, Arabic)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(isLocked ? 0.7 : 1),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                if (isCompleted) ...[
                  Text(
                    'الحالة: منتهية',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ] else if (isLocked) ...[
                  Text(
                    'الحالة: قادمة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right-edge chip button only for "create new" sessions
          if (isCreateNew && buttonText != null) ...[
            const SizedBox(width: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
