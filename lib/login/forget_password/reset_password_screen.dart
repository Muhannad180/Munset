import 'package:flutter/material.dart';
import 'otp_verification_screen.dart'; // Re-using the custom button

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              // Replace with your logo
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
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
              ),
            ),
            const SizedBox(height: 60),
            TextField(
              obscureText: _isObscure1,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                labelStyle: const TextStyle(color: Color(0xFF00796B)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure1 ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isObscure1 = !_isObscure1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: _isObscure2,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                labelStyle: const TextStyle(color: Color(0xFF00796B)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure2 ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isObscure2 = !_isObscure2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 80),
            CustomGradientButton(
              text: 'تغيير كلمة المرور',
              onPressed: () {
                // For now, just pop back to the previous screen
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
