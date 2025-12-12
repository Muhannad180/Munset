import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/style.dart';
import 'package:test1/shared/navigation/main_navigation.dart';
import 'package:test1/data/services/auth_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    this.showBackButton = true,
    this.onRetakeTest,
  });

  final bool showBackButton;
  final VoidCallback? onRetakeTest;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final supabase = Supabase.instance.client;
  final authService = AuthService();

  int? score;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    try {
      final userId = authService.getCurrentUserId();
      if (userId == null) {
        setState(() {
          errorMessage = 'لم يتم العثور على المستخدم';
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('users')
          .select('phq9_score')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          score = response['phq9_score'] as int?;
          isLoading = false;

          if (score == null) {
            errorMessage = 'لم يتم العثور على نتيجة الاختبار';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'حدث خطأ أثناء تحميل النتيجة';
          isLoading = false;
        });
      }
      debugPrint('Error loading PHQ-9 score: $e');
    }
  }

  String getResultMessage() {
    final s = score ?? 0;
    if (s <= 4) {
      return "لا يوجد حد أدنى";
    } else if (s <= 9) {
      return "خفيف";
    } else if (s <= 14) {
      return "متوسط";
    } else if (s <= 19) {
      return "متوسطة الشدة";
    } else {
      return "شديد";
    }
  }

  Color getResultColor() {
    final s = score ?? 0;
    if (s <= 4) {
      return const Color(0xFF4CAF50); // Green
    } else if (s <= 9) {
      return const Color(0xFF8BC34A); // Light Green
    } else if (s <= 14) {
      return const Color(0xFFFFC107); // Amber
    } else if (s <= 19) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  String getRecommendation() {
    final s = score ?? 0;
    if (s <= 4) {
      return "لا أحد";
    } else if (s <= 9) {
      return "المراقبة الذاتية؛ إعادة استخدام مقياس PHQ-9 في المتابعة";
    } else if (s <= 14) {
      return "خطة العلاج، مع الأخذ في الاعتبار الاستشارة والمتابعة و/أو العلاج الدوائي";
    } else if (s <= 19) {
      return "العلاج الفعال بالعلاج النفسي و/أو العلاج النفسي";
    } else {
      return "الفور بالعلاج الدوائي، وفي حالة وجود خطر إيذاء أو اضطراب في الأداء الوظيفية، الإحالة إلى أخصائي الصحة النفسية للعلاج النفسي و/أو الإدارة الدوائية";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading) {
      final loadingContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF26A69A)),
            const SizedBox(height: 20),
            Text(
              'جاري تحميل النتيجة...',
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: const Color(0xFF004D40),
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      );

      return Scaffold(
        body: AppStyle.gradientBackground(
          child: SafeArea(child: loadingContent),
        ),
      );
    }

    // Show error state
    if (errorMessage != null) {
      final errorContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFF44336),
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage!,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: const Color(0xFF004D40),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'رجوع',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      );

      return Scaffold(
        body: AppStyle.gradientBackground(child: SafeArea(child: errorContent)),
      );
    }

    final resultColor = getResultColor();
    final s = score ?? 0;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            'النتيجة',
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF004D40),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(height: 30),

          // Score Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [resultColor.withOpacity(0.8), resultColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: resultColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'نتيجتك',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                Text(
                  '$s',
                  style: GoogleFonts.cairo(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getResultMessage(),
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF455A64),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'التشخيص المبدئي والإجراءات العلاجية المقترحة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),

          // Table Content
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Table Header Row
                _buildTableHeaderRow(),

                // Table Rows
                _buildTableRow(
                  '0 - 4',
                  'لا يوجد حد أدنى',
                  'لا أحد',
                  s >= 0 && s <= 4,
                ),
                _buildTableRow(
                  '5 - 9',
                  'خفيف',
                  'المراقبة الذاتية؛ إعادة استخدام مقياس PHQ-9 في المتابعة',
                  s >= 5 && s <= 9,
                ),
                _buildTableRow(
                  '10 - 14',
                  'متوسط',
                  'خطة العلاج، مع الأخذ في الاعتبار الاستشارة والمتابعة و/أو العلاج الدوائي',
                  s >= 10 && s <= 14,
                ),
                _buildTableRow(
                  '15 - 19',
                  'متوسطة الشدة',
                  'العلاج الفعال بالعلاج النفسي و/أو العلاج النفسي',
                  s >= 15 && s <= 19,
                ),
                _buildTableRow(
                  '20 - 27',
                  'شديد',
                  'الفور بالعلاج الدوائي، وفي حالة وجود خطر إيذاء أو اضطراب في الأداء الوظيفية، الإحالة إلى أخصائي الصحة النفسية للعلاج النفسي و/أو الإدارة الدوائية',
                  s >= 20 && s <= 27,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Action Buttons
          if (widget.onRetakeTest != null)
            // Retake Test Button (when embedded in tab)
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF26A69A), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF26A69A).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onRetakeTest,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'إعادة الاختبار',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (widget.showBackButton)
            // Home Button (when standalone screen)
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF26A69A), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF26A69A).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainNavigation(),
                      ),
                      (route) => false,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'العودة إلى الصفحة الرئيسية',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );

    // If showBackButton is true, wrap in Scaffold with gradient background
    // Otherwise, just return the content (for embedding)
    if (widget.showBackButton) {
      return Scaffold(
        body: AppStyle.gradientBackground(child: SafeArea(child: content)),
      );
    } else {
      return content;
    }
  }

  Widget _buildTableHeaderRow() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFECEFF1),
        border: Border(bottom: BorderSide(color: Color(0xFFCFD8DC), width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFCFD8DC), width: 1),
                  ),
                ),
                child: Text(
                  'نتيجة مقياس PHQ-9',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF37474F),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFCFD8DC), width: 1),
                  ),
                ),
                child: Text(
                  'شدة الاكتئاب',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF37474F),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'إجراءات العلاج المقترحة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF37474F),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String scoreRange,
    String severity,
    String treatment,
    bool isHighlighted, {
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? getResultColor().withOpacity(0.1) : Colors.white,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFECEFF1), width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: const Border(
                    left: BorderSide(color: Color(0xFFECEFF1), width: 1),
                  ),
                  color: isHighlighted
                      ? getResultColor().withOpacity(0.15)
                      : const Color(0xFFFAFAFA),
                ),
                child: Text(
                  scoreRange,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: isHighlighted
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: isHighlighted
                        ? getResultColor()
                        : const Color(0xFF546E7A),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFECEFF1), width: 1),
                  ),
                ),
                child: Text(
                  severity,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: isHighlighted
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isHighlighted
                        ? getResultColor()
                        : const Color(0xFF607D8B),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  treatment,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: isHighlighted
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isHighlighted
                        ? const Color(0xFF37474F)
                        : const Color(0xFF78909C),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
