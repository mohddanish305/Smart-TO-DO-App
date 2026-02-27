// lib/providers/theme_provider.dart
// Theme provider: manages dark mode + 10 selectable themes, all persisted

import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_themes.dart';
import '../services/cache_service.dart';

class ThemeProvider extends ChangeNotifier {
  final CacheService _cacheService;

  bool _isDark = false;
  int _themeIndex = 0;

  ThemeProvider({required CacheService cacheService})
      : _cacheService = cacheService {
    _loadTheme();
  }

  // ── Getters ──────────────────────────────────────────────────
  bool get isDark => _isDark;
  int get themeIndex => _themeIndex;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  AppThemeData get currentAppTheme =>
      AppThemes.getTheme(_themeIndex, isDark: _isDark);

  ThemeData get themeData => currentAppTheme.toThemeData();

  // ── Load ─────────────────────────────────────────────────────
  Future<void> _loadTheme() async {
    _isDark = await _cacheService.getIsDark() ?? false;
    _themeIndex = await _cacheService.getThemeIndex() ?? 0;
    notifyListeners();
  }

  // ── Toggle Dark Mode ─────────────────────────────────────────
  Future<void> toggleDark() async {
    _isDark = !_isDark;
    await _cacheService.saveIsDark(_isDark);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    await _cacheService.saveIsDark(value);
    notifyListeners();
  }

  // ── Select Theme ─────────────────────────────────────────────
  Future<void> setTheme(int index) async {
    _themeIndex = index.clamp(0, AppThemes.themes.length - 1);
    await _cacheService.saveThemeIndex(_themeIndex);
    notifyListeners();
  }

  // Legacy
  Future<void> toggleTheme() => toggleDark();
}
