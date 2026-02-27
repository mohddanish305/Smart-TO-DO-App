// lib/core/errors/app_exception.dart
// Typed exception classes for clean error handling

class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error. Check your connection.'])
      : super(message, code: 'NETWORK_ERROR');
}

class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed.'])
      : super(message, code: 'AUTH_ERROR');
}

class FirestoreException extends AppException {
  const FirestoreException([String message = 'Database error. Please try again.'])
      : super(message, code: 'FIRESTORE_ERROR');
}

class CacheException extends AppException {
  const CacheException([String message = 'Cache error.'])
      : super(message, code: 'CACHE_ERROR');
}

class ValidationException extends AppException {
  const ValidationException(String message)
      : super(message, code: 'VALIDATION_ERROR');
}
