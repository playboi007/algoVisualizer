import 'package:flutter/foundation.dart';

import '../models/algorithm_stepper.dart';
import '../models/algorithm_info.dart'; // Import AlgorithmType

// Concrete state for the Sliding Window algorithm
class SlidingWindowStepState implements AlgorithmStepState {
  @override
  final List<int> array;
  @override
  final Map<String, int?> pointers; // e.g., {'L': leftPointer, 'R': rightPointer}
  @override
  final Set<int> highlightedIndices; // Indices currently in the window
  @override
  final String statusMessage;
  @override
  final int? activeCodeLine; // Optional, can be mapped later
  @override
  final Map<String, dynamic> metrics; // e.g., {'currentWindowSize': size, 'maxEvents': maxEvents}

  SlidingWindowStepState({
    required this.array,
    required this.pointers,
    required this.highlightedIndices,
    required this.statusMessage,
    this.activeCodeLine,
    required this.metrics,
  });
}

class SlidingWindowStepper extends AlgorithmStepper {
  late List<int> _internalArray;
  late int _windowConstraintW;
  late AlgorithmType _algorithmType; // To store the type of algorithm

  int _leftPointer = 0;
  int _rightPointer = 0;
  int _currentWindowSize = 0;
  int _maxEvents =
      0; // For MAX_DIFF, this is max window size. For FIXED_SIZE, this is current window element count.
  bool _isDone = false;

  late List<int> _initialArrayCopy;
  late Map<String, dynamic> _initialParams;
  late AlgorithmType _initialAlgorithmType; // Store for reset

  @override
  String get algorithmId =>
      _initialAlgorithmType == AlgorithmType.SLIDING_WINDOW_FIXED_SIZE
          ? 'sliding_window_fixed_size'
          : 'sliding_window_max_diff';

  @override
  String get referenceCodeSnippet => "";

  @override
  bool get isDone => _isDone;

  @override
  void initialize({
    required List<int> initialArray,
    required Map<String, dynamic> params,
    required AlgorithmType algorithmType, // Added algorithmType parameter
  }) {
    _initialArrayCopy = List.from(initialArray);
    _initialParams = Map.from(params);
    _initialAlgorithmType = algorithmType; // Store for reset

    _internalArray = List.from(initialArray);
    _algorithmType = algorithmType;

    if (_algorithmType == AlgorithmType.SLIDING_WINDOW_MAX_DIFF) {
      _internalArray.sort(); // Sort only for MAX_DIFF variant
    }

    _windowConstraintW = params['W'] as int? ?? 0;
    if (_windowConstraintW <= 0) {
      if (kDebugMode) {
        print(
        "Warning: Window constraint W (size/difference) is not positive. Algorithm might not behave as expected.",
      );
      }
      // For FIXED_SIZE, a W <= 0 is problematic. Could set _isDone = true here.
      if (_algorithmType == AlgorithmType.SLIDING_WINDOW_FIXED_SIZE) {
        _isDone = true;
      }
    }
    _resetInternalState();
    _publishState("Initialized. Click 'Next Step' or 'Play' to begin.");
  }

  void _resetInternalState() {
    _isDone = false;
    if (_internalArray.isEmpty ||
        (_algorithmType == AlgorithmType.SLIDING_WINDOW_FIXED_SIZE &&
            _windowConstraintW <= 0)) {
      _leftPointer = -1;
      _rightPointer = -1;
      _currentWindowSize = 0;
      _maxEvents = 0;
      _isDone = true;
      return;
    }

    _leftPointer = 0;
    _rightPointer = 0;

    if (_algorithmType == AlgorithmType.SLIDING_WINDOW_FIXED_SIZE) {
      // For fixed size, right pointer starts to form the first window
      _rightPointer = _windowConstraintW - 1;
      if (_rightPointer >= _internalArray.length) {
        _rightPointer = _internalArray.length - 1;
      }
      if (_rightPointer < 0) {
        _rightPointer =
            0; // Handle W=1 case where _rightPointer could be -1 initially
      }

      _currentWindowSize = _rightPointer - _leftPointer + 1;
      _maxEvents =
          _currentWindowSize; // Max events here is just the count in the current window
    } else {
      // SLIDING_WINDOW_MAX_DIFF
      _currentWindowSize = 1;
      _maxEvents = 1;
    }
    if (_internalArray.length == 1 &&
        _algorithmType == AlgorithmType.SLIDING_WINDOW_FIXED_SIZE) {
      _isDone = true; // If array has 1 element, first window is the only window
    }
  }

  @override
  void reset() {
    initialize(
      initialArray: _initialArrayCopy,
      params: _initialParams,
      algorithmType: _initialAlgorithmType,
    );
  }

  @override
  void nextStep() {
    if (_isDone || _internalArray.isEmpty) {
      _publishState(
        _isDone
            ? "Algorithm finished. Reset to start again."
            : "Array is empty or W is invalid.",
      );
      return;
    }

    String status;
    if (_algorithmType == AlgorithmType.SLIDING_WINDOW_FIXED_SIZE) {
      // Logic for fixed-size window
      if (_rightPointer < _internalArray.length - 1) {
        _rightPointer++;
        _leftPointer = _rightPointer - _windowConstraintW + 1;
        if (_leftPointer < 0) _leftPointer = 0;
        _currentWindowSize = _rightPointer - _leftPointer + 1;
        _maxEvents =
            _currentWindowSize; // Max events is the current window size
        status =
            "Window slid. L:$_leftPointer, R:$_rightPointer. Events: $_maxEvents (Size: $_currentWindowSize)";
      } else {
        _isDone = true;
        status =
            "Algorithm finished. Final window at L:$_leftPointer, R:$_rightPointer. Events: $_maxEvents";
      }
    } else {
      // Logic for SLIDING_WINDOW_MAX_DIFF (existing logic)
      if (_rightPointer < _internalArray.length - 1) {
        _rightPointer++;
        while (_internalArray[_rightPointer] - _internalArray[_leftPointer] >=
                _windowConstraintW &&
            _leftPointer < _rightPointer) {
          _leftPointer++;
        }
        _currentWindowSize = _rightPointer - _leftPointer + 1;
        if (_currentWindowSize > _maxEvents) {
          _maxEvents = _currentWindowSize;
        }
        status =
            "R moved to $_rightPointer. Window valid. Size: $_currentWindowSize. Max Size (Events): $_maxEvents.";
      } else {
        if (_leftPointer < _rightPointer) {
          _leftPointer++;
          _currentWindowSize = _rightPointer - _leftPointer + 1;
          status =
              "R at end. L moved to $_leftPointer. Size: $_currentWindowSize.";
        } else {
          _isDone = true;
          status = "Algorithm finished. Final Max Size (Events): $_maxEvents.";
        }
      }
    }
    _publishState(status);
  }

  void _publishState(String message) {
    Set<int> highlights = {};
    if (_leftPointer != -1 &&
        _rightPointer != -1 &&
        _leftPointer <= _rightPointer &&
        _rightPointer < _internalArray.length &&
        _internalArray.isNotEmpty) {
      for (int i = _leftPointer; i <= _rightPointer; i++) {
        highlights.add(i);
      }
    }

    final state = SlidingWindowStepState(
      array: List.unmodifiable(_internalArray),
      pointers: {'L': _leftPointer, 'R': _rightPointer},
      highlightedIndices: highlights,
      statusMessage: message,
      metrics: {
        'currentWindowSize': _currentWindowSize,
        'maxEvents':
            _maxEvents, // For FIXED_SIZE, this is #elements in window. For MAX_DIFF, it's max window length.
        if (_algorithmType == AlgorithmType.SLIDING_WINDOW_MAX_DIFF)
          'maxDiffConstraintW': _windowConstraintW,
        if (_algorithmType == AlgorithmType.SLIDING_WINDOW_FIXED_SIZE)
          'fixedWindowSizeW': _windowConstraintW,
      },
      activeCodeLine: null,
    );
    updateState(state);
  }
}
