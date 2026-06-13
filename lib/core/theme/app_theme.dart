import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // ── SCAFFOLD ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.bgPage(isDark),

      // ── COLOR SCHEME ──────────────────────────────────────────────────────
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.bgCard(isDark),
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: AppColors.textPrimary(isDark),
        onError: Colors.white,
      ),

      // ── APPBAR ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ── CARD ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.bgCard(isDark),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.border(isDark),
            width: 0.5,
          ),
        ),
      ),

      // ── ELEVATED BUTTON ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── OUTLINED BUTTON ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.infoText(isDark),
          side: BorderSide(color: AppColors.infoText(isDark)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── TEXT BUTTON ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.infoText(isDark),
        ),
      ),

      // ── INPUT ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border(isDark),
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.infoText(isDark),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary(isDark),
        ),
        hintStyle: TextStyle(
          color: AppColors.textHint(isDark),
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
        ),
      ),

      // ── DIVIDER ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.border(isDark),
        thickness: 0.5,
        space: 0,
      ),

      // ── ICON ──────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: AppColors.textSecondary(isDark),
      ),

      // ── TEXT ──────────────────────────────────────────────────────────────
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          color: AppColors.textHint(isDark),
          fontSize: 11,
        ),
      ),

      // ── TAB BAR ───────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: AppColors.secondary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ── BOTTOM NAV (Material 2 fallback) ─────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard(isDark),
        selectedItemColor: AppColors.infoText(isDark),
        unselectedItemColor: AppColors.textSecondary(isDark),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── NAVIGATION BAR (Material 3) ───────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgCard(isDark),
        indicatorColor: AppColors.infoText(isDark).withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.infoText(isDark));
          }
          return IconThemeData(color: AppColors.textSecondary(isDark));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
                color: AppColors.infoText(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600);
          }
          return TextStyle(
              color: AppColors.textSecondary(isDark), fontSize: 11);
        }),
        elevation: 0,
      ),

      // ── SNACKBAR ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgSurface(isDark),
        contentTextStyle: TextStyle(
          color: AppColors.textPrimary(isDark),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── DIALOG ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgCard(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 14,
        ),
      ),

      // ── CHIP ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSurface(isDark),
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 12,
        ),
        side: BorderSide(
          color: AppColors.border(isDark),
          width: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ── REFRESH INDICATOR ─────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.infoText(isDark),
      ),
    );
  }
}
