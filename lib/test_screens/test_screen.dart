import 'package:flutter/material.dart';
import 'package:test1/test_screens/answer_button.dart';
import 'package:test1/test_screens/data/questions.dart';
// استدعاء شاشة النتائج
import '/style.dart';
import 'package:test1/main_navigation.dart';
import 'package:test1/login/auth_service.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainNavigation()),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      body: AppStyle.gradientBackground(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'في الأسبوعين الماضيين كم مرة تضايقت من الأمور التالية',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),
              Container(
                width: 360,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 138, 217, 190),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentQuestion.text,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),

              const SizedBox(height: 100),

              SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...currentQuestion.answers.map((answer) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}
