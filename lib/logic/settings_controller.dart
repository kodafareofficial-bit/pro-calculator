import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculator_engine.dart';

/// تنظیمات کاربر که بین اجراها ذخیره می‌شود.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    final rawTheme = _prefs.getString(_kTheme);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == rawTheme,
      orElse: () => ThemeMode.system,
    );
    _persianDigits = _prefs.getBool(_kPersian) ?? true;
    _haptics = _prefs.getBool(_kHaptics) ?? true;
    _scientific = _prefs.getBool(_kScientific) ?? false;
    _angleMode = (_prefs.getBool(_kDegrees) ?? true)
        ? AngleMode.degrees
        : AngleMode.radians;
  }

  static const _kTheme = 'settings.theme';
  static const _kPersian = 'settings.persianDigits';
  static const _kHaptics = 'settings.haptics';
  static const _kScientific = 'settings.scientific';
  static const _kDegrees = 'settings.degrees';

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  bool _persianDigits = true;
  bool _haptics = true;
  bool _scientific = false;
  AngleMode _angleMode = AngleMode.degrees;

  ThemeMode get themeMode => _themeMode;
  bool get persianDigits => _persianDigits;
  bool get haptics => _haptics;
  bool get scientific => _scientific;
  AngleMode get angleMode => _angleMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_kTheme, mode.name);
  }

  Future<void> setPersianDigits(bool value) async {
    if (value == _persianDigits) return;
    _persianDigits = value;
    notifyListeners();
    await _prefs.setBool(_kPersian, value);
  }

  Future<void> setHaptics(bool value) async {
    if (value == _haptics) return;
    _haptics = value;
    notifyListeners();
    await _prefs.setBool(_kHaptics, value);
  }

  Future<void> toggleScientific() async {
    _scientific = !_scientific;
    notifyListeners();
    await _prefs.setBool(_kScientific, _scientific);
  }

  Future<void> toggleAngleMode() async {
    _angleMode = _angleMode == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;
    notifyListeners();
    await _prefs.setBool(_kDegrees, _angleMode == AngleMode.degrees);
  }
}
