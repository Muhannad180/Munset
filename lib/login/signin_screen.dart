import 'package:flutter/material.dart';
import 'package:test1/login/signup_screen.dart';
import 'package:test1/main_navigation.dart';
import 'package:test1/login/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  void login() async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      await authService.signInWithEmailPassword(email, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("البريد الإلكتروني أو كلمة المرور غير صحيحة !!"),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double topGradientHeight = 260;
    const double wavesHeight = 160;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            // الجزء العلوي
            SizedBox(
              height: topGradientHeight,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, topGradientHeight),
                    painter: _TopGradientPainter(),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'مُنصت',
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // الجزء السفلي
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // الموجات
                    Positioned(
                      top: -wavesHeight + 20,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: wavesHeight,
                        child: CustomPaint(
                          size: const Size(double.infinity, wavesHeight),
                          painter: _WavesPainter(),
                        ),
                      ),
                    ),

                    // المحتوى
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              'مرحباً بعودتك',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 26),

                            // البريد الإلكتروني
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                hintText: 'أدخل البريد الإلكتروني',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // كلمة المرور
                            TextField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                hintText: 'أدخل كلمة المرور',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 26),

                            // زر تسجيل الدخول
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF26A69A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainNavigation(),
                                  ),
                                );
                              },
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'ليس لديك حساب؟ ',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'إنشاء حساب',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h - 40);
    path.quadraticBezierTo(w * 0.5, h + 50, 0, h - 40);
    path.close();

    final Rect rect = Rect.fromLTWH(0, 0, w, h);
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF9EEBE4), // فاتح
        Color(0xFF5DD5CA), // متوسط
        Color(0xFF26A69A), // غامق
      ],
    );

    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    Paint paint1 = Paint()..color = const Color(0xFFE9E9E9);
    Path p1 = Path();
    p1.moveTo(0, h * 0.6);
    p1.quadraticBezierTo(w * 0.25, h * 0.45, w * 0.5, h * 0.6);
    p1.quadraticBezierTo(w * 0.75, h * 0.75, w, h * 0.6);
    p1.lineTo(w, h);
    p1.lineTo(0, h);
    p1.close();
    canvas.drawPath(p1, paint1);

    Paint paint2 = Paint()..color = const Color(0xFFF5F5F5);
    Path p2 = Path();
    p2.moveTo(0, h * 0.75);
    p2.quadraticBezierTo(w * 0.28, h * 0.6, w * 0.5, h * 0.75);
    p2.quadraticBezierTo(w * 0.72, h * 0.9, w, h * 0.75);
    p2.lineTo(w, h);
    p2.lineTo(0, h);
    p2.close();
    canvas.drawPath(p2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
