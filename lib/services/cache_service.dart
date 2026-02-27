// lib/services/cache_service.dart
// SharedPreferences persistence for tasks, theme, dark mode, login state

import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class CacheService {
  // ── Tasks ─────────────────────────────────────────────────────

  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyTasks, TaskModel.listToJson(tasks));
  }

  Future<List<TaskModel>> getCachedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(AppConstants.prefKeyTasks);
      if (json == null || json.isEmpty) return [];
      return TaskModel.listFromJson(json);
    } catch (_) {
      return [];
    }
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefKeyTasks);
  }

  // ── Theme Index ───────────────────────────────────────────────

  Future<void> saveThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefKeyTheme, index);
  }

  Future<int?> getThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.prefKeyTheme);
  }

  // ── Dark Mode ────────────────────────────────────────────────

  Future<void> saveIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyIsDark, isDark);
  }

  Future<bool?> getIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefKeyIsDark);
  }

  // Legacy theme compat
  Future<void> saveTheme(bool isDark) => saveIsDark(isDark);
  Future<bool?> getSavedTheme() => getIsDark();

  // ── Login State ───────────────────────────────────────────────

  Future<void> saveLoginState({
    required String userId,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyIsLoggedIn, true);
    await prefs.setString(AppConstants.prefKeyUserId, userId);
    await prefs.setString(AppConstants.prefKeyUserName, name);
    await prefs.setString(AppConstants.prefKeyUserEmail, email);
  }

  Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;
    if (!loggedIn) return null;
    final uid = prefs.getString(AppConstants.prefKeyUserId) ?? '';
    final name = prefs.getString(AppConstants.prefKeyUserName) ?? '';
    final email = prefs.getString(AppConstants.prefKeyUserEmail) ?? '';
    if (uid.isEmpty) return null;
    return UserModel(uid: uid, name: name, email: email);
  }

  Future<void> saveUserId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyUserId, uid);
  }

  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefKeyUserId);
  }

  // ── Clear ─────────────────────────────────────────────────────

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // ⚠️ Keep theme & dark mode — only clear auth
    await prefs.remove(AppConstants.prefKeyIsLoggedIn);
    await prefs.remove(AppConstants.prefKeyUserId);
    await prefs.remove(AppConstants.prefKeyUserName);
    await prefs.remove(AppConstants.prefKeyUserEmail);
    await prefs.remove(AppConstants.prefKeyTasks);
  }
}
