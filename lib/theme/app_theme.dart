import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Binance-style Dark Theme Palette
  static const Color background = Color(0xFF0B0E11);
  static const Color card = Color(0xFF1E2329);
  static const Color cardLight = Color(0xFF2B3139);
  
  static const Color primary = Color(0xFF00FFA3); // Neon Green
  static const Color accent = Color(0xFF4D8CFF); // Electric Blue
  
  static const Color textPrimary = Color(0xFFEAECEF);
  static const Color textSecondary = Color(0xFF848E9C);
  static const Color textDisabled = Color(0xFF474D57);
  
  static const Color error = Color(0xFFF6465D);
  static const Color success = Color(0xFF0ECB81);
  
  static const Color border = Color(0xFF334155);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.black,
        secondary: AppColors.accent,
        surface: AppColors.card,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
    );
  }

  static BoxDecoration cryptoCardDecoration({double glowOpacity = 0.03}) => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: glowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      );
}
