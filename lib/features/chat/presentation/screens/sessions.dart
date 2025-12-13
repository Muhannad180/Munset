import 'package:flutter/material.dart';
import 'package:test1/features/chat/presentation/screens/chat_session_page.dart';
import 'dart:io';
import 'package:test1/features/home/presentation/screens/home.dart';
import 'package:test1/core/theme/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sessions extends StatefulWidget {
  const Sessions({super.key});
  final Color primaryColor = const Color(0xFF5E9E92);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNoteDialog(context);
    });
  }

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    // New Supabase API: no `.execute()`, awaiting the query returns a List
    final data = await supabase
        .from('sessions')
        .select()
        .eq('user_id', user.id)
        .order('session_number');

    if (data == null) return [];

    final list = data as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

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
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: AppStyle.isDark(context)
                            ? [const Color(0xFF1F2E2C), AppStyle.bgTop(context)]
                            : [
                                AppStyle.primary,
                                AppStyle.primary.withOpacity(0.6),
                              ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    child: Column(
                      children: [
                        const Text(
                          "الجلسات",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "جلسات علاجية مخصصة لك",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
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
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF8FD3C7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.campaign_outlined,
                          size: 40,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "تنويه!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "لا تسيء فهم التطبيق",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Side (Wrong Idea)
                          Expanded(
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      size: 50,
                                      color: Colors.orangeAccent,
                                    ),
                                    const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "فكرة خاطئة",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "مٌنصت يشخص حالتي",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "مُنصت بديل للطبيب النفسي",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          const VerticalDivider(
                            width: 20,
                            thickness: 1,
                            color: Colors.grey,
                          ),

                          // Right Side (Right Idea)
                          Expanded(
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    const Icon(
                                      Icons.lightbulb,
                                      size: 50,
                                      color: Colors.orangeAccent,
                                    ),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "الفكرة الصحيحة",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "مٌنصت لا يشخص حالتك",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "مٌنصت ليس طبيباً نفسياً، ولا يحل محل الطبيب النفسي.",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "مٌنصت هو تطبيق للدعم النفسي يتيح لك التحدث باريحيه مع ذكاء اصطناعي يمكنه المساعدة.",
                      style: TextStyle(
                        color: Color(0xFF00C853),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          final endedAt = DateTime.parse(prevRow['ended_at'] as String).toUtc();
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
          colors: [Color(0xFF8FD3C7), Color.fromARGB(255, 105, 147, 139)],
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
                color:
                    (iconBackgroundColor ??
                            const Color.fromARGB(255, 105, 147, 139))
                        .withOpacity(isLocked ? 0.6 : 1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon!, color: iconColor ?? Colors.white, size: 26),
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
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right-edge chip button only for "create new" sessions
          if (isCreateNew && buttonText != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  const Icon(Icons.add, color: Colors.white, size: 18),
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
