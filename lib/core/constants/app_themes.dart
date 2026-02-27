// lib/core/constants/app_themes.dart
// 10 minimalist selectable themes for the app

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeData {
  final String name;
  final Color primary;
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color error;
  final bool isDarkBase;

  const AppThemeData({
    required this.name,
    required this.primary,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.error,
    required this.isDarkBase,
  });

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkBase ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: isDarkBase ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        secondary: primary,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.dmSans(color: textMuted, fontSize: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.grey[400]),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? primary.withValues(alpha: 0.35)
                : Colors.grey.withValues(alpha: 0.2)),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle:
            GoogleFonts.dmSans(color: background, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.transparent),
        side: BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      textTheme: GoogleFonts.dmSansTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }
}

class AppThemes {
  AppThemes._();

  static const List<AppThemeData> themes = [
    // 0 — Midnight Black
    AppThemeData(
      name: 'Midnight Black',
      primary: Color(0xFF6246EA),
      background: Color(0xFF0D0D0D),
      surface: Color(0xFF161616),
      card: Color(0xFF1E1E1E),
      border: Color(0xFF2A2A2A),
      textPrimary: Color(0xFFF2F2F2),
      textSecondary: Color(0xFF8A8A8A),
      textMuted: Color(0xFF484848),
      success: Color(0xFF10B981),
      error: Color(0xFFE63946),
      isDarkBase: true,
    ),
    // 1 — Soft Lavender
    AppThemeData(
      name: 'Soft Lavender',
      primary: Color(0xFF7C6BC9),
      background: Color(0xFFF7F5FF),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFE5E0F5),
      textPrimary: Color(0xFF1E1833),
      textSecondary: Color(0xFF6B6280),
      textMuted: Color(0xFFB0AACC),
      success: Color(0xFF10B981),
      error: Color(0xFFE63946),
      isDarkBase: false,
    ),
    // 2 — Ocean Blue
    AppThemeData(
      name: 'Ocean Blue',
      primary: Color(0xFF2563EB),
      background: Color(0xFFF0F6FF),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFDCE8FB),
      textPrimary: Color(0xFF0F1E3A),
      textSecondary: Color(0xFF4E6E9E),
      textMuted: Color(0xFFAABDD8),
      success: Color(0xFF10B981),
      error: Color(0xFFE63946),
      isDarkBase: false,
    ),
    // 3 — Forest Green
    AppThemeData(
      name: 'Forest Green',
      primary: Color(0xFF16A34A),
      background: Color(0xFFF2FAF5),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFD5EDE0),
      textPrimary: Color(0xFF0F2318),
      textSecondary: Color(0xFF3D7A54),
      textMuted: Color(0xFF9EC9B0),
      success: Color(0xFF22C55E),
      error: Color(0xFFE63946),
      isDarkBase: false,
    ),
    // 4 — Minimal Gray
    AppThemeData(
      name: 'Minimal Gray',
      primary: Color(0xFF374151),
      background: Color(0xFFF9F9F9),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFE5E7EB),
      textPrimary: Color(0xFF111827),
      textSecondary: Color(0xFF6B7280),
      textMuted: Color(0xFFD1D5DB),
      success: Color(0xFF10B981),
      error: Color(0xFFE63946),
      isDarkBase: false,
    ),
    // 5 — Sand Beige
    AppThemeData(
      name: 'Sand Beige',
      primary: Color(0xFFB45309),
      background: Color(0xFFFDF8F0),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFF9F0),
      border: Color(0xFFEDDFC6),
      textPrimary: Color(0xFF2C1A06),
      textSecondary: Color(0xFF8A6543),
      textMuted: Color(0xFFCBAF86),
      success: Color(0xFF59A03D),
      error: Color(0xFFE63946),
      isDarkBase: false,
    ),
    // 6 — Arctic White
    AppThemeData(
      name: 'Arctic White',
      primary: Color(0xFF06B6D4),
      background: Color(0xFFFAFBFF),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFE2EEF2),
      textPrimary: Color(0xFF0A1525),
      textSecondary: Color(0xFF4E6E80),
      textMuted: Color(0xFFA8C4CC),
      success: Color(0xFF10B981),
      error: Color(0xFFE63946),
      isDarkBase: false,
    ),
    // 7 — Sunset Orange
    AppThemeData(
      name: 'Sunset Orange',
      primary: Color(0xFFEA580C),
      background: Color(0xFF100A06),
      surface: Color(0xFF1A1107),
      card: Color(0xFF221708),
      border: Color(0xFF332210),
      textPrimary: Color(0xFFFFF3E8),
      textSecondary: Color(0xFFCCA07A),
      textMuted: Color(0xFF6B4C2A),
      success: Color(0xFF10B981),
      error: Color(0xFFFF6B6B),
      isDarkBase: true,
    ),
    // 8 — Deep Purple
    AppThemeData(
      name: 'Deep Purple',
      primary: Color(0xFFA855F7),
      background: Color(0xFF080612),
      surface: Color(0xFF10091C),
      card: Color(0xFF180D26),
      border: Color(0xFF2E1850),
      textPrimary: Color(0xFFF5EEFF),
      textSecondary: Color(0xFFAA88CC),
      textMuted: Color(0xFF5E3A80),
      success: Color(0xFF10B981),
      error: Color(0xFFFF6B6B),
      isDarkBase: true,
    ),
    // 9 — Soft Teal
    AppThemeData(
      name: 'Soft Teal',
      primary: Color(0xFF0D9488),
      background: Color(0xFFF0FDFB),
      surface: Color(0xFFFFFFFF),
      card: Color(0xFFFFFFFF),
      border: Color(0xFFCCEDE9),
      textPrimary: Color(0xFF0A2621),
      textSecondary: Color(0xFF3D7A74),
      textMuted: Color(0xFF96C8C4),
      success: Color(0xFF10B981),
      error: Color(0xFFE63946),
      isDarkBase: false,
    ),
  ];

  static AppThemeData getTheme(int index, {bool isDark = false}) {
    final base = themes[index.clamp(0, themes.length - 1)];
    // For light-base themes, if user requests dark, use dark variant (index 0 — Midnight Black with same primary)
    if (isDark && !base.isDarkBase) {
      return AppThemeData(
        name: base.name,
        primary: base.primary,
        background: const Color(0xFF0D0D0D),
        surface: const Color(0xFF161616),
        card: const Color(0xFF1E1E1E),
        border: const Color(0xFF2A2A2A),
        textPrimary: const Color(0xFFF2F2F2),
        textSecondary: const Color(0xFF8A8A8A),
        textMuted: const Color(0xFF484848),
        success: base.success,
        error: base.error,
        isDarkBase: true,
      );
    }
    return base;
  }
}
