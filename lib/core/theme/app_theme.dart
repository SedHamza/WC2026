import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF5F5F5),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: isDark ? AppColors.bgCard : Colors.white,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E),
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.bgDark : Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.bgCard : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.bgSurface : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.bgSurface : const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondary : const Color(0xFF6B7280),
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.textHint : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}