import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Toggles the theme and notifies listeners of the change.
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}