import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 الألوان الأساسية المستخدمة في الصفحات الجديدة
  static const Color primaryColor = Color(0xFF5E9E92); // التركواز الأساسي
  static const Color secondaryColor = Color(0xFFACD5C7); // التركواز الفاتح (للهيدر)
  static const Color backgroundColor = Color(0xFFF8F9FA); // خلفية الصفحات (رمادي فاتح جداً)
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Color(0xFF2D3436);
  static const Color errorColor = Color(0xFFD63031);
  static const Color greyColor = Color(0xFFB2BEC3);

  // 🖌️ إعداد الثيم العام
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // الألوان الرئيسية
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: whiteColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: whiteColor, // لون النص فوق اللون الأساسي
      ),

      // 🔤 الخطوط (Cairo هو الأنسب للتطبيقات العربية)
      // إذا حدث خطأ في تحميل الخط، سيستخدم الخط الافتراضي للنظام
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.bold, color: blackColor),
        displayMedium: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: blackColor),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: blackColor),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[800]),
        labelLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: whiteColor), // للأزرار
      ),

      // 📱 توحيد شكل الـ AppBar (في حال استخدمته خارج الهيدر المخصص)
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0, // يمنع تغير اللون عند السكرول
        iconTheme: const IconThemeData(color: blackColor),
        titleTextStyle: GoogleFonts.cairo(
          color: blackColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 🔘 توحيد شكل الأزرار (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // حواف دائرية ناعمة
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 📥 توحيد حقول الإدخال (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: whiteColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        
        // الحدود العادية
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // بدون حدود سوداء افتراضية
        ),
        
        // الحدود عند التفعيل (بدون كتابة)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        
        // الحدود عند الكتابة (Focus)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        
        // الحدود عند الخطأ
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        
        hintStyle: TextStyle(color: Colors.grey[400], fontFamily: GoogleFonts.cairo().fontFamily),
        labelStyle: TextStyle(color: Colors.grey[700], fontFamily: GoogleFonts.cairo().fontFamily),
      ),

      // 🖱️ توحيد ألوان الأيقونات والـ Checkbox
      iconTheme: const IconThemeData(color: primaryColor),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null; // شفاف عند عدم الاختيار
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}