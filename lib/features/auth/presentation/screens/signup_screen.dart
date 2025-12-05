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
  
  final Color primaryColor = const Color(0xFF5E9E92);

  void signUp() async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty || usernameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || selectedAge == null || selectedGender == null) {
      _showMsg("يرجى تعبئة كافة الحقول", Colors.orange);
      return;
    }
    if (passwordController.text != confirmPasswordController.text){
      _showMsg("كلمات المرور غير متطابقة", Colors.orange);
      return;
    }

    try {
      final existing = await supabase.from('users').select().eq('username', usernameController.text).maybeSingle();
      if (existing != null) { _showMsg("اسم المستخدم مستخدم مسبقاً", Colors.orange); return; }

      final res = await authService.signUpWithEmailPassword(emailController.text.trim(), passwordController.text);
      if (res.user != null) {
        await supabase.from('users').insert({
          "id": res.user!.id,
          "first_name": firstNameController.text.trim(),
          "last_name": lastNameController.text.trim(),
          "username": usernameController.text.trim(),
          "age": int.parse(selectedAge!),
          "gender": selectedGender!,
          "email": emailController.text.trim(),
        });
        if(mounted) {
          _showMsg("تم إنشاء الحساب بنجاح", Colors.green);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
        }
      }
    } catch (e) {
      _showMsg("حدث خطأ أثناء التسجيل", Colors.red);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.cairo()), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // الهيدر
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Center(child: Padding(padding: const EdgeInsets.only(top: 30), child: Text('حساب جديد', style: GoogleFonts.cairo(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)))),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(child: _field(firstNameController, 'الاسم الأول')),
                      const SizedBox(width: 10),
                      Expanded(child: _field(lastNameController, 'الاسم الأخير')),
                    ]),
                    const SizedBox(height: 15),
                    _field(usernameController, 'اسم المستخدم'),
                    const SizedBox(height: 15),
                    
                    // العمر والجنس
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedAge,
                            decoration: _inputDecor('العمر'),
                            items: ages.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.cairo()))).toList(),
                            onChanged: (v) => setState(() => selectedAge = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    _field(emailController, 'البريد الإلكتروني', type: TextInputType.emailAddress),
                    const SizedBox(height: 15),
                    _field(passwordController, 'كلمة المرور', isPass: true, obscure: _obscurePass, onEye: () => setState(() => _obscurePass = !_obscurePass)),
                    const SizedBox(height: 15),
                    _field(confirmPasswordController, 'تأكيد كلمة المرور', isPass: true, obscure: _obscureConfirm, onEye: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                    
                    const SizedBox(height: 20),
                    Row(children: [
                      Checkbox(value: agreeData, activeColor: primaryColor, onChanged: (v) => setState(() => agreeData = v!)),
                      Text('أوافق على الشروط والأحكام', style: GoogleFonts.cairo(fontSize: 12)),
                    ]),
                    
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: agreeData ? signUp : null,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('إنشاء حساب', style: GoogleFonts.cairo(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('لديك حساب؟ ', style: GoogleFonts.cairo(color: Colors.grey)),
                      GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen())), child: Text('سجل دخول', style: GoogleFonts.cairo(color: primaryColor, fontWeight: FontWeight.bold))),
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

  Widget _field(TextEditingController c, String label, {bool isPass = false, bool obscure = false, VoidCallback? onEye, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: c, obscureText: obscure, keyboardType: type, style: GoogleFonts.cairo(),
      decoration: _inputDecor(label).copyWith(
        suffixIcon: isPass ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onEye) : null,
      ),
    );
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label, labelStyle: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor)),
    );
  }

  Widget _radioOpt(String val) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = val),
      child: Row(children: [
        Icon(selectedGender == val ? Icons.radio_button_checked : Icons.radio_button_off, color: selectedGender == val ? primaryColor : Colors.grey, size: 18),
        const SizedBox(width: 4),
        Text(val, style: GoogleFonts.cairo(fontSize: 14)),
      ]),
    );
  }
}