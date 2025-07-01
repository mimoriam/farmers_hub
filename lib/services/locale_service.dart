import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  // Asynchronous method to load the locale from SharedPreferences.
  Future<void> loadLocale() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    final String? language = await asyncPrefs.getString('language');

    if (language != null) {
      _locale = language == 'English' ? const Locale('en') : const Locale('ar');
    } else {
      _locale = const Locale('en'); // Set a default locale if none is stored.
    }
    notifyListeners();
  }

  // Method to change the locale and save the new preference.
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

    await asyncPrefs.setString('language', locale.languageCode == 'en' ? 'English' : 'Arabic');
    notifyListeners();
  }
}
