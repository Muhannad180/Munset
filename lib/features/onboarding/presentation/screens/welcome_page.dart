import 'package:flutter/material.dart';
import 'package:test1/features/auth/presentation/screens/signin_screen.dart';
import '../../../../core/theme/style.dart';

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
              children: [
                const SizedBox(height: 80),
                Image.asset('assets/images/munset_logo.png'),
                const SizedBox(height: 100),

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
                      MaterialPageRoute(builder: (context) => SignInScreen()),
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
