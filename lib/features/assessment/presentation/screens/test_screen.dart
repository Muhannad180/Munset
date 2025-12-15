import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/features/assessment/presentation/widgets/answer_button.dart';
import 'package:test1/features/assessment/data/questions.dart';
import 'package:test1/features/assessment/presentation/screens/results.dart';
import '../../../../core/theme/style.dart';
import 'package:test1/data/services/auth_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() {
    return _TestScreen();
  }
}

class _TestScreen extends State<TestScreen> {
  var currentQuestionIndex = 0;
  var totalScore = 0;

  void answerQuestion(String selectedAnswer) async {
    int answerScore = 0;
    if (selectedAnswer == 'أبدًا') {
      answerScore = 0;
    } else if (selectedAnswer == 'أيام قليلة') {
      answerScore = 1;
    } else if (selectedAnswer == 'نصف الأيام') {
      answerScore = 2;
    } else if (selectedAnswer == 'تقريبًا كل يوم') {
      answerScore = 3;
    }

    setState(() {
      totalScore += answerScore;
    });

    // ✅ إذا باقي أسئلة → انتقل للسؤال التالي
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // ✅ إذا انتهت كل الأسئلة
      final user = AuthService().supabase.auth.currentUser;

      if (user != null) {
        try {
          await AuthService().savePhq9Score(user.id, totalScore);
        } catch (e) {
          print("خطأ أثناء حفظ النتيجة: $e");
        }
      }

      // ✅ ننتقل بعد انتهاء الـ await مباشرة باستخدام `WidgetsBinding`
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    double progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      body: AppStyle.gradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Progress Line
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF26A69A),
                ),
                minHeight: 6,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'في الأسبوعين الماضيين كم مرة تضايقت من الأمور التالية',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      // Question Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF26A69A).withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          currentQuestion.text,
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            color: const Color(0xFF004D40),
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Answers
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...currentQuestion.answers.map((answer) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: AnswerButton(
                                  answerText: answer,
                                  onTap: () {
                                    answerQuestion(answer);
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
