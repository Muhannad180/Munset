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

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final authService = AuthService();
  final supabase = Supabase.instance.client;
  final usernameOrEmailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  final Color primaryColor = const Color(0xFF5E9E92);

  late AnimationController _btnController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_btnController);
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  Future<void> _animateButton(VoidCallback onComplete) async {
    await _btnController.forward();
    await _btnController.reverse();
    onComplete();
  }

  bool _isEmail(String input) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);

  Future<String?> _getEmailByUsername(String username) async {
    try {
      final response = await supabase.from('users').select('email').eq('username', username).maybeSingle();
      return response?['email'] as String?;
    } catch (e) { return null; }
  }

  void login() async {
    final input = usernameOrEmailController.text.trim();
    final password = passwordController.text.trim();
    String emailToAuthenticate;

    if (input.isEmpty || password.isEmpty) { _showMsg("يرجى ملء جميع الحقول", Colors.orange); return; }

    if (_isEmail(input)) {
      emailToAuthenticate = input;
    } else {
      final foundEmail = await _getEmailByUsername(input);
      if (foundEmail == null) { _showMsg("اسم المستخدم غير موجود", Colors.red); return; }
      emailToAuthenticate = foundEmail;
    }

    try {
      final response = await authService.signInWithEmailPassword(emailToAuthenticate, password);
      if (response.user != null && mounted) {
        Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => MainNavigation(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)));
      }
    } catch (e) { _showMsg("بيانات الدخول غير صحيحة", Colors.red); }
  }

  void _showMsg(String msg, Color color) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.cairo()), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  CustomPaint(size: const Size(double.infinity, 260), painter: _HeaderPainter(color: primaryColor)),
                  Center(child: Padding(padding: const EdgeInsets.only(top: 40), child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.psychology, size: 60, color: Colors.white),
                    const SizedBox(height: 10),
                    Text('مُنصت', style: GoogleFonts.cairo(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  ]))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text('مرحباً بعودتك', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 30),
                    _buildTextField(controller: usernameOrEmailController, label: 'اسم المستخدم أو البريد', icon: Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(controller: passwordController, label: 'كلمة المرور', icon: Icons.lock_outline, isPass: true, obscure: _obscurePassword, onEyePressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                    Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())), child: Text('نسيت كلمة المرور؟', style: GoogleFonts.cairo(color: primaryColor, fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _animateButton(login),
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
                        child: Container(width: double.infinity, height: 55, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]), child: Center(child: Text('تسجيل الدخول', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)))),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('ليس لديك حساب؟ ', style: GoogleFonts.cairo(color: Colors.grey)),
                      GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())), child: Text('إنشاء حساب جديد', style: GoogleFonts.cairo(color: primaryColor, fontWeight: FontWeight.bold))),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPass = false, bool obscure = false, VoidCallback? onEyePressed}) {
    return TextField(controller: controller, obscureText: obscure, style: GoogleFonts.cairo(), decoration: InputDecoration(labelText: label, labelStyle: GoogleFonts.cairo(color: Colors.grey), prefixIcon: Icon(icon, color: primaryColor), suffixIcon: isPass ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onEyePressed) : null, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor, width: 1.5))));
  }
}

class _HeaderPainter extends CustomPainter {
  final Color color;
  _HeaderPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()..lineTo(0, size.height - 50)..quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 50)..lineTo(size.width, 0)..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}