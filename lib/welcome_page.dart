import 'package:flutter/material.dart';
import 'package:test1/test_screens/start_screen.dart';
import 'style.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppStyle.gradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مرحباً',
                  style: AppStyle.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'أنا منصت إلى جميع ما ستخبرني به وسأكون بجانبك طوال اليوم...',
                  style: AppStyle.body,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => StartScreen()),
                    );
                  },
                  child: Text('ابدأ', style: AppStyle.button),
                  style: AppStyle.buttonStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
