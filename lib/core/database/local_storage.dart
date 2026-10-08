import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/settings_model.dart';
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

  Future<void> setMid(String v) => _prefs.setString(PrefKeys.mid, v.trim());

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

  /// Logo URL saved with app settings (`logo` or `paymentScreenLogo`).
  String get paymentScreenLogo {
    final fromModel = appSettings?.paymentScreenLogo?.trim() ?? '';
    if (fromModel.isNotEmpty) return fromModel;

    final raw = _prefs.getString(PrefKeys.appSettings);
    if (raw == null || raw.trim().isEmpty) return '';
    try {
      final decoded = jsonDecode(raw);
      return _findLogoUrl(decoded) ?? '';
    } catch (_) {}
    return '';
  }

  static const _logoKeys = [
    'paymentScreenLogo',
    'payment_screen_logo',
    'logo',
    'logoUrl',
    'logo_url',
    'imageUrl',
    'image_url',
  ];

  String? _findLogoUrl(Object? node) {
    if (node is Map) {
      for (final key in _logoKeys) {
        final value = node[key]?.toString().trim() ?? '';
        if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
      }
      for (final value in node.values) {
        final found = _findLogoUrl(value);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final value in node) {
        final found = _findLogoUrl(value);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// Cached `GET api/app/settings` payload, without the manager PIN.
  SettingsModel? get appSettings {
    final raw = _prefs.getString(PrefKeys.appSettings);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return SettingsModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  /// Persists remote settings for later screens.
  ///
  /// Manager PIN is stored in secure storage, not in [SharedPreferences].
  Future<void> saveRemoteSettings(SettingsModel settings) async {
    await setTipsEnabled(settings.tipEnabled);
    await setCashEnabled(settings.cashPaymentEnabled);

    final pin = settings.managerPin?.trim() ?? '';
    if (pin.isNotEmpty) {
      await setManagerPin(pin);
    }

    final terminalName = settings.terminalName?.trim();
    if (terminalName != null && terminalName.isNotEmpty) {
      await setTerminalName(terminalName);
    }

    await setTerminalId(settings.terminalId?.trim() ?? '');
    await setMid(settings.merchantId?.trim() ?? '');

    final cached = Map<String, dynamic>.from(settings.toJson())
      ..remove('managerPin');
    await _prefs.setString(PrefKeys.appSettings, jsonEncode(cached));
  }

  /// print | digital | ask | none
  String get receiptType => _prefs.getString(PrefKeys.receiptType) ?? 'ask';

  Future<void> setReceiptType(String v) => _prefs.setString(PrefKeys.receiptType, v);
}
