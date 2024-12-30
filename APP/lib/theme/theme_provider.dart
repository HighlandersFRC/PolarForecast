import 'package:flutter/material.dart';
import 'theme.dart';

class ThemeDataProvider extends ChangeNotifier {
  ThemeData _lightTheme = lightTheme(),
      _darkTheme = darkTheme(),
      _themeData = darkTheme();
  ThemeDataProvider() {}

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    if (_themeData.brightness == Brightness.light) {
      _themeData = _darkTheme;
    } else {
      _themeData = _lightTheme;
    }
    notifyListeners();
  }
}
