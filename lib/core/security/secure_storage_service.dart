import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for credentials (password, manager PIN).
class SecureStorageService {
  SecureStorageService._({FlutterSecureStorage? storage, Map<String, String>? memory})
      : _storage = storage,
        _memory = memory;

  factory SecureStorageService({FlutterSecureStorage? storage}) {
    return SecureStorageService._(
      storage: storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          ),
    );
  }

  /// In-memory store for unit/widget tests (avoids platform-channel hangs).
  factory SecureStorageService.memory() {
    return SecureStorageService._(memory: <String, String>{});
  }

  final FlutterSecureStorage? _storage;
  final Map<String, String>? _memory;

  static const String loginPasswordKey = 'secure_login_password';
  static const String managerPinKey = 'secure_manager_pin';
  static const String authTokenKey = 'secure_auth_token';

  Future<String?> read(String key) async {
    if (_memory != null) return _memory[key];
    return _storage!.read(key: key);
  }

  Future<void> write(String key, String value) async {
    if (_memory != null) {
      _memory[key] = value;
      return;
    }
    await _storage!.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    if (_memory != null) {
      _memory.remove(key);
      return;
    }
    await _storage!.delete(key: key);
  }

  Future<void> deleteAll() async {
    if (_memory != null) {
      _memory.clear();
      return;
    }
    await _storage!.deleteAll();
  }

  Future<String?> getLoginPassword() => read(loginPasswordKey);

  Future<void> setLoginPassword(String value) =>
      write(loginPasswordKey, value);

  Future<String?> getManagerPin() => read(managerPinKey);

  Future<void> setManagerPin(String value) => write(managerPinKey, value);

  Future<String?> getAuthToken() => read(authTokenKey);

  Future<void> setAuthToken(String value) => write(authTokenKey, value);

  Future<void> clearAuthToken() => delete(authTokenKey);

  Future<bool> hasLoginPassword() async {
    final v = await getLoginPassword();
    return v != null && v.isNotEmpty;
  }

  Future<bool> hasManagerPin() async {
    final v = await getManagerPin();
    return v != null && v.isNotEmpty;
  }
}
