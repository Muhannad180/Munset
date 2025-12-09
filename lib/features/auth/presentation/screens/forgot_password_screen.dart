import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF26A69A);

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showMsg("يرجى إدخال البريد الإلكتروني", Colors.orange);
      return;
    }
    setState(() => _isLoading = true);

    // Check if email exists in users table
    try {
      final userData = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (userData == null) {
        setState(() => _isLoading = false);
        _showMsg("البريد الإلكتروني غير مسجل", Colors.red);
        return;
      }

      await supabase.auth.resetPasswordForEmail(email);
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      _showMsg("تم إرسال رمز التحقق إلى بريدك الإلكتروني", Colors.green);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMsg("حدث خطأ أثناء الإرسال. تأكد من البريد الإلكتروني", Colors.red);
    }
  }

  Future<void> _verifyCode() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    if (otp.length < 6) {
      _showMsg("يرجى إدخال الرمز كاملاً", Colors.orange);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );
      setState(() => _isLoading = false);
      if (res.session != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        );
      } else {
        _showMsg("رمز التحقق غير صحيح", Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMsg("رمز التحقق غير صحيح أو انتهت صلاحيته", Colors.red);
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
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: GoogleFonts.cairo(
        fontSize: 22,
        color: primaryColor,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.transparent),
      ),
    );

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
              const SizedBox(height: 20),
              Text(
                'استعادة كلمة المرور',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'أدخل بريدك الإلكتروني لاستقبال رمز إعادة التعيين',
                style: GoogleFonts.cairo(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
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
                  controller: emailController,
                  enabled: !_otpSent,
                  style: GoogleFonts.cairo(),
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    labelStyle: GoogleFonts.cairo(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                    suffixIcon: !_otpSent
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )
                                : TextButton(
                                    onPressed: _sendCode,
                                    child: Text(
                                      'إرسال',
                                      style: GoogleFonts.cairo(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          )
                        : Icon(Icons.check_circle, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (_otpSent) ...[
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    controller: otpController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyDecorationWith(
                      border: Border.all(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
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
                            'تحقق',
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
                      'لم يصلك الرمز؟ ',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _sendCode,
                      child: Text(
                        'إعادة إرسال',
                        style: GoogleFonts.cairo(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'يرجى التحقق من مجلد الرسائل غير المرغوب فيها (Spam)',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
