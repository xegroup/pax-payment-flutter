import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/pref_keys.dart';

class LocalizationService extends ChangeNotifier {
  LocalizationService({required SharedPreferences prefs}) : _prefs = prefs {
    final savedLocale = _prefs.getString(PrefKeys.locale);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        _currentLocale = Locale(parts[0], parts[1]);
      }
    }
    Intl.defaultLocale = '${_currentLocale.languageCode}_${_currentLocale.countryCode}';
  }

  final SharedPreferences _prefs;
  Locale _currentLocale = const Locale('en', 'GB');

  Locale get currentLocale => _currentLocale;

  List<Locale> get supportedLocales => const [
        Locale('en', 'GB'),
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('fr', 'FR'),
      ];

  void setLocale(Locale locale) {
    _currentLocale = locale;
    _prefs.setString(
      PrefKeys.locale,
      '${locale.languageCode}_${locale.countryCode}',
    );
    Intl.defaultLocale = '${locale.languageCode}_${locale.countryCode}';
    notifyListeners();
  }
}
