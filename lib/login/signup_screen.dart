import 'package:flutter/material.dart';
import 'package:test1/login/signin_screen.dart';
import 'package:test1/login/theme/theme.dart';
import 'package:test1/login/widgets/custom_scaffold.dart';
import 'package:test1/main_navigation.dart';
import 'package:test1/style.dart';
import 'package:test1/login/auth_service.dart';

// Register page

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // get auth service
  final authService = AuthService();

  // text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreePersonalData = true;

  // sign up buttom pressed
  void signUp() async {
    // prepare data
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // check that passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("كلمة المرور غير متطابقة")));
      return;
    }

    // attemt sign up
    try {
      await authService.signUpWithEmailPassword(email, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("حدث خطأ : $e")));
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScaffold(
        child: Column(
          children: [
            const Expanded(flex: 1, child: SizedBox(height: 10)),
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الاسم الكامل';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('الاسم كامل'),
                            hintText: 'أدخل الاسم الكامل',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('البريد الإلكتروني'),
                            hintText: 'أدخل البريد الإلكتروني',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          obscuringCharacter: '•',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'إدخال كلمة المرور';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.visibility),
                            ),
                            label: const Text('كلمة المرور'),
                            hintText: 'أدخل كلمة المرور',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          obscuringCharacter: '•',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'تكرار إدخال كلمة المرور';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.visibility),
                            ),
                            label: const Text('التحقق من كلمة المرور'),
                            hintText: 'تكرار أدخل كلمة المرور',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Checkbox(
                              value: agreePersonalData,
                              onChanged: (bool? value) {
                                setState(() {
                                  agreePersonalData = value!;
                                });
                              },
                              activeColor: lightColorScheme.primary,
                            ),
                            const Text(
                              'أوافق على معالجة ',
                              style: TextStyle(color: Colors.black45),
                            ),
                            Text(
                              'البيانات الشخصية',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: signUp,
                            child: Text('إنشاء حساب', style: AppStyle.button),
                            style: AppStyle.buttonStyle,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'لديك حساب بالفعل؟ ',
                              style: TextStyle(color: Colors.black45),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const SignInScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: lightColorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
