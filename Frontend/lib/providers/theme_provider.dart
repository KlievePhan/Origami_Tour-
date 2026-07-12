import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _pushNotificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void togglePushNotifications(bool isEnabled) {
    _pushNotificationsEnabled = isEnabled;
    notifyListeners();
  }
}
