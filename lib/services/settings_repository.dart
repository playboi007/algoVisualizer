import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _themeModeKey = 'theme_mode';
  static const String _defaultAnimationSpeedKey = 'default_animation_speed';
  // static const String _preferredCodeLanguageKey = 'preferred_code_language'; // For future use

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Theme Mode ---
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await _prefs;
    final String? themeModeString = prefs.getString(_themeModeKey);
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system; // Default to system
    }
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeModeKey, themeMode.name);
  }

  // --- Default Animation Speed ---
  // Stored as a double between 0.0 (fast) and 1.0 (slow)
  Future<double> loadDefaultAnimationSpeed() async {
    final prefs = await _prefs;
    // Default to 0.5 if not set (medium speed)
    return prefs.getDouble(_defaultAnimationSpeedKey) ?? 0.5;
  }

  Future<void> saveDefaultAnimationSpeed(double speed) async {
    final prefs = await _prefs;
    await prefs.setDouble(_defaultAnimationSpeedKey, speed.clamp(0.0, 1.0));
  }

  // --- Preferred Code Language (Example for future) ---
  /*
  Future<String?> loadPreferredCodeLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_preferredCodeLanguageKey);
  }

  Future<void> savePreferredCodeLanguage(String language) async {
    final prefs = await _prefs;
    await prefs.setString(_preferredCodeLanguageKey, language);
  }
  */
}
