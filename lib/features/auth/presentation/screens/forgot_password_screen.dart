import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'reset_password_screen.dart'; 

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _otpSent = false;
  final Color primaryColor = const Color(0xFF5E9E92);

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50, height: 50,
      textStyle: GoogleFonts.cairo(fontSize: 22, color: primaryColor, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2.0, color: Colors.grey.shade400))),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.black)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text('استعادة كلمة المرور', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  labelText: 'رقم الجوال',
                  labelStyle: GoogleFonts.cairo(),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(onPressed: () => setState(() => _otpSent = true), child: Text('إرسال', style: GoogleFonts.cairo(color: primaryColor, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (_otpSent) ...[
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(length: 4, defaultPinTheme: defaultPinTheme, focusedPinTheme: defaultPinTheme.copyDecorationWith(border: Border(bottom: BorderSide(width: 2.0, color: primaryColor)))),
                ),
                const SizedBox(height: 30),
                Text('03:34', style: GoogleFonts.cairo(color: Colors.grey)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('تحقق', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}