import 'dart:developer';

import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);

  getThemeMode() => _themeMode;

  setThemeMode(ThemeMode mode) async {
        log('Theme ThemeNotifier ');

    _themeMode = mode;
    notifyListeners();
  }
}
