import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/translations/localization_service.dart';

class MySharedPref {
  // prevent making instance
  MySharedPref._();

  // STORING KEYS
  static const String _currentLocalKey = 'current_local';
  static const String _lightThemeKey = 'is_theme_light';
  static const String _card1CityKey = 'card1_city';
  static const String _card2CityKey = 'card2_city';

  // get storage
  static late SharedPreferences _sharedPreferences;

  static String getCard1City() => _sharedPreferences.getString(_card1CityKey) ?? 'London';
  static Future<void> setCard1City(String city) => _sharedPreferences.setString(_card1CityKey, city);

  static String getCard2City() => _sharedPreferences.getString(_card2CityKey) ?? 'Cairo';
  static Future<void> setCard2City(String city) => _sharedPreferences.setString(_card2CityKey, city);

  /// init get storage services
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static setStorage(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  /// set theme current type as light theme
  static Future<void> setThemeIsLight(bool lightTheme) =>
      _sharedPreferences.setBool(_lightThemeKey, lightTheme);

  /// get if the current theme type is light
  static bool getThemeIsLight() =>
      _sharedPreferences.getBool(_lightThemeKey) ??
      true; // todo set the default theme (true for light, false for dark)

  /// save current locale
  static Future<void> setCurrentLanguage(String languageCode) =>
      _sharedPreferences.setString(_currentLocalKey, languageCode);

  /// get current locale
  static Locale getCurrentLocal() {
    String? langCode = _sharedPreferences.getString(_currentLocalKey);
    // default language is english
    if (langCode == null) {
      return LocalizationService.defaultLanguage;
    }
    return LocalizationService.supportedLanguages[langCode]!;
  }

  /// clear all data from shared pref
  static Future<void> clear() async => await _sharedPreferences.clear();
}
