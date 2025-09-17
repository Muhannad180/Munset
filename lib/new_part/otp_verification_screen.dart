import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

// A reusable gradient button that matches the design
class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5A9C96).withOpacity(0.8),
            const Color(0xFF7EC9C2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// The main screen widget
class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

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
      backgroundColor: const Color(0xFFE0F2F1), // Light mint green background
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
            // IMPORTANT: Replace this with your actual logo widget
            child: Text(
              'منصت',
              style: TextStyle(
                fontFamily: 'Tajawal', // Make sure you have this font
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
            const SizedBox(height: 80),
            const Text(
              'رمز التحقق',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'تم إرسال رمز التحقق الى جوال رقم 05xxxx5297',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF00796B),
              ),
            ),
            const SizedBox(height: 60),
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
            const Text(
              '03:34',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF00796B),
              ),
            ),
            const SizedBox(height: 50),
            CustomGradientButton(
              text: 'استمرار',
              onPressed: () {
                // Placeholder navigation
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}