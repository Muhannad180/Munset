import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/features/chat/presentation/screens/chat_session_page.dart';
import 'package:test1/core/theme/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sessions extends StatefulWidget {
  const Sessions({super.key});
  final Color primaryColor = const Color(0xFF5E9E92);

  @override
  State<Sessions> createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _sessionsFuture;
  late AnimationController _pulseController;

  // Session color - uses AppStyle.primary for consistency
  Color get _sessionColor => AppStyle.primary;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchSessions();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNoteDialog(context);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('sessions')
        .select()
        .eq('user_id', user.id)
        .order('session_number');

    final list = data as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  int _getCompletedCount(List<Map<String, dynamic>> sessions) {
    return sessions.where((s) => s['status'] == 'completed').length;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _sessionsFuture,
          builder: (context, snapshot) {
            final sessions = snapshot.data ?? [];
            final completedCount = _getCompletedCount(sessions);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Beautiful Header
                SliverToBoxAdapter(
                  child: _buildHeader(context, completedCount),
                ),

                // Progress Card
                SliverToBoxAdapter(
                  child: _buildProgressCard(context, completedCount, sessions),
                ),

                // Session List
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: Center(child: Text('خطأ: ${snapshot.error}')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildSessionCardForNumber(
                          context,
                          index + 1,
                          sessions,
                        );
                      }, childCount: 8),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completedCount) {
    final bool isDark = AppStyle.isDark(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1F2E2C), AppStyle.bgTop(context)]
              : [AppStyle.primary, AppStyle.primary.withOpacity(0.6)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الجلسات",
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "جلسات علاجية مخصصة لك",
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Session Icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.psychology_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    int completedCount,
    List<Map<String, dynamic>> sessions,
  ) {
    final progress = completedCount / 8;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppStyle.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Progress
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppStyle.isDark(context)
                              ? Colors.white10
                              : Colors.grey[200]!,
                        ),
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) =>
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppStyle.primary,
                              ),
                            ),
                      ),
                    ),
                    // Center text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$completedCount",
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppStyle.primary,
                          ),
                        ),
                        Text(
                          "من 8",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppStyle.textSmall(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Progress Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getProgressMessage(completedCount),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppStyle.textMain(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getProgressSubtitle(completedCount),
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppStyle.textSmall(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress dots
                    Row(
                      children: List.generate(
                        8,
                        (i) => Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 24,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i < completedCount
                                ? AppStyle.primary
                                : (AppStyle.isDark(context)
                                      ? Colors.white10
                                      : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProgressMessage(int count) {
    if (count == 0) return "ابدأ رحلتك اليوم";
    if (count < 3) return "بداية رائعة! استمر";
    if (count < 5) return "أنت في منتصف الطريق";
    if (count < 8) return "اقتربت من الهدف!";
    return "🎉 أكملت جميع الجلسات!";
  }

  String _getProgressSubtitle(int count) {
    if (count == 0) return "أكمل أول جلسة لبدء التحسن";
    if (count < 8) return "أكملت $count من 8 جلسات";
    return "أحسنت! يمكنك مراجعة الجلسات";
  }

  Widget _buildSessionCardForNumber(
    BuildContext context,
    int sessionNumber,
    List<Map<String, dynamic>> sessions,
  ) {
    final now = DateTime.now().toUtc();

    Map<String, dynamic>? currentRow;
    for (final row in sessions) {
      if (row['session_number'] == sessionNumber) {
        currentRow = row;
        break;
      }
    }

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
          unlocked = false;
        }
      }
    }

    final bool isLocked = !unlocked;
    final bool isAvailable = unlocked && !isCompleted;
    final String sessionId = currentRow?['session_id']?.toString() ?? '';

    // Calculate lock reason and unlock date
    String lockReason = "";
    DateTime? unlockDate;

    if (isLocked && sessionNumber > 1) {
      if (prevRow == null) {
        lockReason = "أكمل الجلسة ${sessionNumber - 1} أولاً";
      } else if (prevRow['status'] != 'completed') {
        lockReason = "أكمل الجلسة ${sessionNumber - 1} أولاً";
      } else if (prevRow['ended_at'] != null) {
        try {
          final endedAt = DateTime.parse(prevRow['ended_at'] as String).toUtc();
          unlockDate = endedAt.add(const Duration(days: 7));
          final daysLeft = unlockDate.difference(now).inDays;
          final hoursLeft = unlockDate.difference(now).inHours % 24;

          if (daysLeft > 0) {
            lockReason = "ستُفتح بعد $daysLeft يوم";
          } else if (hoursLeft > 0) {
            lockReason = "ستُفتح بعد $hoursLeft ساعة";
          } else {
            lockReason = "ستُفتح قريباً";
          }

          // Add the date
          final day = unlockDate.day;
          final month = _getArabicMonth(unlockDate.month);
          lockReason += " ($day $month)";
        } catch (_) {
          lockReason = "أكمل الجلسة ${sessionNumber - 1} أولاً";
        }
      }
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseScale = isAvailable
            ? 1.0 + (_pulseController.value * 0.03)
            : 1.0;

        return Transform.scale(
          scale: pulseScale,
          child: GestureDetector(
            onTap: () => _onSessionTap(
              context,
              sessionNumber,
              sessionId,
              isLocked,
              isCompleted,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: isLocked
                      ? [
                          AppStyle.isDark(context)
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100]!,
                          AppStyle.isDark(context)
                              ? Colors.white.withOpacity(0.03)
                              : Colors.grey[50]!,
                        ]
                      : [
                          _sessionColor.withOpacity(isCompleted ? 0.15 : 0.9),
                          _sessionColor.withOpacity(isCompleted ? 0.08 : 0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: isCompleted
                    ? Border.all(
                        color: _sessionColor.withOpacity(0.3),
                        width: 2,
                      )
                    : null,
                boxShadow: isLocked
                    ? []
                    : [
                        BoxShadow(
                          color: _sessionColor.withOpacity(
                            isCompleted ? 0.1 : 0.3,
                          ),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Session Number Badge
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isLocked
                            ? (AppStyle.isDark(context)
                                  ? Colors.white10
                                  : Colors.grey[200])
                            : (isCompleted
                                  ? _sessionColor.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: isLocked
                          ? Icon(
                              Icons.lock_outline,
                              color: AppStyle.isDark(context)
                                  ? Colors.white30
                                  : Colors.grey[400],
                              size: 24,
                            )
                          : isCompleted
                          ? Icon(
                              Icons.check_circle,
                              color: _sessionColor,
                              size: 28,
                            )
                          : const Icon(
                              Icons.chat_bubble_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "الجلسة $sessionNumber",
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isLocked
                                      ? (AppStyle.isDark(context)
                                            ? Colors.white38
                                            : Colors.grey)
                                      : (isCompleted
                                            ? AppStyle.textMain(context)
                                            : Colors.white),
                                ),
                              ),
                              const Spacer(),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _sessionColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "مكتملة ✓",
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _sessionColor,
                                    ),
                                  ),
                                ),
                              if (isAvailable)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "ابدأ",
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (isLocked) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: AppStyle.isDark(context)
                                      ? Colors.white24
                                      : Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    lockReason.isNotEmpty
                                        ? lockReason
                                        : "أكمل الجلسة السابقة أولاً",
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: AppStyle.isDark(context)
                                          ? Colors.white24
                                          : Colors.grey[400],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getArabicMonth(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  void _onSessionTap(
    BuildContext context,
    int sessionNumber,
    String sessionId,
    bool isLocked,
    bool isCompleted,
  ) {
    if (isLocked) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'هذه الجلسة لم تُفتح بعد. ستتوفر بعد إكمال الجلسة السابقة بأسبوع.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppStyle.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (isCompleted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لقد أكملت هذه الجلسة بالفعل ✓',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatSessionPage(
          sessionTitle: "الجلسة $sessionNumber",
          sessionId: sessionId,
          sessionNumber: sessionNumber,
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
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppStyle.cardBg(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppStyle.primary,
                      AppStyle.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "تنويه مهم",
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildNoteItem(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      text: "مٌنصت للدعم النفسي والمساندة",
                    ),
                    const SizedBox(height: 16),
                    _buildNoteItem(
                      icon: Icons.cancel_outlined,
                      iconColor: Colors.red,
                      text: "مٌنصت لا يُشخّص حالتك الطبية",
                    ),
                    const SizedBox(height: 16),
                    _buildNoteItem(
                      icon: Icons.cancel_outlined,
                      iconColor: Colors.red,
                      text: "مٌنصت ليس بديلاً عن الطبيب النفسي",
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppStyle.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "إذا كنت تمر بأزمة نفسية حادة، يرجى التواصل مع متخصص أو خط مساعدة فوراً.",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppStyle.primary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyle.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "فهمت",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppStyle.textMain(context),
            ),
          ),
        ),
      ],
    );
  }
}
