import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Sacred/Spiritual palette: Deep indigo, pure white, gold/amber
  static const Color primary = Color(0xFF2A2B5F); // Deep spiritual indigo
  static const Color primaryDark = Color(0xFF1B1C40); // Darker indigo
  static const Color primaryLight = Color(0xFF414383); // Lighter indigo

  static const Color accent = Color(0xFFD4AF37); // Elegant gold
  static const Color accentLight = Color(0xFFF3E5AB); // Cream/Soft gold
  static const Color accentDark = Color(0xFFAA7C11); // Deep amber/bronze

  // Warm, spiritual grade colors (harmonious sunrises/light gradients)
  static const List<Color> gradeColors = [
    Color(0xFFE07A5F), // Grade 1
    Color(0xFFF4A261), // Grade 2
    Color(0xFFE9C46A), // Grade 3
    Color(0xFF2A9D8F), // Grade 4
    Color(0xFF264653), // Grade 5
    Color(0xFF457B9D), // Grade 6
    Color(0xFF1D3557), // Grade 7
    Color(0xFF6B705C), // Grade 8
    Color(0xFFA5A58D), // Grade 9
    Color(0xFFB7B7A4), // Grade 10
    Color(0xFFDDBDF6), // Grade 11
    Color(0xFFA2D2FF), // Grade 12
  ];

  // Backgrounds
  static const Color background = Color(0xFFFDFBF7); // Warm ivory/alabaster
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text colors
  static const Color textDark = Color(0xFF22223B);
  static const Color textMedium = Color(0xFF4A4E69);
  static const Color textLight = Color(0xFF9A8C98);
  static const Color textHint = Color(0xFFC9ADA7);

  // Functional colors
  static const Color error = Color(0xFFD90429);
  static const Color success = Color(0xFF38B000);
  static const Color divider = Color(0xFFF2ECE4);

  // Document types
  static const Color pdfColor = Color(0xFFE63946);
  static const Color docColor = Color(0xFF457B9D);
}

class AppTheme {
  /// Global wrapper for GoogleFonts.outfit that automatically adds
  /// Noto Serif Ethiopic as a fallback to support Amharic characters.
  static TextStyle outfit({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.outfit(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
    ).copyWith(
      fontFamilyFallback: [GoogleFonts.notoSerifEthiopic().fontFamily!],
    );
  }

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.outfitTextTheme().copyWith(
          displayLarge: outfit(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: outfit(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: outfit(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          titleMedium: outfit(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          bodyLarge: outfit(color: AppColors.textMedium, fontSize: 15),
          bodyMedium: outfit(color: AppColors.textMedium, fontSize: 13),
          bodySmall: outfit(color: AppColors.textLight, fontSize: 12),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: outfit(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: AppColors.textDark),
        ),
      );
}
