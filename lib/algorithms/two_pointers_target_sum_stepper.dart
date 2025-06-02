import '../models/algorithm_stepper.dart';
import '../models/algorithm_info.dart'; // Import AlgorithmType

class TwoPointersTargetSumStepState implements AlgorithmStepState {
  @override
  final List<int> array;
  @override
  final Map<String, int?> pointers; // {'L': left, 'R': right}
  @override
  final Set<int> highlightedIndices; // left and right pointer indices
  @override
  final String statusMessage;
  @override
  final int? activeCodeLine;
  @override
  final Map<String, dynamic> metrics; // {'currentSum': sum, 'targetSum': target}

  TwoPointersTargetSumStepState({
    required this.array,
    required this.pointers,
    required this.highlightedIndices,
    required this.statusMessage,
    this.activeCodeLine,
    required this.metrics,
  });
}

class TwoPointersTargetSumStepper extends AlgorithmStepper {
  late List<int> _internalArray;
  late int _targetSum;
  late AlgorithmType _algorithmType; // Added

  late List<int> _initialArrayCopy;
  late Map<String, dynamic> _initialParams;
  late AlgorithmType _initialAlgorithmType; // Added for reset

  int _left = 0;
  int _right = 0;
  bool _isDone = false;
  bool _pairFound = false;

  @override
  String get algorithmId => 'two_pointers_target_sum';

  @override
  String get referenceCodeSnippet => ""; // Placeholder, load from AlgorithmInfo

  @override
  bool get isDone => _isDone;

  @override
  void initialize({
    required List<int> initialArray,
    required Map<String, dynamic> params,
    required AlgorithmType algorithmType, // Added to match interface
  }) {
    _initialArrayCopy = List.from(initialArray);
    _initialParams = Map.from(params);
    _initialAlgorithmType = algorithmType; // Store for reset
    _algorithmType = algorithmType; // Store it

    _internalArray = List.from(initialArray);
    // Crucial: Two Pointers for target sum assumes a SORTED array.
    _internalArray.sort();

    _targetSum = params['target'] as int? ?? 0;
    _resetInternalState();
    _publishState(
      "Initialized. Array: ${_internalArray.join(', ')}. Target: $_targetSum",
    );
  }

  void _resetInternalState() {
    _left = 0;
    _right = _internalArray.isNotEmpty ? _internalArray.length - 1 : 0;
    _isDone =
        _internalArray.length < 2; // Cannot find a pair if less than 2 elements
    _pairFound = false;
    if (_isDone) {
      _publishState("Array has less than 2 elements. Cannot find a pair.");
    }
  }

  @override
  void reset() {
    // Pass the stored algorithmType when re-initializing
    initialize(
      initialArray: _initialArrayCopy,
      params: _initialParams,
      algorithmType: _initialAlgorithmType,
    );
  }

  @override
  void nextStep() {
    if (_isDone) {
      String finalMessage =
          _pairFound
              ? "Pair found! Left: ${_internalArray[_left]}, Right: ${_internalArray[_right]}. Sum equals Target: $_targetSum."
              : "No pair found summing to $_targetSum. Pointers met.";
      _publishState(finalMessage);
      return;
    }

    if (_left >= _right) {
      _isDone = true;
      _pairFound =
          false; // Ensure this is set if loop terminates due to pointers crossing
      _publishState(
        "Pointers met or crossed. No pair found summing to $_targetSum.",
      );
      return;
    }

    Set<int> highlights = {_left, _right};
    int currentSum = _internalArray[_left] + _internalArray[_right];
    String status;

    if (currentSum == _targetSum) {
      _pairFound = true;
      _isDone = true;
      status =
          "SUCCESS! Sum of ${_internalArray[_left]} (at L:$_left) + ${_internalArray[_right]} (at R:$_right) = $currentSum, which equals Target $_targetSum.";
    } else if (currentSum < _targetSum) {
      status =
          "Sum ${_internalArray[_left]} + ${_internalArray[_right]} = $currentSum ( < $_targetSum). Incrementing Left pointer.";
      _left++;
    } else {
      // currentSum > _targetSum
      status =
          "Sum ${_internalArray[_left]} + ${_internalArray[_right]} = $currentSum ( > $_targetSum). Decrementing Right pointer.";
      _right--;
    }

    // Check again if pointers crossed after move, for final step state before being truly done
    if (!_isDone && _left >= _right) {
      _isDone =
          true; // Will be handled by the top _isDone check in next call or by the explicit check before this if block.
      // If we reach here and pair wasn't found, then no pair was found.
      if (!_pairFound) {
        status += " Pointers will cross. No pair found.";
      }
    }

    _publishState(status, highlights: highlights, currentSum: currentSum);
  }

  void _publishState(String message, {Set<int>? highlights, int? currentSum}) {
    final state = TwoPointersTargetSumStepState(
      array: List.unmodifiable(_internalArray),
      pointers: {
        'L': _left,
        'R': _right,
      }, // Using L and R for consistency with UI color map
      highlightedIndices:
          highlights ?? (_isDone && !_pairFound ? {} : {_left, _right}),
      statusMessage: message,
      metrics: {
        'targetSum': _targetSum,
        if (currentSum != null) 'currentSum': currentSum,
        'leftVal':
            _internalArray.isNotEmpty &&
                    _left >= 0 &&
                    _left < _internalArray.length
                ? _internalArray[_left]
                : null,
        'rightVal':
            _internalArray.isNotEmpty &&
                    _right >= 0 &&
                    _right < _internalArray.length
                ? _internalArray[_right]
                : null,
      },
      activeCodeLine: null, // TODO
    );
    updateState(state);
  }
}
