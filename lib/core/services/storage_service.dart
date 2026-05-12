import 'package:shared_preferences/shared_preferences.dart';

import '../constants/pref_keys.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  String? getPhoneNumber() {
    return _prefs.getString(PrefKeys.phoneNumber);
  }

  Future<void> setPhoneNumber(String value) {
    return _prefs.setString(PrefKeys.phoneNumber, value);
  }
}
