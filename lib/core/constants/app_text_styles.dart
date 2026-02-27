// lib/core/constants/app_text_styles.dart
// Typography system using DM Sans — clean, modern, minimal

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display ──────────────────────────────────────────────────
  static TextStyle displayLarge(bool isDark) => GoogleFonts.dmSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle displayMedium(bool isDark) => GoogleFonts.dmSans(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // ── Headings ─────────────────────────────────────────────────
  static TextStyle headingLarge(bool isDark) => GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle headingMedium(bool isDark) => GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    height: 1.35,
  );

  static TextStyle headingSmall(bool isDark) => GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    height: 1.4,
  );

  // ── Body ─────────────────────────────────────────────────────
  static TextStyle bodyLarge(bool isDark) => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    height: 1.6,
  );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color:
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    height: 1.55,
  );

  static TextStyle bodySmall(bool isDark) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
    height: 1.5,
  );

  // ── Labels ───────────────────────────────────────────────────
  static TextStyle labelMedium(bool isDark) => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color:
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    letterSpacing: 0.1,
  );

  static TextStyle labelSmall(bool isDark) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
    letterSpacing: 0.3,
  );

  // ── Button ───────────────────────────────────────────────────
  static TextStyle button(bool isDark) => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle buttonSmall(bool isDark) => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
}
