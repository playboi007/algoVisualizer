import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepository {
  static const String _viewedAlgorithmsKey = 'viewed_algorithms';
  static const String _exploredCategoriesKey = 'explored_categories';
  static const String _timeSpentSecondsKey = 'time_spent_seconds';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Viewed Algorithms ---
  Future<Set<String>> loadViewedAlgorithmIds() async {
    final prefs = await _prefs;
    final List<String>? ids = prefs.getStringList(_viewedAlgorithmsKey);
    return ids?.toSet() ?? {};
  }

  Future<void> saveViewedAlgorithmIds(Set<String> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList(_viewedAlgorithmsKey, ids.toList());
  }

  // --- Explored Categories ---
  Future<Set<String>> loadExploredCategoryNames() async {
    final prefs = await _prefs;
    final List<String>? names = prefs.getStringList(_exploredCategoriesKey);
    return names?.toSet() ?? {};
  }

  Future<void> saveExploredCategoryNames(Set<String> names) async {
    final prefs = await _prefs;
    await prefs.setStringList(_exploredCategoriesKey, names.toList());
  }

  // --- Time Spent Tracking ---
  Future<int> loadTimeSpentSeconds() async {
    final prefs = await _prefs;
    return prefs.getInt(_timeSpentSecondsKey) ?? 0;
  }

  Future<void> saveTimeSpentSeconds(int seconds) async {
    final prefs = await _prefs;
    await prefs.setInt(_timeSpentSecondsKey, seconds);
  }

  // Method to clear all progress (useful for testing or reset feature)
  Future<void> clearAllProgress() async {
    final prefs = await _prefs;
    await prefs.remove(_viewedAlgorithmsKey);
    await prefs.remove(_exploredCategoriesKey);
    await prefs.remove(_timeSpentSecondsKey);
  }
}
