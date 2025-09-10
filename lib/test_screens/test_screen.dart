import 'package:flutter/material.dart';
import 'package:test1/test_screens/answer_button.dart';
import 'package:test1/test_screens/data/questions.dart';
import 'package:test1/test_screens/results.dart'; // استدعاء شاشة النتائج
import '/style.dart';

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

  void answerQuestion(String selectedAnswer) {
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

      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(score: totalScore),
          ),
        );
      }
    });
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
