import 'package:flutter/material.dart';

import '../../features/auth/login_screen.dart';

/// Handles expired or invalid auth sessions app-wide.
class AuthSession {
  AuthSession._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _isHandling = false;

  static bool shouldForceLogin({
    required int? statusCode,
    required String path,
  }) {
    if (statusCode != 401 && statusCode != 403) return false;
    final normalized = path.toLowerCase();
    if (normalized.contains('/auth/login') ||
        normalized.contains('/auth/register')) {
      return false;
    }
    return true;
  }

  static Future<void> handleUnauthorized({
    required Future<void> Function() clearToken,
    String? message,
  }) async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      await clearToken();

      final navigator = navigatorKey.currentState;
      if (navigator == null) return;

      final sessionMessage =
          message ?? 'Your session has expired. Please sign in again.';

      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => LoginScreen(sessionMessage: sessionMessage),
        ),
        (route) => false,
      );
    } finally {
      _isHandling = false;
    }
  }
}
