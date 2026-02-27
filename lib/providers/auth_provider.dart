// lib/providers/auth_provider.dart
// Auth state with full local login persistence (no Firebase session dependency)

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final CacheService _cacheService;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthProvider({
    required AuthService authService,
    required CacheService cacheService,
  })  : _authService = authService,
        _cacheService = cacheService {
    _init();
  }

  // ── Getters ──────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // ── Initialization (checks persisted login first) ─────────────
  Future<void> _init() async {
    // 1. Check local cache first — no network needed
    final savedUser = await _cacheService.getSavedUser();
    if (savedUser != null) {
      _user = savedUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return;
    }

    // 2. Fall back to Firebase auth stream
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        _user = _authService.userFromFirebase(firebaseUser);
        _status = AuthStatus.authenticated;
        // Persist for next cold start
        if (_user != null) {
          _cacheService.saveLoginState(
            userId: _user!.uid,
            name: _user!.name,
            email: _user!.email,
          );
        }
      } else {
        if (_status != AuthStatus.authenticated) {
          _user = null;
          _status = AuthStatus.unauthenticated;
        }
      }
      notifyListeners();
    });

    // If no firebase user either, set unauthenticated
    await Future.delayed(const Duration(milliseconds: 500));
    if (_status == AuthStatus.initial) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // ── Sign In with Google ───────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading();
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      return await _saveAndAuthenticate(user);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Sign In with Email ────────────────────────────────────────
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading();
      final user = await _authService.signInWithEmail(email, password);
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      return await _saveAndAuthenticate(user);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Sign Up with Email ────────────────────────────────────────
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      _setLoading();
      final user = await _authService.signUpWithEmail(email, password, name);
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      return await _saveAndAuthenticate(user);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Save + Authenticate ───────────────────────────────────────
  Future<bool> _saveAndAuthenticate(UserModel user) async {
    _user = user;
    await _cacheService.saveLoginState(
      userId: user.uid,
      name: user.name,
      email: user.email,
    );
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // ── Sign Out ─────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      _setLoading();
      await _authService.signOut();
      await _cacheService.clearAll(); // clears login state, keeps theme
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
