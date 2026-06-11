import 'package:flutter/material.dart';

class AppColors {
  // ── BRAND ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF002868);   // Bleu WC
  static const Color secondary = Color(0xFFC8102E); // Rouge WC
  static const Color accent = Color(0xFF006847);    // Vert WC

  // ── BACKGROUNDS LIGHT ─────────────────────────────────────────────────────
  static const Color bgPageLight = Color(0xFFFFFFFF);    // Fond page blanc
  static const Color bgCardLight = Color(0xFFFFFFFF);    // Fond carte blanc
  static const Color bgSurfaceLight = Color(0xFFF3F4F6); // Fond inputs/sections
  static const Color bgSubtleLight = Color(0xFFF9FAFB);  // Fond très léger

  // ── BACKGROUNDS DARK ──────────────────────────────────────────────────────
  static const Color bgPageDark = Color(0xFF0A0E1A);    // Fond page sombre
  static const Color bgCardDark = Color(0xFF141824);    // Fond carte sombre
  static const Color bgSurfaceDark = Color(0xFF1E2433); // Fond inputs/sections
  static const Color bgSubtleDark = Color(0xFF111827);  // Fond très léger sombre

  // ── TEXTES LIGHT ──────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF111827);   // Texte principal
  static const Color textSecondaryLight = Color(0xFF6B7280); // Texte secondaire
  static const Color textHintLight = Color(0xFF9CA3AF);      // Placeholder
  static const Color textDisabledLight = Color(0xFFD1D5DB);  // Désactivé

  // ── TEXTES DARK ───────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFFFFFFF);    // Texte principal
  static const Color textSecondaryDark = Color(0xFFB0B8CC);  // Texte secondaire
  static const Color textHintDark = Color(0xFF6B7280);       // Placeholder
  static const Color textDisabledDark = Color(0xFF374151);   // Désactivé

  // ── BORDURES LIGHT ────────────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);        // Bordure normale
  static const Color borderStrongLight = Color(0xFFD1D5DB);  // Bordure forte

  // ── BORDURES DARK ─────────────────────────────────────────────────────────
static const Color borderDark = Color(0xFF2A3347);
  static const Color borderStrongDark = Color(0xFF374151);   // Bordure forte

  // ── SÉMANTIQUES (identiques dans les deux modes) ──────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF166534);
  static const Color successBgLight = Color(0xFFF0FDF4);
  static const Color successBgDark = Color(0xFF052E16);

  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFF991B1B);
  static const Color errorBgLight = Color(0xFFFEF2F2);
  static const Color errorBgDark = Color(0xFF2D0A0A);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFF854F0B);
  static const Color warningBgLight = Color(0xFFFFFBEB);
  static const Color warningBgDark = Color(0xFF1C1200);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoBgLight = Color(0xFFEEF2FF);
  static const Color infoBgDark = Color(0xFF0C1A3D);

  // ── STATUTS MATCHS ────────────────────────────────────────────────────────
  static const Color live = Color(0xFFEF4444);
  static const Color finished = Color(0xFF6B7280);
  static const Color upcoming = Color(0xFF3B82F6);

  // ── HELPERS — retourne la bonne couleur selon le mode ────────────────────
  static Color bgPage(bool isDark) => isDark ? bgPageDark : bgPageLight;
  static Color bgCard(bool isDark) => isDark ? bgCardDark : bgCardLight;
  static Color bgSurface(bool isDark) => isDark ? bgSurfaceDark : bgSurfaceLight;
  static Color bgSubtle(bool isDark) => isDark ? bgSubtleDark : bgSubtleLight;

  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color textHint(bool isDark) => isDark ? textHintDark : textHintLight;
  static Color textDisabled(bool isDark) => isDark ? textDisabledDark : textDisabledLight;

  static Color border(bool isDark) => isDark ? borderDark : borderLight;
  static Color borderStrong(bool isDark) => isDark ? borderStrongDark : borderStrongLight;

  static Color successBg(bool isDark) => isDark ? successBgDark : successBgLight;
  static Color errorBg(bool isDark) => isDark ? errorBgDark : errorBgLight;
  static Color warningBg(bool isDark) => isDark ? warningBgDark : warningBgLight;
  static Color infoBg(bool isDark) => isDark ? infoBgDark : infoBgLight;
}