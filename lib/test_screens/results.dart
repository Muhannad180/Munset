import 'package:flutter/material.dart';
import '/style.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.score});

  final int score;

  String getResultMessage() {
    if (score <= 4) {
      return "حالتك طبيعية تقريبًا";
    } else if (score <= 9) {
      return "اكتئاب بسيط";
    } else if (score <= 14) {
      return "اكتئاب متوسط";
    } else if (score <= 19) {
      return "اكتئاب متوسط إلى شديد";
    } else {
      return "اكتئاب شديد";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppStyle.gradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'مجموع نقاطك: $score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                getResultMessage(),
                style: const TextStyle(fontSize: 20, color: Colors.red),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
