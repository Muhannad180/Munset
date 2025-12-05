import 'package:flutter/material.dart';
import 'package:test1/features/auth/presentation/screens/signin_screen.dart';
import '../../../../core/theme/style.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _btnController;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(_btnController);
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  void _onStartPressed() async {
    await _btnController.forward();
    await _btnController.reverse();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignInScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

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
                Text('مرحباً', style: AppStyle.heading, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Text('أنا منصت إلى جميع ما ستخبرني به وسأكون بجانبك طوال اليوم...', style: AppStyle.body, textAlign: TextAlign.center, textDirection: TextDirection.rtl),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _onStartPressed,
                  child: AnimatedBuilder(
                    animation: _btnScale,
                    builder: (context, child) => Transform.scale(scale: _btnScale.value, child: child),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFF5E9E92), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))]),
                      child: Text('ابدأ', style: AppStyle.button),
                    ),
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