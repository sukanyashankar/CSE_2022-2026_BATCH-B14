import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _pinKey = 'sos_pin';
  static const String _onboardedKey = 'is_onboarded';

  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  static Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, value);
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  static const String _shakeKey = "shake_enabled";

  static Future<void> setShakeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shakeKey, value);
  }

  static Future<bool> isShakeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shakeKey) ?? false;
  }

  static const String _darkModeKey = "dark_mode";

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }
}
