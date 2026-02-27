// lib/core/constants/app_constants.dart
// App-wide constants

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Smart To-Do';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.smarttodo.planner';

  // Collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

  // SharedPreferences keys
  static const String prefKeyTasks = 'cached_tasks';
  static const String prefKeyTheme = 'app_theme_index';
  static const String prefKeyIsDark = 'app_is_dark';
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyIsLoggedIn = 'is_logged_in';
  static const String prefKeyUserName = 'user_name';
  static const String prefKeyUserEmail = 'user_email';

  // Task categories
  static const List<String> taskCategories = [
    'Work',
    'Personal',
    'Health',
    'Learning',
    'Finance',
    'Other',
  ];

  // Animation durations
  static const Duration durationFast = Duration(milliseconds: 180);
  static const Duration durationNormal = Duration(milliseconds: 280);
  static const Duration durationSlow = Duration(milliseconds: 450);

  // UI dimensions
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 18.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 100.0;

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  static const double cardElevation = 0.0;
}
