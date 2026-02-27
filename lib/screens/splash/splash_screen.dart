// lib/screens/splash/splash_screen.dart
// Premium calm splash: off-white bg, centered Lottie, smooth fade out

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../auth/auth_screen.dart';
import '../home/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottieCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _lottieCtrl = AnimationController(vsync: this);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    // Pre-load tasks if authenticated
    if (auth.isAuthenticated && auth.user != null) {
      final taskP = context.read<TaskProvider>();
      if (taskP.status == TaskLoadStatus.initial) {
        await taskP.initForUser(auth.user!.uid);
      }
    }

    if (!mounted) return;

    final dest = auth.isAuthenticated ? const HomeShell() : const AuthScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => dest,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _lottieCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie animation
              SizedBox(
                width: 160,
                height: 160,
                child: Lottie.asset(
                  'assets/animations/Task.json',
                  controller: _lottieCtrl,
                  fit: BoxFit.contain,
                  onLoaded: (comp) {
                    _lottieCtrl
                      ..duration = comp.duration
                      ..repeat();
                  },
                  errorBuilder: (_, __, ___) => _FallbackLogo(),
                ),
              ),
              const SizedBox(height: 36),
              // App name
              Text(
                'Smart To-Do',
                style: GoogleFonts.dmSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Focus. Plan. Achieve.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFAAAAAA),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF6246EA).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF6246EA).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: const Icon(Icons.task_alt_rounded,
          color: Color(0xFF6246EA), size: 48),
    );
  }
}
