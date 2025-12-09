import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signin_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final supabase = Supabase.instance.client;
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  bool _obs1 = true;
  bool _obs2 = true;
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF26A69A);

  @override
  void dispose() {
    passController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final password = passController.text;
    if (password.isEmpty || password.length < 6) {
      _showMsg("يرجى اختيار كلمة مرور قوية (6 أحرف على الأقل)", Colors.orange);
      return;
    }
    if (password != confirmController.text) {
      _showMsg("كلمات المرور غير متطابقة", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final UserAttributes attrs = UserAttributes(password: password);
      await supabase.auth.updateUser(attrs);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تم تغيير كلمة المرور بنجاح",
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to SignIn and remove back stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    } catch (e) {
      _showMsg("حدث خطأ أثناء التحديث: ${e.toString()}", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'كلمة المرور الجديدة',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'قم بتعيين كلمة المرور الجديدة لحسابك',
                style: GoogleFonts.cairo(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              _field(
                passController,
                'كلمة المرور الجديدة',
                _obs1,
                () => setState(() => _obs1 = !_obs1),
              ),
              const SizedBox(height: 20),
              _field(
                confirmController,
                'تأكيد كلمة المرور',
                _obs2,
                () => setState(() => _obs2 = !_obs2),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'حفظ التغييرات',
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
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    bool obs,
    VoidCallback onEye,
  ) {
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
        controller: controller,
        obscureText: obs,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: Icon(
              obs ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onEye,
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
}
