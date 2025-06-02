import 'package:flutter/foundation.dart';
import '../services/progress_repository.dart';
import '../services/algorithm_service.dart'; // To get total counts for progress calculation
import '../models/algorithm_info.dart'; // For AlgorithmCategory enum
import 'dart:async';

class ProgressProvider with ChangeNotifier {
  final ProgressRepository _repository;
  final AlgorithmService
  _algorithmService; // To get all algorithms and categories

  Set<String> _viewedAlgorithmIds = {};
  Set<String> _exploredCategoryNames = {};
  int _timeSpentInSeconds = 0; // New field for time tracking

  bool _isLoading = false;
  Timer? _sessionTimer; // Timer to track current session time
  DateTime? _sessionStartTime;

  ProgressProvider(this._repository, this._algorithmService) {
    loadProgress();
    _startSessionTimer();
  }

  // --- Getters ---
  bool get isLoading => _isLoading;
  Set<String> get viewedAlgorithmIds => _viewedAlgorithmIds;
  Set<String> get exploredCategoryNames => _exploredCategoryNames;
  int get timeSpentInSeconds => _timeSpentInSeconds;

  String get formattedTimeSpent {
    final duration = Duration(seconds: _timeSpentInSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "${hours}h ${twoDigits(minutes)}m";
    } else if (minutes > 0) {
      return "${twoDigits(minutes)}m ${twoDigits(seconds)}s";
    } else {
      return "${twoDigits(seconds)}s";
    }
  }

  int get totalAlgorithmsAvailable =>
      _algorithmService.getAllAlgorithms().length;
  int get totalCategoriesAvailable {
    return AlgorithmCategory.values
        .where(
          (cat) => _algorithmService.getAllAlgorithms().any(
            (alg) => alg.category == cat,
          ),
        )
        .length;
  }

  double get overallProgress {
    if (totalAlgorithmsAvailable == 0) return 0.0;
    return _viewedAlgorithmIds.length / totalAlgorithmsAvailable;
  }

  int get algorithmsViewedCount => _viewedAlgorithmIds.length;
  int get categoriesExploredCount => _exploredCategoryNames.length;

  Map<AlgorithmCategory, ({int completed, int total})> get progressByCategory {
    final Map<AlgorithmCategory, ({int completed, int total})> progressMap = {};
    final allAlgorithms = _algorithmService.getAllAlgorithms();

    for (var category in AlgorithmCategory.values) {
      final algorithmsInCategory =
          allAlgorithms.where((alg) => alg.category == category).toList();
      if (algorithmsInCategory.isNotEmpty) {
        final viewedInCategory =
            algorithmsInCategory
                .where((alg) => _viewedAlgorithmIds.contains(alg.id))
                .length;
        progressMap[category] = (
          completed: viewedInCategory,
          total: algorithmsInCategory.length,
        );
      }
    }
    return progressMap;
  }

  // --- Public Methods ---
  Future<void> loadProgress() async {
    _isLoading = true;
    notifyListeners();

    _viewedAlgorithmIds = await _repository.loadViewedAlgorithmIds();
    _exploredCategoryNames = await _repository.loadExploredCategoryNames();
    _timeSpentInSeconds = await _repository.loadTimeSpentSeconds(); // Load time

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAlgorithmAsViewed(String algorithmId) async {
    if (_viewedAlgorithmIds.add(algorithmId)) {
      await _repository.saveViewedAlgorithmIds(_viewedAlgorithmIds);
      // Also mark its category as explored
      final algorithm = _algorithmService.getAlgorithmById(algorithmId);
      if (algorithm != null) {
        await markCategoryAsExplored(algorithm.category);
      }
      notifyListeners();
    }
  }

  Future<void> markCategoryAsExplored(AlgorithmCategory category) async {
    // Store category name as string as enums can be tricky with persistence depending on method
    final categoryName = category.toString();
    if (_exploredCategoryNames.add(categoryName)) {
      await _repository.saveExploredCategoryNames(_exploredCategoryNames);
      notifyListeners();
    }
  }

  // Method to add time spent, typically called periodically or when app pauses/resumes
  Future<void> _addTimeSpent(Duration duration) async {
    if (duration.inSeconds <= 0) return; // No negative or zero time
    _timeSpentInSeconds += duration.inSeconds;
    await _repository.saveTimeSpentSeconds(_timeSpentInSeconds);
    notifyListeners(); // Update UI if it displays time spent live
  }

  // --- Session Timer Logic (Basic) ---
  // This is a simple way to track time while the app is in the foreground.
  // More robust solutions might involve AppLifecycleListener.
  void _startSessionTimer() {
    _sessionStartTime = DateTime.now();
    // Periodically save accumulated time, e.g., every minute
    _sessionTimer?.cancel(); // Cancel any existing timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_sessionStartTime != null) {
        final now = DateTime.now();
        final durationThisPeriod = now.difference(_sessionStartTime!);
        _addTimeSpent(durationThisPeriod);
        _sessionStartTime = now; // Reset start time for the next period
      }
    });
  }

  // Call this when the app is about to be paused or disposed
  // For example, in main.dart using AppLifecycleListener or in the dispose method of the root widget
  void recordFinalSessionTime() {
    _sessionTimer?.cancel();
    if (_sessionStartTime != null) {
      final durationThisPeriod = DateTime.now().difference(_sessionStartTime!);
      _addTimeSpent(durationThisPeriod);
      _sessionStartTime = null;
    }
  }

  Future<void> clearAllProgressData() async {
    _isLoading = true;
    notifyListeners();
    await _repository.clearAllProgress();
    _viewedAlgorithmIds = {};
    _exploredCategoryNames = {};
    _timeSpentInSeconds = 0; // Reset time spent
    _sessionStartTime = DateTime.now(); // Reset session start for new tracking
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    recordFinalSessionTime(); // Ensure any remaining time is recorded
    super.dispose();
  }
}
