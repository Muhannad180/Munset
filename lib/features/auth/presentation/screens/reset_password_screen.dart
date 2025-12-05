import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obs1 = true;
  bool _obs2 = true;
  final Color primaryColor = const Color(0xFF5E9E92);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.black)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text('كلمة المرور الجديدة', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 40),
              _field('كلمة المرور الجديدة', _obs1, () => setState(() => _obs1 = !_obs1)),
              const SizedBox(height: 20),
              _field('تأكيد كلمة المرور', _obs2, () => setState(() => _obs2 = !_obs2)),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('حفظ التغييرات', style: GoogleFonts.cairo(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, bool obs, VoidCallback onEye) {
    return TextField(
      obscureText: obs,
      style: GoogleFonts.cairo(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.grey),
        filled: true, fillColor: Colors.white,
        suffixIcon: IconButton(icon: Icon(obs ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onEye),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}