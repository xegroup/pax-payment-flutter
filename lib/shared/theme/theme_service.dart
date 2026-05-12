import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_dark_theme.dart';
import 'app_light_theme.dart';
import 'pax_colors.dart';

class ThemeService extends ChangeNotifier {
  ThemeService({required SharedPreferences prefs}) : _prefs = prefs {
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
  }

  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeData get lightTheme => buildLightTheme();
  ThemeData get darkTheme => buildDarkTheme();

  // Legacy static palette — maps to Obsidian tokens.
  static const Color xeposWhite = PaxColors.white;
  static const Color xeposBlack = PaxColors.black;
  static const Color xeposPrimaryBlue = PaxColors.teal500;
  static const Color xeposButtonGreen = PaxColors.success;
  static const Color xeposTextGreen = PaxColors.successDark;
  static const Color xeposMediumGray = PaxColors.grey500;
  static const Color xeposInputFieldBg = PaxColors.grey50;
  static const Color xeposExitRed = PaxColors.error;
  static const Color xeposErrorRed = PaxColors.error;
  static const Color xeposBackground = PaxColors.grey950;
  static const Color xeposSolid = PaxColors.grey900;
  static const Color xeposTitleColor = PaxColors.teal600;
  static const Color xeposLightGray = PaxColors.grey100;
  static const Color xeposDarkGrayText = PaxColors.grey800;
  static const Color xeposHintText = PaxColors.grey600;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
