import 'package:shared_preferences/shared_preferences.dart';

import '../constants/pref_keys.dart';
import '../security/secure_storage_service.dart';

/// Typed accessors over [SharedPreferences] and secure credential storage.
class LocalStorage {
  LocalStorage(this._prefs, this._secure);

  final SharedPreferences _prefs;
  final SecureStorageService _secure;

  bool get isLoggedIn => _prefs.getBool(PrefKeys.isLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) => _prefs.setBool(PrefKeys.isLoggedIn, value);

  bool get credentialsConfigured =>
      _prefs.getBool(PrefKeys.credentialsConfigured) ?? false;

  Future<void> setCredentialsConfigured(bool value) =>
      _prefs.setBool(PrefKeys.credentialsConfigured, value);

  String get loginUsername => _prefs.getString(PrefKeys.loginUsername) ?? '';

  Future<void> setLoginUsername(String v) =>
      _prefs.setString(PrefKeys.loginUsername, v);

  Future<String?> getLoginPassword() => _secure.getLoginPassword();

  Future<void> setLoginPassword(String v) => _secure.setLoginPassword(v);

  Future<String?> getManagerPin() => _secure.getManagerPin();

  Future<void> setManagerPin(String v) => _secure.setManagerPin(v);

  Future<bool> verifyLoginPassword(String password) async {
    final stored = await getLoginPassword();
    return stored != null && stored == password;
  }

  Future<bool> verifyManagerPin(String pin) async {
    final stored = await getManagerPin();
    return stored != null && stored == pin;
  }

  Future<bool> hasCredentials() async {
    if (!credentialsConfigured) return false;
    final user = loginUsername.trim();
    if (user.isEmpty) return false;
    return await _secure.hasLoginPassword() && await _secure.hasManagerPin();
  }


  String get mid => _prefs.getString(PrefKeys.mid) ?? '';

  Future<void> setMid(String v) => _prefs.setString(PrefKeys.mid, v);

  String get currentStore => _prefs.getString(PrefKeys.currentStore) ?? '2Burger Bar';

  Future<void> setCurrentStore(String v) => _prefs.setString(PrefKeys.currentStore, v);

  String get terminalName => _prefs.getString(PrefKeys.terminalName) ?? 'Terminal';

  Future<void> setTerminalName(String v) =>
      _prefs.setString(PrefKeys.terminalName, v.trim());

  String get terminalID => _prefs.getString(PrefKeys.terminalId) ?? '';

  Future<void> setTerminalId(String v) =>
      _prefs.setString(PrefKeys.terminalId, v.trim());


  bool get tipsEnabled => _prefs.getBool(PrefKeys.tipsEnabled) ?? true;

  Future<void> setTipsEnabled(bool v) => _prefs.setBool(PrefKeys.tipsEnabled, v);

  bool get cashEnabled => _prefs.getBool(PrefKeys.cashEnabled) ?? true;

  Future<void> setCashEnabled(bool v) => _prefs.setBool(PrefKeys.cashEnabled, v);

  bool get autoPrintReceipt => _prefs.getBool(PrefKeys.autoPrintReceipt) ?? false;

  Future<void> setAutoPrintReceipt(bool v) =>
      _prefs.setBool(PrefKeys.autoPrintReceipt, v);

  /// print | digital | ask | none
  String get receiptType => _prefs.getString(PrefKeys.receiptType) ?? 'ask';

  Future<void> setReceiptType(String v) => _prefs.setString(PrefKeys.receiptType, v);
}
