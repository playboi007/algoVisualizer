// lib/models/algorithm_info.dart

enum AlgorithmCategory {
  SLIDING_WINDOW,
  SORTING,
  SEARCHING,
  TWO_POINTERS,
  GRAPH,
  TREE,
  DYNAMIC_PROGRAMMING,
  STRING,
  MATH,
  OTHER,
}

enum AlgorithmType {
  SLIDING_WINDOW_MAX_DIFF,
  SLIDING_WINDOW_FIXED_SIZE, // New type for fixed-size window operations
  BUBBLE_SORT,
  TWO_POINTERS_TARGET_SUM,
}

enum VisualizationType {
  ARRAY_1D, // For algorithms operating on a single list/array
  // Future: ARRAY_2D, GRAPH_VIS, TREE_VIS, etc.
}

enum InputParamType {
  INTEGER_ARRAY_COMMA_SEPARATED, // e.g., "1,2,3,4,5"
  INTEGER, // e.g., "5"
  STRING, // e.g., "hello"
  STRING_ARRAY_COMMA_SEPARATED, // e.g., "apple,banana,orange"
}

// Describes the input fields an algorithm expects
class AlgorithmInputParam {
  final String
  id; // e.g., "timestamps", "windowSize", "arrayToSort", "targetValue"
  final String
  label; // User-friendly label, e.g., "Timestamps (comma-separated)"
  final String defaultValue;
  final InputParamType type;
  final String? hintText; // Optional hint for the text field

  AlgorithmInputParam({
    required this.id,
    required this.label,
    required this.defaultValue,
    required this.type,
    this.hintText,
  });
}

class AlgorithmInfo {
  final String id; // Unique identifier, e.g., "sliding_window_max_events"
  final String name;
  final String description;
  final AlgorithmCategory category;
  final String referenceCodeSnippet;
  final String referenceCodeLanguage; // e.g., "Java", "Python", "Dart"
  final VisualizationType visualizationType;
  final List<AlgorithmInputParam> inputParams;
  final String? timeComplexity; // e.g., "O(n)", "O(n log n)"
  final String? spaceComplexity; // e.g., "O(1)", "O(n)"
  final String?
  notes; // Any additional notes or explanations about the algorithm
  final AlgorithmType type;

  AlgorithmInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.referenceCodeSnippet,
    required this.referenceCodeLanguage,
    required this.visualizationType,
    required this.inputParams,
    this.timeComplexity,
    this.spaceComplexity,
    this.notes,
    required this.type,
  });
}
