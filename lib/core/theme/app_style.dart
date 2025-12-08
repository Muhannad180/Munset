import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  // Palette - Keep static as they are brand colors
  static const Color primary = Color(0xFF4DB6AC); 
  static const Color primaryDark = Color(0xFF00897B);
  static const Color accent = Color(0xFFFFB74D); 
  
  // Backgrounds
  static Color bgTop(BuildContext context) => isDark(context) ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA);
  static Color bgBottom(BuildContext context) => isDark(context) ? const Color(0xFF121212) : const Color(0xFFE3F2FD);
  static Color cardBg(BuildContext context) => isDark(context) ? const Color(0xFF2C2C2C) : Colors.white;

  // Gradients
  static LinearGradient mainGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop(context), bgBottom(context)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> cardShadow(BuildContext context) => [
    BoxShadow(
      color: isDark(context) ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 2,
    )
  ];

  static BorderRadius get cardRadius => BorderRadius.circular(20);

  // Typography Hierarchy
  static Color textMain(BuildContext context) => isDark(context) ? Colors.white : const Color(0xFF2D3436);
  static Color textBody(BuildContext context) => isDark(context) ? Colors.grey[300]! : const Color(0xFF535C68);
  static Color textSmall(BuildContext context) => isDark(context) ? Colors.grey[500]! : const Color(0xFF95A5A6);

  static TextStyle heading(BuildContext context) => GoogleFonts.tajawal(
    fontSize: 26, 
    fontWeight: FontWeight.w800,
    color: textMain(context),
    height: 1.3,
  );

  static TextStyle cardTitle(BuildContext context) => GoogleFonts.tajawal(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textMain(context),
  );

  static TextStyle body(BuildContext context) => GoogleFonts.tajawal(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: textBody(context),
    height: 1.6,
  );
  
  static TextStyle bodySmall(BuildContext context) => GoogleFonts.tajawal(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSmall(context),
  );

  static TextStyle get buttonText => GoogleFonts.tajawal(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
