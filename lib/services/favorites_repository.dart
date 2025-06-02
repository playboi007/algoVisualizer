import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  static const String _favoriteAlgorithmIdsKey = 'favorite_algorithm_ids';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Set<String>> loadFavoriteAlgorithmIds() async {
    final prefs = await _prefs;
    final List<String>? ids = prefs.getStringList(_favoriteAlgorithmIdsKey);
    return ids?.toSet() ?? {};
  }

  Future<void> saveFavoriteAlgorithmIds(Set<String> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList(_favoriteAlgorithmIdsKey, ids.toList());
  }

  Future<void> addFavorite(String algorithmId) async {
    final currentFavorites = await loadFavoriteAlgorithmIds();
    if (currentFavorites.add(algorithmId)) {
      await saveFavoriteAlgorithmIds(currentFavorites);
    }
  }

  Future<void> removeFavorite(String algorithmId) async {
    final currentFavorites = await loadFavoriteAlgorithmIds();
    if (currentFavorites.remove(algorithmId)) {
      await saveFavoriteAlgorithmIds(currentFavorites);
    }
  }

  Future<bool> isFavorite(String algorithmId) async {
    final currentFavorites = await loadFavoriteAlgorithmIds();
    return currentFavorites.contains(algorithmId);
  }
}
