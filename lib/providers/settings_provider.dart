import 'package:flutter/material.dart';
import '../services/settings_repository.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;
  double _defaultAnimationSpeed = 0.5; // 0.0 (fast) to 1.0 (slow)
  // String? _preferredCodeLanguage; // For future use

  bool _isLoading = false;

  SettingsProvider(this._repository) {
    loadSettings();
  }

  // --- Getters ---
  ThemeMode get themeMode => _themeMode;
  double get defaultAnimationSpeed => _defaultAnimationSpeed;
  // String? get preferredCodeLanguage => _preferredCodeLanguage;
  bool get isLoading => _isLoading;

  // --- Public Methods ---
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _themeMode = await _repository.loadThemeMode();
    _defaultAnimationSpeed = await _repository.loadDefaultAnimationSpeed();
    // _preferredCodeLanguage = await _repository.loadPreferredCodeLanguage();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _repository.saveThemeMode(_themeMode);
  }

  Future<void> updateDefaultAnimationSpeed(double speed) async {
    final clampedSpeed = speed.clamp(0.0, 1.0);
    if (clampedSpeed == _defaultAnimationSpeed) return;
    _defaultAnimationSpeed = clampedSpeed;
    notifyListeners();
    await _repository.saveDefaultAnimationSpeed(_defaultAnimationSpeed);
    // Potentially notify VisualizationProvider if it uses this as a default
  }

  /*
  Future<void> updatePreferredCodeLanguage(String? language) async {
    if (language == _preferredCodeLanguage) return;
    _preferredCodeLanguage = language;
    notifyListeners();
    if (language != null) {
      await _repository.savePreferredCodeLanguage(language);
    } else {
      // Handle clearing the preference if needed, e.g. prefs.remove(key)
    }
  }
  */
}
