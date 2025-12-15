import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/features/assessment/presentation/screens/test_screen.dart';
import '../../../../core/theme/style.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppStyle.gradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1), // Light Teal
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      'في البداية اريد منك الإجابة على 9 اسئلة، اختبر بها حالتك النفسية.\nرجاءً خذ وقتك ولا تتعجل في الإجابة...',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        color: const Color(0xFF00796B), // Darker Teal
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Warning Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            textDirection: TextDirection.rtl,
                            text: TextSpan(
                              style: GoogleFonts.cairo(
                                color: Colors.grey[800],
                                fontSize: 16,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'تنبيه: ',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      'هذا الاختبار (PHQ-9) يعطي نبذة عن حالتك الصحية ولا يعد وسيلة تشخيص دقيقة، لابد من الرجوع للطبيب النفسي لتشخيصك !!',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TestScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26A69A),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      label: Text(
                        'الموافقة والبدء',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Skip Button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
