import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_themes.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/cache_service.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (needed for Auth)
  await Firebase.initializeApp();

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // Shared service singletons
  final cacheService = CacheService();
  final authService = AuthService();
  final dbService = DatabaseService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(cacheService: cacheService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            cacheService: cacheService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            dbService: dbService,
            cacheService: cacheService,
          ),
        ),
      ],
      child: const SmartTodoApp(),
    ),
  );
}

class SmartTodoApp extends StatelessWidget {
  const SmartTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final appTheme = themeProvider.currentAppTheme;
        final themeData = appTheme.toThemeData();

        return MaterialApp(
          title: 'Smart To-Do',
          debugShowCheckedModeBanner: false,
          // Use single themeData driven by provider — instant, no restart
          theme: themeData,
          darkTheme: AppThemes.getTheme(themeProvider.themeIndex, isDark: true).toThemeData(),
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
          builder: (context, child) {
            return ScrollConfiguration(
              behavior:
                  const ScrollBehavior().copyWith(overscroll: false),
              child: child!,
            );
          },
        );
      },
    );
  }
}
