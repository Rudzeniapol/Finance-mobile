import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'isDarkMode';
  static const _localeKey = 'locale';

  ThemeMode _themeMode = ThemeMode.dark;
  String _locale = 'en';

  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _locale = prefs.getString(_localeKey) ?? 'en';
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<void> setLocale(String code) async {
    _locale = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }
}
