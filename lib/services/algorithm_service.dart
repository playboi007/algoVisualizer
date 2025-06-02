import 'package:flutter/foundation.dart';

import '../models/algorithm_info.dart';

class AlgorithmService {
  final List<AlgorithmInfo> _algorithms = [
    AlgorithmInfo(
      id: "sliding_window_max_events",
      name: "Max Events in Sliding Window",
      description:
          "Calculates the maximum number of events (from a sorted list of timestamps) that occur within a given time window W.",
      category: AlgorithmCategory.SLIDING_WINDOW,
      type: AlgorithmType.SLIDING_WINDOW_MAX_DIFF,
      referenceCodeSnippet: '''
class Solution {
    public int maxEventsInWindow(int[] timestamps, int W) {
        // Ensure timestamps are sorted for this logic to make sense
        // Arrays.sort(timestamps); // If not guaranteed to be sorted

        int left = 0;
        int maxCount = 0;

        for (int right = 0; right < timestamps.length; right++) {
            // Shrink from the left until window fits within W seconds
            // (timestamps[right] - timestamps[left]) is the current window's time span
            while (timestamps[right] - timestamps[left] > W) {
                left++;
            }
            // Current window size (number of events)
            int windowSize = right - left + 1;
            if (windowSize > maxCount) {
                maxCount = windowSize;
            }
        }
        return maxCount;
    }
}
''',
      referenceCodeLanguage: "Java",
      visualizationType: VisualizationType.ARRAY_1D,
      inputParams: [
        AlgorithmInputParam(
          id: "timestamps",
          label: "Timestamps (sorted, comma-separated)",
          defaultValue: "1, 2, 5, 6, 8, 10, 12, 15",
          type: InputParamType.INTEGER_ARRAY_COMMA_SEPARATED,
          hintText: "e.g., 1,2,5,6,8,10",
        ),
        AlgorithmInputParam(
          id: "w",
          label: "Window (W)",
          defaultValue: "5",
          type: InputParamType.INTEGER,
          hintText: "e.g., 5",
        ),
      ],
      timeComplexity: "O(n)",
      spaceComplexity: "O(1)",
      notes:
          "This algorithm assumes the input timestamps are already sorted. The window slides from left to right.",
    ),
    AlgorithmInfo(
      id: "bubble_sort",
      name: "Bubble Sort",
      description:
          "A simple comparison-based sorting algorithm. It repeatedly steps through the list, compares adjacent elements, and swaps them if they are in the wrong order. The pass through the list is repeated until no swaps are needed, which indicates that the list is sorted.",
      category: AlgorithmCategory.SORTING,
      type: AlgorithmType.BUBBLE_SORT,
      referenceCodeSnippet: '''
void bubbleSort(int arr[]) {
    int n = arr.length;
    boolean swapped;
    for (int i = 0; i < n - 1; i++) {
        swapped = false;
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                // Swap arr[j] and arr[j+1]
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
                swapped = true;
            }
        }
        // If no two elements were swapped by inner loop, then break
        if (!swapped) break;
    }
}
''',
      referenceCodeLanguage: "Java",
      visualizationType: VisualizationType.ARRAY_1D,
      inputParams: [
        AlgorithmInputParam(
          id: "array",
          label: "Array (comma-separated numbers)",
          defaultValue: "5, 1, 4, 2, 8",
          type: InputParamType.INTEGER_ARRAY_COMMA_SEPARATED,
          hintText: "e.g., 64,34,25,12,22,11,90",
        ),
      ],
      timeComplexity: "O(n^2) in worst/average case, O(n) in best case",
      spaceComplexity: "O(1)",
      notes:
          "Bubble sort is known for its simplicity but is inefficient for large lists.",
    ),
    // New Algorithm: Two Pointers - Target Sum
    AlgorithmInfo(
      id: "two_pointers_target_sum",
      name: "Two Pointers - Target Sum",
      description:
          "Given a sorted array and a target, find if there exists any pair of elements such that their sum is equal to the target. Uses two pointers, one from each end of the array.",
      category: AlgorithmCategory.TWO_POINTERS,
      type: AlgorithmType.TWO_POINTERS_TARGET_SUM,
      referenceCodeSnippet: '''
// Assumes array is sorted
static boolean twoSum(int[] arr, int target) {
    int left = 0, right = arr.length - 1;
    while (left < right) {
        int sum = arr[left] + arr[right];
        if (sum == target) return true;
        else if (sum < target) left++;
        else right--;
    }
    return false;
}
''',
      referenceCodeLanguage: "Java",
      visualizationType: VisualizationType.ARRAY_1D,
      inputParams: [
        AlgorithmInputParam(
          id: "array",
          label: "Sorted Array (comma-separated)",
          defaultValue: "-8, 1, 4, 6, 10, 45",
          type: InputParamType.INTEGER_ARRAY_COMMA_SEPARATED,
          hintText: "e.g., 1,2,3,4,10",
        ),
        AlgorithmInputParam(
          id: "target",
          label: "Target Sum",
          defaultValue: "16",
          type: InputParamType.INTEGER,
          hintText: "e.g., 70",
        ),
      ],
      timeComplexity: "O(n)",
      spaceComplexity:
          "O(1) (if array sorting is not considered part of this specific step, otherwise O(log n) or O(n) for sorting)",
      notes:
          "This technique relies on the array being sorted. The pointers move inwards until they meet or a pair is found.",
    ),
    // Add more AlgorithmInfo objects here for other algorithms
  ];

  List<AlgorithmInfo> getAllAlgorithms() => _algorithms;

  AlgorithmInfo? getAlgorithmById(String id) {
    try {
      return _algorithms.firstWhere((alg) => alg.id == id);
    } catch (e) {
      // If no element is found, firstWhere throws a StateError.
      // You can return null or handle it as appropriate.
      if (kDebugMode) {
        print("Algorithm with ID '$id' not found.");
      }
      return null;
    }
  }
}
