import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/features/auth/presentation/screens/signin_screen.dart';
import 'package:test1/data/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool agreeData = true;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? selectedAge;
  String? selectedGender;
  final List<String> ages = [for (int i = 12; i <= 60; i++) i.toString()];

  final Color primaryColor = const Color(0xFF26A69A);

  void signUp() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedAge == null ||
        selectedGender == null) {
      _showMsg("يرجى تعبئة كافة الحقول", Colors.orange);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showMsg("كلمات المرور غير متطابقة", Colors.orange);
      return;
    }

    try {
      final existing = await supabase
          .from('users')
          .select()
          .eq('username', usernameController.text)
          .maybeSingle();
      if (existing != null) {
        _showMsg("اسم المستخدم مستخدم مسبقاً", Colors.orange);
        return;
      }

      final res = await authService.signUpWithEmailPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      if (res.user != null) {
        // Wait a bit for the trigger to create the base user record
        await Future.delayed(const Duration(milliseconds: 1000));

        // Update user profile with additional fields (trigger already created the record)
        await supabase
            .from('users')
            .update({
              "first_name": firstNameController.text.trim(),
              "last_name": lastNameController.text.trim(),
              "username": usernameController.text.trim(),
              "age": int.parse(selectedAge!),
              "gender": selectedGender!,
            })
            .eq('id', res.user!.id);

        if (mounted) {
          _showMsg("تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول", Colors.green);
          // الانتقال إلى صفحة تسجيل الدخول
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          );
        }
      }
    } catch (e, s) {
      _showMsg("حدث خطأ أثناء التسجيل", Colors.red);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo()),
        backgroundColor: color,
      ),
    );
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
            // Header
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
                        'حساب جديد',
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

            // Content
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
                    // Waves
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

                    // Form
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _field(
                                    firstNameController,
                                    'الاسم الأول',
                                    Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _field(
                                    lastNameController,
                                    'الاسم يالأخير',
                                    Icons.person_outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _field(
                              usernameController,
                              'اسم المستخدم',
                              Icons.alternate_email,
                            ),
                            const SizedBox(height: 15),

                            // Age and Gender
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
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
                                    child: DropdownButtonFormField<String>(
                                      value: selectedAge,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: primaryColor,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'العمر',
                                        labelStyle: GoogleFonts.cairo(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.calendar_today_outlined,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                      ),
                                      items: ages
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: GoogleFonts.cairo(),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => selectedAge = v),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 55,
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _radioOpt('ذكر'),
                                        _radioOpt('أنثى'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _field(
                              emailController,
                              'البريد الإلكتروني',
                              Icons.email_outlined,
                              type: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 15),
                            _field(
                              passwordController,
                              'كلمة المرور',
                              Icons.lock_outline,
                              isPass: true,
                              obscure: _obscurePass,
                              onEye: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                            const SizedBox(height: 15),
                            _field(
                              confirmPasswordController,
                              'تأكيد كلمة المرور',
                              Icons.lock_outline,
                              isPass: true,
                              obscure: _obscureConfirm,
                              onEye: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),

                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Checkbox(
                                  value: agreeData,
                                  activeColor: primaryColor,
                                  onChanged: (v) =>
                                      setState(() => agreeData = v!),
                                ),
                                Text(
                                  'أوافق على الشروط والأحكام',
                                  style: GoogleFonts.cairo(fontSize: 12),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: agreeData ? signUp : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  elevation: 5,
                                  shadowColor: primaryColor.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'إنشاء حساب',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '  لديك حساب؟ ',
                                  style: GoogleFonts.cairo(
                                    color: primaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignInScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'سجل دخول',
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

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool isPass = false,
    bool obscure = false,
    VoidCallback? onEye,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
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
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: primaryColor),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onEye,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _radioOpt(String val) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = val),
      child: Row(
        children: [
          Icon(
            selectedGender == val
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            color: selectedGender == val ? primaryColor : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(val, style: GoogleFonts.cairo(fontSize: 14)),
        ],
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
