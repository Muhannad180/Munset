import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  // ----- Colors -----

  static const Color _top = Color(0xFFF5FFF5); // very light mint (top)
  static const Color _bottom = Color(0xFFB2DFDB); // teal-ish mint (bottom)

  // ----- Gradient -----
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_top, Color.fromARGB(255, 158, 235, 228)],
  );

  /// A reusable background widget
  static Widget gradientBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(gradient: backgroundGradient),
      child: child,
    );
  }

  // ----- Text styles (Arabic-friendly) -----

  static TextStyle get heading => GoogleFonts.tajawal(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
  );

  static TextStyle get body => GoogleFonts.tajawal(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle get button => GoogleFonts.tajawal(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static ButtonStyle get buttonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.teal.shade400,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
