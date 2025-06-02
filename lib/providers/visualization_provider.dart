import 'dart:async';
import 'package:flutter/material.dart';
import '../models/algorithm_info.dart';
import '../services/algorithm_service.dart';
import '../models/algorithm_stepper.dart'; // CORRECTED AND FINAL PATH
import '../algorithms/sliding_window_stepper.dart';
import '../algorithms/bubble_sort_stepper.dart';
import '../algorithms/two_pointers_target_sum_stepper.dart';
import '../services/favorites_repository.dart'; // Import FavoritesRepository

class VisualizationProvider with ChangeNotifier {
  final AlgorithmService _algorithmService = AlgorithmService();
  final FavoritesRepository _favoritesRepository;

  AlgorithmInfo? _currentAlgorithm;
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, String> _inputValues =
      {}; // User-provided inputs for the algorithm
  AlgorithmStepper? _currentStepper;

  Timer? _playTimer;
  bool _isUiPlaying = false;
  double _animationSpeedFactor = 0.5; // 0.0 (fast) to 1.0 (slow)

  Set<String> _favoriteAlgorithmIds = {};

  VisualizationProvider({required FavoritesRepository favoritesRepository})
    : _favoritesRepository = favoritesRepository {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    _favoriteAlgorithmIds =
        await _favoritesRepository.loadFavoriteAlgorithmIds();
    notifyListeners();
  }

  // --- Getters ---
  AlgorithmInfo? get currentAlgorithm => _currentAlgorithm;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, String> get inputValues => _inputValues;

  // Getters that delegate to AlgorithmStepper's current state
  AlgorithmStepState? get currentStepState => _currentStepper?.currentStepState;
  List<int> get currentArray => _currentStepper?.currentStepState.array ?? [];
  Map<String, int?> get currentPointers =>
      _currentStepper?.currentStepState.pointers ?? {};
  Set<int> get highlightedIndices =>
      _currentStepper?.currentStepState.highlightedIndices ?? {};
  String get statusMessage =>
      _currentStepper?.currentStepState.statusMessage ??
      _errorMessageOrLoading();
  Map<String, dynamic> get currentMetrics =>
      _currentStepper?.currentStepState.metrics ?? {};
  bool get isAlgorithmDone => _currentStepper?.isDone ?? true;
  // int? get activeCodeLine => _currentStepper?.currentStepState.activeCodeLine; // If needed later

  bool get isPlaying => _isUiPlaying;
  double get animationSpeedFactor => _animationSpeedFactor;

  // Getter for the set of favorite algorithm IDs
  Set<String> get favoriteAlgorithmIds => _favoriteAlgorithmIds;

  String _errorMessageOrLoading() {
    if (_isLoading) return "Loading...";
    if (_errorMessage.isNotEmpty) return _errorMessage;
    if (_currentAlgorithm == null) return "No algorithm selected.";
    if (_currentStepper == null) return "Visualization not initialized.";
    return "Ready.";
  }

  // --- Favorite Methods ---
  bool isFavorite(String algorithmId) {
    return _favoriteAlgorithmIds.contains(algorithmId);
  }

  Future<void> toggleFavorite(String algorithmId) async {
    if (_favoriteAlgorithmIds.contains(algorithmId)) {
      _favoriteAlgorithmIds.remove(algorithmId);
      await _favoritesRepository.removeFavorite(algorithmId);
    } else {
      _favoriteAlgorithmIds.add(algorithmId);
      await _favoritesRepository.addFavorite(algorithmId);
    }
    notifyListeners();
  }

  // --- Core Logic ---
  Future<void> loadAlgorithmDetails(String algorithmId) async {
    _isLoading = true;
    _errorMessage = '';
    _currentAlgorithm = null;
    _inputValues = {};
    _currentStepper?.dispose();
    _currentStepper = null;
    _stopPlay();
    notifyListeners();

    try {
      final algorithm = _algorithmService.getAlgorithmById(algorithmId);
      if (algorithm != null) {
        _currentAlgorithm = algorithm;
        for (var param in algorithm.inputParams) {
          _inputValues[param.id] = param.defaultValue;
        }
        _initializeStepperForAlgorithm(algorithm);
      } else {
        _errorMessage = "Algorithm with ID '$algorithmId' not found.";
      }
    } catch (e) {
      _errorMessage = "Failed to load algorithm: ${e.toString()}";
    }
    _isLoading = false;
    notifyListeners();
  }

  void _initializeStepperForAlgorithm(AlgorithmInfo algorithm) {
    _currentStepper?.dispose();

    switch (algorithm.type) {
      case AlgorithmType.SLIDING_WINDOW_MAX_DIFF:
      case AlgorithmType.SLIDING_WINDOW_FIXED_SIZE:
        _currentStepper = SlidingWindowStepper();
        break;
      case AlgorithmType.BUBBLE_SORT:
        _currentStepper = BubbleSortStepper();
        break;
      case AlgorithmType.TWO_POINTERS_TARGET_SUM:
        _currentStepper = TwoPointersTargetSumStepper();
        break;
      }

    List<int> parsedArray = [];
    Map<String, dynamic> algoParams = {};

    final arrayInputParam = algorithm.inputParams.firstWhere(
      (p) => p.type == InputParamType.INTEGER_ARRAY_COMMA_SEPARATED,
      orElse:
          () => algorithm.inputParams.firstWhere(
            (p) => p.id.toLowerCase().contains("array"),
            orElse:
                () => AlgorithmInputParam(
                  id: "_dummy_array_",
                  label: "",
                  defaultValue: "",
                  type: InputParamType.INTEGER_ARRAY_COMMA_SEPARATED,
                ),
          ),
    );
    final rawArrayString =
        _inputValues[arrayInputParam.id] ?? arrayInputParam.defaultValue;
    try {
      parsedArray =
          rawArrayString.split(',').map((e) => int.parse(e.trim())).toList();
    } catch (e) {
      _errorMessage =
          "Invalid array input format for $rawArrayString: ${e.toString()}";
      parsedArray = [];
    }

    for (var param in algorithm.inputParams) {
      if (param.id != arrayInputParam.id) {
        if (param.type == InputParamType.INTEGER) {
          try {
            algoParams[param.id] = int.parse(
              _inputValues[param.id] ?? param.defaultValue,
            );
          } catch (e) {
            _errorMessage =
                "Invalid integer input for ${param.label}: ${e.toString()}";
            algoParams[param.id] = 0; // Default or error value
          }
        } else {
          algoParams[param.id] = _inputValues[param.id] ?? param.defaultValue;
        }
      }
    }

    try {
      _currentStepper!.initialize(
        initialArray: parsedArray,
        params: algoParams,
        algorithmType: algorithm.type,
      );
    } catch (e) {
      _errorMessage = "Error initializing stepper: ${e.toString()}";
      _currentStepper = null;
    }
    notifyListeners();
  }

  void updateInputValue(String paramId, String value) {
    _inputValues[paramId] = value;
    notifyListeners();
  }

  void reInitializeVisualization() {
    if (_currentAlgorithm == null) {
      _errorMessage = "No algorithm loaded to re-initialize.";
      notifyListeners();
      return;
    }
    _stopPlay();
    _initializeStepperForAlgorithm(_currentAlgorithm!);
  }

  void stepForward() {
    if (_currentStepper != null && !_currentStepper!.isDone) {
      _currentStepper!.nextStep();
    } else {
      _stopPlay();
    }
    notifyListeners(); // Ensure UI updates after stepForward
  }

  void resetAlgorithm() {
    _currentStepper?.reset();
    _stopPlay();
    notifyListeners(); // Ensure UI updates after reset
  }

  void setAnimationSpeedFactor(double factor) {
    _animationSpeedFactor = factor.clamp(0.0, 1.0);
    if (_isUiPlaying) {
      _stopPlay();
      _startPlay();
    }
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isUiPlaying) {
      _stopPlay();
    } else {
      _startPlay();
    }
  }

  void _startPlay() {
    if (_currentStepper == null || _currentStepper!.isDone) {
      _isUiPlaying = false;
      notifyListeners();
      return;
    }

    _isUiPlaying = true;
    notifyListeners();

    final minDelayMs = 100;
    final maxDelayMs = 2000;
    final delayMs =
        minDelayMs +
        ((maxDelayMs - minDelayMs) * _animationSpeedFactor).toInt();

    _playTimer?.cancel();
    _playTimer = Timer.periodic(Duration(milliseconds: delayMs), (timer) {
      if (_currentStepper != null && !_currentStepper!.isDone && _isUiPlaying) {
        _currentStepper!.nextStep();
        notifyListeners(); // Update UI on each step
      } else {
        _stopPlay();
      }
    });
  }

  void _stopPlay() {
    _playTimer?.cancel();
    _isUiPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    _currentStepper?.dispose();
    super.dispose();
  }
}

// Assuming AlgorithmLogicType might be something like this in your models:
// enum AlgorithmLogicType { SLIDING_WINDOW_MAX_EVENTS, SLIDING_WINDOW_MAX_DIFF, OTHER }
// And InputParamType in algorithm_info.dart
/*
enum InputParamType {
  STRING,
  INTEGER,
  DOUBLE,
  BOOLEAN,
  INTEGER_ARRAY_COMMA_SEPARATED, // For "1,2,3,4"
  // Add more types as needed
}
*/
