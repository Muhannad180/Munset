import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/login/signin_screen.dart';
import 'package:test1/login/auth_service.dart';
import 'package:test1/main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final authService = AuthService();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool agreePersonalData = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? selectedAge;
  String? selectedGender;
  final List<String> ages = [for (int i = 12; i <= 60; i++) i.toString()];

  void signUp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // التحقق من جميع الحقول
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        selectedAge == null ||
        selectedGender == null ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى ملئ جميع الحقول")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("كلمة المرور غير متطابقة")));
      return;
    }

    try {
      // إنشاء حساب في Auth
      final response = await authService.signUpWithEmailPassword(
        email,
        password,
      );

      // التحقق من نجاح إنشاء الحساب والحصول على user id
      if (response.user != null) {
        final userId = response.user!.id;

        // حفظ بيانات المستخدم في جدول user
        await supabase.from('users').insert({
          "id": userId,
          "first_name": firstName,
          "last_name": lastName,
          "age": int.parse(selectedAge!),
          "gender": selectedGender!,
          "email": email,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم إنشاء الحساب بنجاح")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("حدث خطأ: ${e.toString()}")));
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double topGradientHeight = 200;
    const double wavesHeight = 160;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Column(
          children: [
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
                        style: const TextStyle(
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              'إنشاء حساب جديد',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ====== الاسم ======
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'الاسم',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // الاسم الأول والاسم الأخير جنب بعض
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: firstNameController,
                                    decoration: InputDecoration(
                                      labelText: 'الاسم الأول',
                                      hintText: 'أدخل اسمك الأول',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: lastNameController,
                                    decoration: InputDecoration(
                                      labelText: 'الاسم الأخير',
                                      hintText: 'أدخل اسمك الأخير',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ====== العمر والجنس ======
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'العمر',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    initialValue: selectedAge,
                                    items: ages
                                        .map(
                                          (age) => DropdownMenuItem(
                                            value: age,
                                            child: Text(age),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAge = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'الجنس',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RadioListTile<String>(
                                              title: const Text('ذكر'),
                                              value: 'ذكر',
                                              groupValue: selectedGender,
                                              contentPadding: EdgeInsets.zero,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedGender = value;
                                                });
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: RadioListTile<String>(
                                              title: const Text('أنثى'),
                                              value: 'أنثى',
                                              groupValue: selectedGender,
                                              contentPadding: EdgeInsets.zero,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedGender = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // البريد الإلكتروني
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                hintText: 'أدخل البريد الإلكتروني',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // كلمة المرور
                            TextField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                hintText: 'أدخل كلمة المرور',
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
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // تأكيد كلمة المرور
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                labelText: 'التحقق من كلمة المرور',
                                hintText: 'تكرار كلمة المرور',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Checkbox(
                                  value: agreePersonalData,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      agreePersonalData = value ?? true;
                                    });
                                  },
                                  activeColor: const Color.fromARGB(
                                    255,
                                    68,
                                    138,
                                    255,
                                  ),
                                ),
                                const Text(
                                  'أوافق على معالجة ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const Text(
                                  'البيانات الشخصية',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF26A69A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'إنشاء حساب',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'لديك حساب بالفعل؟ ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'تسجيل الدخول',
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

/* ======= Painters للتماثل مع صفحة الدخول ======= */

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
      colors: const [Color(0xFF9EEBE4), Color(0xFF5DD5CA), Color(0xFF26A69A)],
      stops: const [0.0, 0.5, 1.0],
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
