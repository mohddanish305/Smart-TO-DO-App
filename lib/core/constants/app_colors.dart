// lib/core/constants/app_colors.dart
// Minimalist refined color palette — pure neutrals + deep indigo accent

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Accent (deep indigo — focus, trust, modern) ─────────────
  static const Color accent = Color(0xFF6246EA);
  static const Color accentLight = Color(0xFFEDE9FF);
  static const Color accentDark = Color(0xFF3D28C7);

  // ── Light Theme (crisp white + pure grey neutrals) ──────────
  static const Color lightBg = Color(0xFFF8F8F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8E8E8);
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF555555);
  static const Color lightTextMuted = Color(0xFFAAAAAA);
  static const Color lightDivider = Color(0xFFF0F0F0);

  // ── Dark Theme (true dark + neutral grey) ────────────────────
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF161616);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF2F2F2);
  static const Color darkTextSecondary = Color(0xFF8A8A8A);
  static const Color darkTextMuted = Color(0xFF484848);
  static const Color darkDivider = Color(0xFF222222);

  // ── Semantic ─────────────────────────────────────────────────
  static const Color error = Color(0xFFE63946);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // ── Category Colors ──────────────────────────────────────────
  static const List<Color> categoryColors = [
    Color(0xFF6246EA), // Work — indigo
    Color(0xFF3B82F6), // Personal — blue
    Color(0xFF10B981), // Health — green
    Color(0xFF8B5CF6), // Learning — purple
    Color(0xFFF59E0B), // Finance — amber
    Color(0xFF6B8E9E), // Other — slate
  ];
}
