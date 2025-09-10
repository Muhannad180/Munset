import 'package:flutter/material.dart';
import 'package:test1/login/signin_screen.dart';
import 'package:test1/login/theme/theme.dart';
import 'package:test1/login/widgets/custom_scaffold.dart';
import 'package:test1/style.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

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
                padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formSignupKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 40.0),

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
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25.0),

                        TextFormField(
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
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25.0),

                        TextFormField(
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
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25.0),

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

                        const SizedBox(height: 25.0),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formSignupKey.currentState!.validate() &&
                                  agreePersonalData) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم إنشاء الحساب بنجاح'),
                                  ),
                                );
                              } else if (!agreePersonalData) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'الرجاء الموافقة على معالجة البيانات الشخصية',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('إنشاء حساب', style: AppStyle.button),
                            style: AppStyle.buttonStyle,
                          ),
                        ),

                        const SizedBox(height: 30.0),

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
                                    builder: (e) => const LogInScreen(),
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
