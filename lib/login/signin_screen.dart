import 'package:flutter/material.dart';
import 'package:test1/login/theme/theme.dart';
import 'package:test1/login/widgets/custom_scaffold.dart';
import 'package:test1/login/signup_screen.dart';
import 'package:test1/login/forget_password/forgot_password_screen.dart';
import 'package:test1/main_navigation.dart';
import 'package:test1/style.dart';
import 'package:test1/login/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // get auth service
  final authService = AuthService();

  // text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // login puttom pressed
  void login() async {
    // preapare data
    final email = emailController.text;
    final password = passwordController.text;

    // attemp login
    try {
      await authService.signInWithEmailPassword(email, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigation()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("البريد الإلكتروني او كلمة المرور غير صحيحة !!"),
          ),
        );
      }
    }
  }

  bool rememberPassword = true;

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
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          obscuringCharacter: '•',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            label: const Text('كلمة المرور'),
                            hintText: 'أدخل كلمة المرور',
                            hintStyle: const TextStyle(color: Colors.black26),
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
                              value: rememberPassword,
                              onChanged: (bool? value) {
                                setState(() {
                                  rememberPassword = value!;
                                });
                              },
                              activeColor: lightColorScheme.primary,
                            ),
                            const Text(
                              'تذكرني',
                              style: TextStyle(color: Colors.black45),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: login,
                            child: Text('تسجيل الدخول', style: AppStyle.button),
                            style: AppStyle.buttonStyle,
                          ),
                        ),
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ليس لديك حساب؟ ',
                              style: TextStyle(color: Colors.black45),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (e) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'إنشاء حساب',
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
