import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/features/auth/presentation/screens/signup_screen.dart';
import 'package:test1/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:test1/shared/navigation/main_navigation.dart';
import 'package:test1/data/services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;
  final usernameOrEmailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Define primary color here as requested
  final Color primaryColor = const Color(0xFF26A69A);

  bool _isEmail(String input) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);

  Future<String?> _getEmailByUsername(String username) async {
    try {
      final response = await supabase
          .from('users')
          .select('email')
          .eq('username', username)
          .maybeSingle();
      return response?['email'] as String?;
    } catch (e) {
      return null;
    }
  }

  void login() async {
    final input = usernameOrEmailController.text.trim();
    final password = passwordController.text.trim();
    String emailToAuthenticate;

    if (input.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("يرجى ملء جميع الحقول", style: GoogleFonts.cairo()),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_isEmail(input)) {
      emailToAuthenticate = input;
    } else {
      final foundEmail = await _getEmailByUsername(input);
      if (foundEmail == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "اسم المستخدم غير موجود",
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      emailToAuthenticate = foundEmail;
    }

    try {
      await authService.signInWithEmailPassword(emailToAuthenticate, password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "البريد الإلكتروني أو كلمة المرور غير صحيحة !!",
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    usernameOrEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double topGradientHeight = 220;
    const double wavesHeight = 160;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
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
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Text(
                        'مُنصت',
                        style: GoogleFonts.cairo(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    'مرحباً بعودتك',
                                    style: GoogleFonts.cairo(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'يرجى تسجيل الدخول للمتابعة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 26),

                                  // البريد الإلكتروني (أو اسم المستخدم)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: usernameOrEmailController,
                                      style: GoogleFonts.cairo(),
                                      decoration: InputDecoration(
                                        hintText: 'اسم المستخدم أو البريد',
                                        hintStyle: GoogleFonts.cairo(
                                          color: Colors.grey[400],
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: primaryColor,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // كلمة المرور
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: _obscurePassword,
                                      style: GoogleFonts.cairo(),
                                      decoration: InputDecoration(
                                        hintText: 'كلمة المرور',
                                        hintStyle: GoogleFonts.cairo(
                                          color: Colors.grey[400],
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: primaryColor,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'نسيت كلمة المرور؟',
                                        style: GoogleFonts.cairo(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // زر تسجيل الدخول
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        elevation: 5,
                                        shadowColor: primaryColor.withOpacity(
                                          0.4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'تسجيل الدخول',
                                        style: GoogleFonts.cairo(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ليس لديك حساب؟ ',
                                style: GoogleFonts.cairo(
                                  color: primaryColor,
                                  fontSize: 14,
                                ),
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
                                child: Text(
                                  'إنشاء حساب',
                                  style: GoogleFonts.cairo(
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
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF80CBC4), Color(0xFF4DB6AC), Color(0xFF26A69A)],
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
