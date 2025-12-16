import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/theme/app_style.dart';
import '../../../../data/task_library.dart';

class TaskTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggle;

  const TaskTile({super.key, required this.task, required this.onToggle});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  // ignore: unused_field
  bool _isPressed = false;
  bool _isLoadingAdvice = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchAndShowAdvice(BuildContext context) async {
    final title = TaskLibrary.getArabicTitle(widget.task);
    final description = TaskLibrary.getArabicDescription(widget.task) ?? '';

    setState(() => _isLoadingAdvice = true);

    try {
      final url = Uri.parse('https://munset-backend.onrender.com/task-advice');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'task_name': title, 'task_description': description}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final advice = data['advice'] ?? 'استمر في المحاولة!';
        _showAdviceDialog(context, title, advice);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في جلب النصيحة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingAdvice = false);
    }
  }

  void _showAdviceDialog(BuildContext context, String title, String advice) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppStyle.cardBg(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "نصيحة للمهمة",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppStyle.textMain(context),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppStyle.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppStyle.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                advice,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  height: 1.6,
                  color: AppStyle.textMain(context),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: AppStyle.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'حسناً',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppStyle.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    String title,
    String description,
  ) {
    final categoryInfo = _getCategoryInfo(widget.task);
    final List<Color> gradientColors = categoryInfo['gradient'] as List<Color>;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppStyle.cardBg(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryInfo['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppStyle.textMain(context),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "📋 تفاصيل المهمة",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: gradientColors[0],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    height: 1.7,
                    color: AppStyle.textMain(context),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: gradientColors[0].withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'حسناً',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: gradientColors[0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get category info based on task category or id
  Map<String, dynamic> _getCategoryInfo(Map<String, dynamic> task) {
    final String category = (task['category'] ?? '').toString().toLowerCase();
    final String id = (task['id'] ?? task['task_id'] ?? '')
        .toString()
        .toLowerCase();
    final String title =
        (task['title'] ?? task['task'] ?? task['task_name'] ?? '')
            .toString()
            .toLowerCase();

    // ========== BREATHING & RELAXATION ==========
    if (category.contains('relax') ||
        category.contains('grounding') ||
        id.contains('relax') ||
        id.contains('grounding') ||
        id.contains('breathing') ||
        title.contains('تنفس') ||
        title.contains('استرخاء') ||
        title.contains('تأريض') ||
        title.contains('breath') ||
        title.contains('relax') ||
        title.contains('grounding') ||
        title.contains('calm') ||
        title.contains('meditation') ||
        title.contains('mindful')) {
      return {
        'icon': Icons.air,
        'gradient': const [Color(0xFF4ECDC4), Color(0xFF2D9CDB)],
        'label': 'استرخاء',
        'labelColor': const Color(0xFF4ECDC4),
      };
    }

    // ========== THOUGHT CHALLENGES / COGNITIVE ==========
    if (category.contains('thought') ||
        category.contains('cognitive') ||
        id.contains('thought') ||
        id.contains('challenge') ||
        id.contains('cognitive') ||
        title.contains('سجل') ||
        title.contains('أفكار') ||
        title.contains('معرفي') ||
        title.contains('thought') ||
        title.contains('challenge') ||
        title.contains('replace') ||
        title.contains('cognitive') ||
        title.contains('reframe') ||
        title.contains('negative')) {
      return {
        'icon': Icons.psychology,
        'gradient': const [Color(0xFFA855F7), Color(0xFF7C3AED)],
        'label': 'معرفي',
        'labelColor': const Color(0xFFA855F7),
      };
    }

    // ========== REFLECTION & JOURNALING ==========
    if (category.contains('reflect') ||
        category.contains('journal') ||
        category.contains('record') ||
        id.contains('reflect') ||
        id.contains('journal') ||
        id.contains('gratitude') ||
        title.contains('تأمل') ||
        title.contains('يوميات') ||
        title.contains('امتنان') ||
        title.contains('reflect') ||
        title.contains('journal') ||
        title.contains('daily') ||
        title.contains('gratitude') ||
        title.contains('write') ||
        title.contains('log')) {
      return {
        'icon': Icons.auto_stories,
        'gradient': const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        'label': 'تأمل',
        'labelColor': const Color(0xFF6366F1),
      };
    }

    // ========== IDENTIFY / AWARENESS ==========
    if (id.contains('identify') ||
        id.contains('awareness') ||
        id.contains('recognize') ||
        title.contains('تعرف') ||
        title.contains('حدد') ||
        title.contains('وعي') ||
        title.contains('identify') ||
        title.contains('recognize') ||
        title.contains('spot') ||
        title.contains('notice') ||
        title.contains('awareness') ||
        title.contains('detect')) {
      return {
        'icon': Icons.search,
        'gradient': const [Color(0xFFEC4899), Color(0xFFF472B6)],
        'label': 'وعي',
        'labelColor': const Color(0xFFEC4899),
      };
    }

    // ========== BEHAVIORAL EXPERIMENT ==========
    if (category.contains('behav') ||
        category.contains('experiment') ||
        id.contains('experiment') ||
        id.contains('behavior') ||
        id.contains('action') ||
        title.contains('تجربة') ||
        title.contains('سلوك') ||
        title.contains('مواجهة') ||
        title.contains('experiment') ||
        title.contains('behavior') ||
        title.contains('try') ||
        title.contains('action') ||
        title.contains('exposure')) {
      return {
        'icon': Icons.science_outlined,
        'gradient': const [Color(0xFFF97316), Color(0xFFEAB308)],
        'label': 'سلوكي',
        'labelColor': const Color(0xFFF97316),
      };
    }

    // ========== ACTIVITY SCHEDULING ==========
    if (category.contains('activity') ||
        category.contains('scheduling') ||
        id.contains('activity') ||
        id.contains('schedule') ||
        id.contains('plan') ||
        title.contains('جدولة') ||
        title.contains('أنشطة') ||
        title.contains('خطة') ||
        title.contains('schedule') ||
        title.contains('activity') ||
        title.contains('plan') ||
        title.contains('routine') ||
        title.contains('habit')) {
      return {
        'icon': Icons.calendar_month,
        'gradient': const [Color(0xFF10B981), Color(0xFF34D399)],
        'label': 'جدولة',
        'labelColor': const Color(0xFF10B981),
      };
    }

    // ========== EXERCISE & PHYSICAL ==========
    if (id.contains('exercise') ||
        id.contains('physical') ||
        id.contains('walk') ||
        title.contains('رياضة') ||
        title.contains('تمارين') ||
        title.contains('مشي') ||
        title.contains('exercise') ||
        title.contains('walk') ||
        title.contains('physical') ||
        title.contains('movement') ||
        title.contains('stretch')) {
      return {
        'icon': Icons.directions_run,
        'gradient': const [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
        'label': 'نشاط',
        'labelColor': const Color(0xFF14B8A6),
      };
    }

    // ========== SLEEP ==========
    if (id.contains('sleep') ||
        id.contains('rest') ||
        title.contains('نوم') ||
        title.contains('راحة') ||
        title.contains('sleep') ||
        title.contains('rest') ||
        title.contains('bedtime')) {
      return {
        'icon': Icons.bedtime,
        'gradient': const [Color(0xFF6366F1), Color(0xFF818CF8)],
        'label': 'نوم',
        'labelColor': const Color(0xFF6366F1),
      };
    }

    // ========== SELF-COMPASSION ==========
    if (category.contains('compassion') ||
        category.contains('positive') ||
        category.contains('self') ||
        id.contains('compassion') ||
        id.contains('strength') ||
        id.contains('kindness') ||
        title.contains('تعاطف') ||
        title.contains('قوة') ||
        title.contains('ذات') ||
        title.contains('compassion') ||
        title.contains('kind') ||
        title.contains('strength') ||
        title.contains('self-care') ||
        title.contains('positive')) {
      return {
        'icon': Icons.favorite,
        'gradient': const [Color(0xFFF43F5E), Color(0xFFE11D48)],
        'label': 'تعاطف',
        'labelColor': const Color(0xFFF43F5E),
      };
    }

    // ========== SOCIAL / COMMUNICATION ==========
    if (id.contains('social') ||
        id.contains('communication') ||
        id.contains('connect') ||
        title.contains('اجتماعي') ||
        title.contains('تواصل') ||
        title.contains('social') ||
        title.contains('connect') ||
        title.contains('talk') ||
        title.contains('communicate') ||
        title.contains('relationship')) {
      return {
        'icon': Icons.people,
        'gradient': const [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        'label': 'اجتماعي',
        'labelColor': const Color(0xFF0EA5E9),
      };
    }

    // ========== ANGER / EMOTION MANAGEMENT ==========
    if (id.contains('anger') ||
        id.contains('emotion') ||
        id.contains('feeling') ||
        title.contains('غضب') ||
        title.contains('مشاعر') ||
        title.contains('anger') ||
        title.contains('emotion') ||
        title.contains('feeling') ||
        title.contains('mood') ||
        title.contains('frustrat')) {
      return {
        'icon': Icons.whatshot,
        'gradient': const [Color(0xFFEF4444), Color(0xFFF87171)],
        'label': 'مشاعر',
        'labelColor': const Color(0xFFEF4444),
      };
    }

    // ========== FEAR / ANXIETY ==========
    if (id.contains('fear') ||
        id.contains('anxiety') ||
        id.contains('worry') ||
        title.contains('خوف') ||
        title.contains('قلق') ||
        title.contains('fear') ||
        title.contains('anxiety') ||
        title.contains('worry') ||
        title.contains('panic') ||
        title.contains('nervous')) {
      return {
        'icon': Icons.shield,
        'gradient': const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        'label': 'مواجهة',
        'labelColor': const Color(0xFF8B5CF6),
      };
    }

    // ========== DEFAULT ==========
    return {
      'icon': Icons.task_alt,
      'gradient': const [Color(0xFF5E9E92), Color(0xFF4A8B7F)],
      'label': 'مهمة',
      'labelColor': AppStyle.primary,
    };
  }

  // Get difficulty info
  Map<String, dynamic> _getDifficultyInfo(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'low':
      case 'سهل':
        return {
          'label': 'سهل',
          'color': const Color(0xFF22C55E),
          'bgColor': const Color(0xFF22C55E).withOpacity(0.1),
        };
      case 'high':
      case 'صعب':
        return {
          'label': 'صعب',
          'color': const Color(0xFFEF4444),
          'bgColor': const Color(0xFFEF4444).withOpacity(0.1),
        };
      case 'medium':
      case 'متوسط':
      default:
        return {
          'label': 'متوسط',
          'color': const Color(0xFFF59E0B),
          'bgColor': const Color(0xFFF59E0B).withOpacity(0.1),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDone = task['is_completed'] == true;

    // Use TaskLibrary to get Arabic title and description
    final title = TaskLibrary.getArabicTitle(task);
    final description = TaskLibrary.getArabicDescription(task) ?? '';
    final difficulty = TaskLibrary.getArabicDifficulty(task);

    final categoryInfo = _getCategoryInfo(task);
    final difficultyInfo = _getDifficultyInfo(difficulty);
    final List<Color> gradientColors = categoryInfo['gradient'] as List<Color>;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onToggle();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDone
                ? (AppStyle.isDark(context)
                      ? Colors.white.withOpacity(0.03)
                      : Colors.grey[50])
                : AppStyle.cardBg(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDone
                  ? Colors.transparent
                  : gradientColors[0].withOpacity(0.2),
              width: 1,
            ),
            boxShadow: isDone
                ? []
                : [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Subtle gradient overlay on left
                if (!isDone)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: gradientColors,
                        ),
                      ),
                    ),
                  ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Category Icon Container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: isDone
                              ? null
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    gradientColors[0].withOpacity(0.15),
                                    gradientColors[1].withOpacity(0.05),
                                  ],
                                ),
                          color: isDone
                              ? (AppStyle.isDark(context)
                                    ? Colors.white10
                                    : Colors.grey[200])
                              : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          categoryInfo['icon'] as IconData,
                          color: isDone
                              ? (AppStyle.isDark(context)
                                    ? Colors.white38
                                    : Colors.grey)
                              : gradientColors[0],
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Row with Badges
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: isDone
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                      color: isDone
                                          ? (AppStyle.isDark(context)
                                                ? Colors.white38
                                                : Colors.grey)
                                          : AppStyle.textMain(context),
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: gradientColors[0],
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            // Badges Row
                            if (!isDone) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Category Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: gradientColors[0].withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      categoryInfo['label'] as String,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: gradientColors[0],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Difficulty Badge removed

                                  const Spacer(),

                                  // Details Button (if description exists)
                                  if (description.isNotEmpty) ...[
                                    GestureDetector(
                                      onTap: () => _showDetailsDialog(
                                        context,
                                        title,
                                        description,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: gradientColors[0].withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 14,
                                              color: gradientColors[0],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'تفاصيل',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: gradientColors[0],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],

                                  // Advice Button
                                  GestureDetector(
                                    onTap: _isLoadingAdvice
                                        ? null
                                        : () => _fetchAndShowAdvice(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_isLoadingAdvice)
                                            SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.amber[700],
                                              ),
                                            )
                                          else
                                            Icon(
                                              Icons.lightbulb_outline,
                                              size: 14,
                                              color: Colors.amber[700],
                                            ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'نصيحة',
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: isDone
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradientColors,
                                )
                              : null,
                          color: isDone ? null : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone
                                ? Colors.transparent
                                : gradientColors[0].withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: gradientColors[0].withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
