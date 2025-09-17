import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'reset_password_screen.dart'; // We'll create this next
import 'otp_verification_screen.dart'; // Re-using the custom button from here

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 2.0, color: Colors.grey.shade400)),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF004D40)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text( // Replace with your logo
              'منصت',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Color(0xFF004D40),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'إعادة تعيين كلمة المرور',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            const SizedBox(height: 40),
            TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                labelStyle: const TextStyle(color: Color(0xFF00796B)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _otpSent = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7EC9C2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('إرسال الرمز'),
                  ),
                ),
                suffixIcon: const Icon(Icons.check_circle, color: Color(0xFF00796B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 60),
            if (_otpSent) ...[
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: const Border(bottom: BorderSide(width: 2.0, color: Color(0xFF00796B))),
                    ),
                  ),
                  separatorBuilder: (index) => const SizedBox(width: 20),
                ),
              ),
              const SizedBox(height: 30),
              const Text('03:34', style: TextStyle(fontSize: 16, color: Color(0xFF00796B))),
              const SizedBox(height: 50),
              CustomGradientButton(
                text: 'تحقق',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}