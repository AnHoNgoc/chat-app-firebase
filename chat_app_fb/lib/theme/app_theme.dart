import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4F6EF6);
  static const Color secondaryColor = Color(0xFF7489FF);
  static const Color accentColor = Color(0xFFFD79A8);
  static const Color backgroundColor = Color(0xFFF8F9Fa);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF2D3436);
  static const Color textSecondaryColor = Color(0xFF636E72);
  static const Color borderColor = Color(0xFFDDD6FE);
  static const Color errorColor = Color(0xFFE17055);
  static const Color successColor = Color(0xFF00B894);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      error: errorColor,
      onSurface: textPrimaryColor,
      onBackground: textPrimaryColor,
    ),

    // ✅ Text theme with ScreenUtil
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: textSecondaryColor,
      ),
    ),

    // ✅ AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      iconTheme: const IconThemeData(color: textPrimaryColor),
    ),

    // ✅ Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ✅ Card theme
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),

    // ✅ Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: borderColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
    ),

    // ✅ FAB theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
