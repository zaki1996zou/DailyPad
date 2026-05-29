import 'package:fc_app3_dailypad/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final isDark = LocalStorageService.isDarkMode;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    final newIsDark = !isDarkMode;
    _themeMode = newIsDark ? ThemeMode.dark : ThemeMode.light;
    await LocalStorageService.setDarkMode(newIsDark);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    await LocalStorageService.setDarkMode(value);
    notifyListeners();
  }
}
