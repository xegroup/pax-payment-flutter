import 'package:dio/dio.dart';

import '../../features/transaction/data/session_response.dart';
import '../di/injection.dart';
import '../network/MyApiClient.dart';
import '../security/secure_storage_service.dart';

enum SessionStatus {
  /// No stored token — show login.
  unauthenticated,

  /// Token present and checkSession returned valid.
  authenticated,

  /// Token was rejected or expired — clear and show login with message.
  expired,
}

/// Validates the stored auth token against `GET api/app/auth/check`.
class SessionService {
  SessionService._();

  /// Called on splash and app resume to verify the stored session.
  static Future<SessionStatus> validateStoredSession() async {
    final storedToken = await sl<SecureStorageService>().getAuthToken();
    if (storedToken == null || storedToken.trim().isEmpty) {
      return SessionStatus.unauthenticated;
    }

    await MyApiClient.loadPersistedAuthToken();

    try {
      final response = await MyApiClient.checkSession();
      if (response.valid) {
        await MyApiClient.persistAuthToken(storedToken.trim());
        return SessionStatus.authenticated;
      }

      await MyApiClient.clearAuthToken();
      return SessionStatus.expired;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        await MyApiClient.clearAuthToken();
        return SessionStatus.expired;
      }

      final parsed = SessionResponse.tryParse(e.response?.data);
      if (parsed != null && !parsed.valid) {
        await MyApiClient.clearAuthToken();
        return SessionStatus.expired;
      }

      rethrow;
    }
  }
}
