import 'package:shared_preferences/shared_preferences.dart';

import '../constants/pref_keys.dart';

/// Typed accessors over [SharedPreferences] for app configuration.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  bool get isLoggedIn => _prefs.getBool(PrefKeys.isLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) => _prefs.setBool(PrefKeys.isLoggedIn, value);

  String get loginUsername => _prefs.getString(PrefKeys.loginUsername) ?? 'admin';

  Future<void> setLoginUsername(String v) => _prefs.setString(PrefKeys.loginUsername, v);

  String get loginPassword => _prefs.getString(PrefKeys.loginPassword) ?? '1234';

  Future<void> setLoginPassword(String v) => _prefs.setString(PrefKeys.loginPassword, v);

  String get managerPin => _prefs.getString(PrefKeys.managerPin) ?? '1234';

  Future<void> setManagerPin(String v) => _prefs.setString(PrefKeys.managerPin, v);

  String get tid => _prefs.getString(PrefKeys.tid) ?? '';

  Future<void> setTid(String v) => _prefs.setString(PrefKeys.tid, v);

  String get mid => _prefs.getString(PrefKeys.mid) ?? '';

  Future<void> setMid(String v) => _prefs.setString(PrefKeys.mid, v);

  String get currentStore => _prefs.getString(PrefKeys.currentStore) ?? '2Burger Bar';

  Future<void> setCurrentStore(String v) => _prefs.setString(PrefKeys.currentStore, v);

  bool get tipsEnabled => _prefs.getBool(PrefKeys.tipsEnabled) ?? true;

  Future<void> setTipsEnabled(bool v) => _prefs.setBool(PrefKeys.tipsEnabled, v);

  bool get cashEnabled => _prefs.getBool(PrefKeys.cashEnabled) ?? false;

  Future<void> setCashEnabled(bool v) => _prefs.setBool(PrefKeys.cashEnabled, v);

  bool get autoPrintReceipt => _prefs.getBool(PrefKeys.autoPrintReceipt) ?? false;

  Future<void> setAutoPrintReceipt(bool v) => _prefs.setBool(PrefKeys.autoPrintReceipt, v);

  /// print | digital | ask | none
  String get receiptType => _prefs.getString(PrefKeys.receiptType) ?? 'ask';

  Future<void> setReceiptType(String v) => _prefs.setString(PrefKeys.receiptType, v);
}
