import '../models/algorithm_stepper.dart';
import '../models/algorithm_info.dart'; // Import AlgorithmType

class BubbleSortStepState implements AlgorithmStepState {
  @override
  final List<int> array;
  @override
  final Map<String, int?> pointers; // {'i': outerLoopIndex, 'j': innerLoopIndex}
  @override
  final Set<int> highlightedIndices; // Indices being compared or just swapped
  @override
  final String statusMessage;
  @override
  final int? activeCodeLine; // TODO: Map to code lines
  @override
  final Map<String, dynamic> metrics; // {'comparisons': count, 'swaps': count}

  BubbleSortStepState({
    required this.array,
    required this.pointers,
    required this.highlightedIndices,
    required this.statusMessage,
    this.activeCodeLine,
    required this.metrics,
  });
}

class BubbleSortStepper extends AlgorithmStepper {
  late List<int> _internalArray;
  late List<int> _initialArrayCopy;
  late AlgorithmType
  _algorithmType; // Added, though not strictly used by BubbleSort logic

  // Bubble Sort specific state
  int _i = 0; // Outer loop index
  int _j = 0; // Inner loop index (comparison index)
  bool _swappedInCurrentPass = false;
  bool _isDone = false;
  int _n = 0; // Length of the array

  int _comparisonCount = 0;
  int _swapCount = 0;

  @override
  String get algorithmId => 'bubble_sort';

  @override
  String get referenceCodeSnippet => ""; // Placeholder

  @override
  bool get isDone => _isDone;

  @override
  void initialize({
    required List<int> initialArray,
    required Map<String, dynamic> params, // Not used by bubble sort directly
    required AlgorithmType algorithmType, // Added to match interface
  }) {
    _initialArrayCopy = List.from(initialArray);
    _internalArray = List.from(initialArray);
    _algorithmType = algorithmType; // Store it
    _n = _internalArray.length;
    _resetInternalState();
    _publishState(
      "Initialized Bubble Sort. Array: ${_internalArray.join(', ')}",
    );
  }

  void _resetInternalState() {
    _i = 0;
    _j = 0;
    _swappedInCurrentPass = false;
    _isDone = _n <= 1; // Already sorted if 0 or 1 element
    _comparisonCount = 0;
    _swapCount = 0;
    if (_internalArray.isNotEmpty && !_isDone) {
      _publishState("Ready to sort. Pass ${_i + 1}.");
    } else if (_isDone) {
      _publishState("Array is empty or has only one element. Already sorted.");
    }
  }

  @override
  void reset() {
    // Re-initialize with stored initial values and type
    // Since BubbleSort's initialize doesn't use params beyond array, we can simplify if needed,
    // but for consistency with the interface change, we keep it general.
    // However, the current structure of this stepper re-initializes _internalArray
    // and calls _resetInternalState directly, so we don't strictly need to call full initialize here.
    // For now, just ensuring it takes algorithmType if we were to call initialize().
    // Actual reset logic for BubbleSort:
    _internalArray = List.from(_initialArrayCopy);
    // _algorithmType remains from the initial call to initialize.
    _resetInternalState();
    if (!_isDone) {
      _publishState("Bubble Sort reset. Array: ${_internalArray.join(', ')}");
    } else {
      _publishState("Array is empty or has only one element. Already sorted.");
    }
  }

  @override
  void nextStep() {
    if (_isDone) {
      _publishState(
        "Algorithm finished. Final array: ${_internalArray.join(', ')}",
      );
      return;
    }

    String status;
    Set<int> currentHighlights = {};

    if (_i < _n - 1) {
      if (_j < _n - _i - 1) {
        _comparisonCount++;
        currentHighlights.add(_j);
        currentHighlights.add(_j + 1);
        status =
            "Comparing ${_internalArray[_j]} (at index $_j) and ${_internalArray[_j + 1]} (at index ${_j + 1}).";

        if (_internalArray[_j] > _internalArray[_j + 1]) {
          // Swap
          int temp = _internalArray[_j];
          _internalArray[_j] = _internalArray[_j + 1];
          _internalArray[_j + 1] = temp;
          _swappedInCurrentPass = true;
          _swapCount++;
          status += " Swapped. Array: ${_internalArray.join(', ')}.";
        } else {
          status += " No swap needed.";
        }
        _j++;
      } else {
        // End of inner loop (pass completed)
        if (!_swappedInCurrentPass && _i > 0) {
          // Optimization: if no swaps in a full pass (after first pass), array is sorted
          _isDone = true;
          status =
              "Pass ${_i + 1} completed. No swaps in this pass. Array sorted: ${_internalArray.join(', ')}.";
        } else {
          status = "Pass ${_i + 1} completed. Starting next pass.";
          _i++;
          _j = 0;
          _swappedInCurrentPass = false;
          if (_i >= _n - 1) {
            // All passes completed
            _isDone = true;
            status =
                "All passes completed. Array sorted: ${_internalArray.join(', ')}.";
          }
        }
      }
    } else {
      // Should have been caught by _i < _n - 1 or _isDone set earlier
      _isDone = true;
      status = "Array sorted: ${_internalArray.join(', ')}.";
    }

    if (_isDone) {
      currentHighlights.clear(); // No highlights when done
    }

    _publishState(status, highlights: currentHighlights);
  }

  void _publishState(String message, {Set<int>? highlights}) {
    final state = BubbleSortStepState(
      array: List.unmodifiable(_internalArray),
      pointers: {
        'i': _i < _n - 1 ? _i : null,
        'j': !_isDone && _j < _n - (_i) - 1 ? _j : null,
      }, // j can be out of bound for next step after pass ends
      highlightedIndices: highlights ?? {},
      statusMessage: message,
      metrics: {
        'comparisons': _comparisonCount,
        'swaps': _swapCount,
        'current_pass': _i + 1, // Pass number (1-indexed)
      },
      activeCodeLine: null, // TODO
    );
    updateState(state);
  }
}
