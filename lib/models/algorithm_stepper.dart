import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart'; // Required for @protected
import './algorithm_info.dart'; // Import AlgorithmType

/// Represents the state of the visualization at a single step of an algorithm.
/// Concrete stepper implementations will provide a concrete version of this.
abstract class AlgorithmStepState {
  List<int> get array; // The current state of the main array being visualized
  Map<String, int?>
  get pointers; // Key-value pairs for pointers, e.g., {\'L\': 0, \'R\': 1, \'i\': 2}. Nullable if a pointer is not set.
  Set<int>
  get highlightedIndices; // Indices of elements that should have a special highlight (e.g., being compared, swapped, or part of a window).
  String get statusMessage; // Message describing the current step or state.
  int?
  get activeCodeLine; // Optional: line number in the reference code snippet that corresponds to the current operation.
  Map<String, dynamic>
  get metrics; // Additional algorithm-specific metrics, e.g., {\'comparisons\': 10, \'swaps\': 3, \'currentWindowSize\': 5}.

  // Constructor for subclasses to implement
  // AlgorithmStepState();
}

/// Abstract base class for all algorithm steppers.
/// Each specific algorithm (e.g., Bubble Sort, Sliding Window) will have a concrete implementation.
abstract class AlgorithmStepper extends ChangeNotifier {
  AlgorithmStepState?
  _currentStepState; // Make nullable, will be set in initialize

  /// Initializes the algorithm with the input array and other parameters.
  /// This should set up the initial state for visualization.
  void initialize({
    required List<int> initialArray,
    required Map<String, dynamic>
    params, // For algorithm-specific parameters like W for sliding window
    required AlgorithmType algorithmType, // Added algorithmType
  });

  /// Advances the algorithm by one step and updates the currentStepState.
  void nextStep();

  /// Resets the algorithm to its initial state (based on the last call to initialize).
  void reset();

  /// Returns the current visualization state.
  /// Ensure _currentStepState is not null before accessing, or handle nullability.
  AlgorithmStepState get currentStepState {
    if (_currentStepState == null) {
      throw StateError("AlgorithmStepper not initialized or state is null.");
    }
    return _currentStepState!;
  }

  /// Indicates whether the algorithm has completed all its steps.
  bool get isDone;

  /// Provides the reference code snippet for the current algorithm.
  /// This might come from AlgorithmInfo or be defined directly in the stepper.
  String get referenceCodeSnippet;

  /// Provides the name or ID of the algorithm.
  String get algorithmId;

  /// Call this method in concrete steppers whenever the internal state changes
  /// such that the UI needs to be updated. This will typically be at the end of
  /// initialize(), nextStep(), and reset().
  @protected
  void updateState(AlgorithmStepState newState) {
    _currentStepState = newState;
    notifyListeners(); // Now available from ChangeNotifier
  }
}

// Example of a concrete AlgorithmStepState (not used directly yet)
// class BubbleSortStepState implements AlgorithmStepState {
//   @override
//   final List<int> array;
//   @override
//   final Map<String, int?> pointers; // e.g., {'i': 0, 'j': 1}
//   @override
//   final Set<int> highlightedIndices; // e.g., elements being compared
//   @override
//   final String statusMessage;
//   @override
//   final int? activeCodeLine;
//   @override
//   final Map<String, dynamic> metrics; // e.g., {'swaps': 0, 'comparisons': 0}

//   BubbleSortStepState({
//     required this.array,
//     required this.pointers,
//     required this.highlightedIndices,
//     required this.statusMessage,
//     this.activeCodeLine,
//     required this.metrics,
//   });
// }
