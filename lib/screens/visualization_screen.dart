import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/algorithm_info.dart';
import '../providers/visualization_provider.dart';
import 'package:flutter_highlight/flutter_highlight.dart'; // For code syntax highlighting
import '../providers/progress_provider.dart';



// Define a map for pointer colors - this could be part of a theme or constants file later
const Map<String, Color> _pointerColors = {
  'L': Colors.blueAccent, // Sliding Window Left
  'R': Colors.pinkAccent, // Sliding Window Right
  'i': Colors.greenAccent, // Bubble Sort outer loop
  'j': Colors.orangeAccent, // Bubble Sort inner loop / comparison
  // Add more as needed
};
const Color _multiplePointersColor = Colors.purpleAccent;
const Color _highlightedColor =
    Colors.indigoAccent; // General highlight / In Window

class VisualizationScreen extends StatefulWidget {
  final String algorithmId;

  const VisualizationScreen({super.key, required this.algorithmId});

  @override
  VisualizationScreenState createState() => VisualizationScreenState();
}

class VisualizationScreenState extends State<VisualizationScreen> {
  // Placeholder state variables - these will be moved to/managed by VisualizationProvider
  // int _leftPointer = -1; // -1 indicates not set
  // int _rightPointer = -1;
  // int _currentWindowSize = 0;
  // final int _maxEvents = 0; // This was already final, consider if it should be from provider
  // String _statusMessage = \"Initialized. Click 'Next Step' or 'Play' to begin.\";
  // final List<int> _timestamps = [1, 2, 5, 6, 8, 10, 12, 15]; // Example data
  // bool _isPlaying = false;
  // final int _windowW = 5; // Example fixed window, W will now come from provider

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load algorithm details first
      Provider.of<VisualizationProvider>(
        context,
        listen: false,
      ).loadAlgorithmDetails(widget.algorithmId);

      // Then, mark as viewed (if not already)
      // Ensure ProgressProvider is also accessed safely after the first frame.
      Provider.of<ProgressProvider>(
        context,
        listen: false,
      ).markAlgorithmAsViewed(widget.algorithmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to changes in VisualizationProvider
    return Consumer<VisualizationProvider>(
      builder: (context, provider, child) {
        final algorithm = provider.currentAlgorithm;
        final isLoading = provider.isLoading;
        final errorMessage = provider.errorMessage;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isLoading
                  ? "Loading Algorithm..."
                  : algorithm?.name ?? "Algorithm Visualizer",
            ),
            backgroundColor:
                Theme.of(context).colorScheme.primaryContainer, // M3 color
            actions:
                isLoading ||
                        algorithm ==
                            null // Disable actions while loading/error
                    ? []
                    : [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: "Show Algorithm Info",
                        onPressed: () {
                          _showAlgorithmInfoPanel(context, provider, algorithm);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          provider.isFavorite(algorithm.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        tooltip: "Favorite",
                        onPressed: () {
                          provider.toggleFavorite(algorithm.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        tooltip: "Share Algorithm",
                        onPressed: () {
                          // TODO: Implement share functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Share action (not implemented yet)",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
          ),
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  )
                  : algorithm == null
                  ? const Center(child: Text("Algorithm details not found."))
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildAlgorithmHeader(algorithm),
                        const SizedBox(height: 20),
                        _buildInputsSection(context, provider, algorithm),
                        const SizedBox(height: 24),
                        _buildControlsAndStateSection(context, provider),
                        const SizedBox(height: 24),
                        _buildTimestampsVisualizationSection(context, provider),
                        const SizedBox(height: 24),
                        _buildReferenceCodeSection(algorithm),
                        const SizedBox(height: 20),
                        if (algorithm.notes != null &&
                            algorithm.notes!.isNotEmpty)
                          _buildNotesSection(algorithm),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildAlgorithmHeader(AlgorithmInfo algorithm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          algorithm.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          algorithm.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 10),
        if (algorithm.timeComplexity != null)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "Time Complexity: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: algorithm.timeComplexity),
              ],
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        if (algorithm.spaceComplexity != null)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "Space Complexity: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: algorithm.spaceComplexity),
              ],
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }

  Widget _buildInputsSection(
    BuildContext context,
    VisualizationProvider provider,
    AlgorithmInfo algorithm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Algorithm Inputs",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...algorithm.inputParams.map((param) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: TextEditingController(
                text: provider.inputValues[param.id] ?? param.defaultValue,
              ),
              onChanged: (value) {
                provider.updateInputValue(param.id, value);
              },
              decoration: InputDecoration(
                labelText: param.label,
                hintText: param.hintText,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              keyboardType:
                  param.type == InputParamType.INTEGER ||
                          param.type ==
                              InputParamType.INTEGER_ARRAY_COMMA_SEPARATED
                      ? TextInputType.numberWithOptions(
                        signed: true,
                        decimal: false,
                      )
                      : TextInputType.text,
            ),
          );
        }),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              provider.reInitializeVisualization();
              FocusScope.of(context).unfocus();
            },
            child: const Text("Start / Reset Visualization"),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsAndStateSection(
    BuildContext context,
    VisualizationProvider provider,
  ) {
    final algorithm = provider.currentAlgorithm;
    if (algorithm == null || provider.currentStepState == null) {
      return Center(
        child: Text(
          provider.statusMessage.isNotEmpty
              ? provider.statusMessage
              : "Initialize algorithm to see state.",
        ),
      );
    }

    List<Widget> pointerWidgets = [];
    const List<String> commonPointerKeys = ['L', 'R', 'i', 'j'];
    final activePointers = provider.currentPointers;
    final arrayData = provider.currentArray;

    for (String key in commonPointerKeys) {
      if (activePointers.containsKey(key) && activePointers[key] != null) {
        int pointerIndex = activePointers[key]!;
        String pointerValue =
            (pointerIndex >= 0 && pointerIndex < arrayData.length)
                ? arrayData[pointerIndex].toString()
                : "N/A";
        pointerWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "${key.toUpperCase()}: $pointerIndex (val: $pointerValue)",
            ),
          ),
        );
      }
    }

    activePointers.forEach((key, value) {
      if (value != null && !commonPointerKeys.contains(key)) {
        int pointerIndex = value;
        String pointerValue =
            (pointerIndex >= 0 && pointerIndex < arrayData.length)
                ? arrayData[pointerIndex].toString()
                : "N/A";
        pointerWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              "${key.toUpperCase()}: $pointerIndex (val: $pointerValue)",
            ),
          ),
        );
      }
    });

    List<Widget> metricWidgets = [];
    final metrics = provider.currentMetrics;
    metrics.forEach((key, value) {
      String formattedKey =
          key
              .replaceAllMapped(
                RegExp(r'([A-Z])'),
                (match) => ' ${match.group(1)}',
              )
              .capitalize();
      metricWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text("$formattedKey: $value"),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Controls & Algorithm State",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed:
                    provider.isAlgorithmDone || provider.isPlaying
                        ? null
                        : () => provider.stepForward(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.12),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  disabledForegroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.38),
                ),
                child: const Text("Next Step"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed:
                    provider.isAlgorithmDone && !provider.isPlaying
                        ? null
                        : () => provider.togglePlayPause(),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      provider.isPlaying
                          ? Theme.of(context).colorScheme.tertiaryContainer
                          : Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor:
                      provider.isPlaying
                          ? Theme.of(context).colorScheme.onTertiaryContainer
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.12),
                  disabledForegroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.38),
                ),
                child: Text(provider.isPlaying ? "Pause" : "Play"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => provider.resetAlgorithm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                ),
                child: const Text("Reset"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Animation Speed:",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: provider.animationSpeedFactor,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label:
                "Speed: ${((1.0 - provider.animationSpeedFactor) * 100).toStringAsFixed(0)}%",
            onChanged: (value) {
              provider.setAnimationSpeedFactor(value);
            },
          ),
          const SizedBox(height: 16),
          if (pointerWidgets.isNotEmpty)
            Text("Pointers:", style: Theme.of(context).textTheme.titleMedium),
          ...pointerWidgets,
          if (pointerWidgets.isNotEmpty) const SizedBox(height: 8),

          if (metricWidgets.isNotEmpty)
            Text("Metrics:", style: Theme.of(context).textTheme.titleMedium),
          ...metricWidgets,
          if (metricWidgets.isNotEmpty) const SizedBox(height: 8),

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
            child: Text(
              provider.statusMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampsVisualizationSection(
    BuildContext context,
    VisualizationProvider provider,
  ) {
    final algorithm = provider.currentAlgorithm;
    if (algorithm == null || provider.currentStepState == null) {
      return const SizedBox.shrink();
    }

    final arrayData = provider.currentArray;
    final activePointers = provider.currentPointers;
    final highlighted = provider.highlightedIndices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${algorithm.visualizationType.toString().split('.').last.replaceAll('_', ' ').capitalize()} Visualization",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(arrayData.length, (index) {
                bool isHighlighted = highlighted.contains(index);

                List<String> pointersAtIndex = [];
                activePointers.forEach((key, value) {
                  if (value == index) {
                    pointersAtIndex.add(key);
                  }
                });

                Color boxColor = Theme.of(context).colorScheme.surface;
                Color textColor = Theme.of(context).colorScheme.onSurface;
                BoxBorder border = Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.0,
                );

                if (pointersAtIndex.length > 1) {
                  boxColor = _multiplePointersColor;
                  border = Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  );
                } else if (pointersAtIndex.length == 1) {
                  String pointerName = pointersAtIndex.first;
                  boxColor =
                      _pointerColors[pointerName] ??
                      Theme.of(context).colorScheme.primaryContainer;
                  textColor = Theme.of(context).colorScheme.onPrimaryContainer;
                  border = Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  );
                } else if (isHighlighted) {
                  boxColor = _highlightedColor;
                  textColor = Colors.white;
                }

                return Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: boxColor,
                    border: border,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(
                    child: Text(
                      arrayData[index].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final provider = Provider.of<VisualizationProvider>(context, listen: false);
    List<Widget> legendItems = [];

    final activePointers = provider.currentPointers;
    final highlightedIndices = provider.highlightedIndices;

    activePointers.forEach((key, value) {
      if (value != null && _pointerColors.containsKey(key)) {
        if (!legendItems.any(
          (item) => item.key == Key('pointer_legend_$key'),
        )) {
          legendItems.add(
            _legendItem(
              context,
              _pointerColors[key]!,
              key.toUpperCase(),
              key: Key('pointer_legend_$key'),
            ),
          );
        }
      }
    });

    if (highlightedIndices.isNotEmpty) {
      bool highlightLegendExists = legendItems.any((item) {
        if (item.key == const Key('highlight_legend')) return true;
        if (item is Row && item.children.isNotEmpty) {
          final container =
              item.children.firstWhere(
                    (c) => c is Container,
                    orElse: () => const SizedBox(),
                  )
                  as Container?;
          if (container?.decoration is BoxDecoration) {
            if ((container!.decoration as BoxDecoration).color ==
                _highlightedColor) {
              return true;
            }
          }
        }
        return false;
      });

      if (!highlightLegendExists) {
        legendItems.add(
          _legendItem(
            context,
            _highlightedColor,
            "Active / Highlighted",
            key: const Key('highlight_legend'),
          ),
        );
      }
    }

    bool hasMultiplePointersAtSameSpot = false;
    Map<int, int> indexCounts = {};
    activePointers.forEach((key, value) {
      if (value != null) {
        indexCounts[value] = (indexCounts[value] ?? 0) + 1;
        if (indexCounts[value]! > 1) {
          hasMultiplePointersAtSameSpot = true;
        }
      }
    });

    if (hasMultiplePointersAtSameSpot) {
      if (!legendItems.any(
        (item) => item.key == const Key('multi_pointer_legend'),
      )) {
        legendItems.add(
          _legendItem(
            context,
            _multiplePointersColor,
            "Multiple Pointers",
            key: const Key('multi_pointer_legend'),
          ),
        );
      }
    }

    if (legendItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(spacing: 16.0, runSpacing: 8.0, children: legendItems),
    );
  }

  Widget _legendItem(
    BuildContext context,
    Color color,
    String label, {
    Key? key,
  }) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey.shade600),
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildReferenceCodeSection(AlgorithmInfo algorithm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reference ${algorithm.referenceCodeLanguage} Code",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(
              0xff282c34,
            ), // A common dark theme color for code blocks
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              algorithm.referenceCodeSnippet.trim(),
              language: algorithm.referenceCodeLanguage.toLowerCase(),
              theme:
                  atomOneDarkTheme, // A popular dark theme for flutter_highlight
              padding: const EdgeInsets.all(8.0),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.0,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(AlgorithmInfo algorithm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notes",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Text(
            algorithm.notes!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  // Method to show the BottomSheet for Algorithm Information
  void _showAlgorithmInfoPanel(
    BuildContext context,
    VisualizationProvider provider,
    AlgorithmInfo algorithm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return DefaultTabController(
          length: 5, // Explanation, Pseudocode, Code, Complexity, Notes
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (_, scrollController) {
              return Column(
                children: [
                  // Optional: Add a grabber handle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  TabBar(
                    isScrollable: true,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: "Explanation"),
                      Tab(text: "Pseudocode"),
                      Tab(text: "Code"),
                      Tab(text: "Complexity"),
                      Tab(text: "Notes"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildInfoPanelTab(scrollController, "Explanation", [
                          Text(algorithm.description),
                        ]),
                        _buildInfoPanelTab(scrollController, "Pseudocode", [
                          HighlightView(
                            algorithm.referenceCodeSnippet
                                .trim(), // Assuming pseudocode is in snippet
                            language: 'plaintext', // Generic for pseudocode
                            theme: atomOneDarkTheme,
                            padding: const EdgeInsets.all(8.0),
                            textStyle: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13.0,
                              height: 1.5,
                            ),
                          ),
                        ]),
                        _buildInfoPanelTab(
                          scrollController,
                          "Code (${algorithm.referenceCodeLanguage})",
                          [
                            HighlightView(
                              algorithm.referenceCodeSnippet.trim(),
                              language:
                                  algorithm.referenceCodeLanguage.toLowerCase(),
                              theme: atomOneDarkTheme,
                              padding: const EdgeInsets.all(8.0),
                              textStyle: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13.0,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        _buildInfoPanelTab(scrollController, "Complexity", [
                          if (algorithm.timeComplexity != null)
                            Text(
                              "Time: ${algorithm.timeComplexity}",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          if (algorithm.spaceComplexity != null)
                            Text(
                              "Space: ${algorithm.spaceComplexity}",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          if (algorithm.timeComplexity == null &&
                              algorithm.spaceComplexity == null)
                            const Text("Complexity information not available."),
                        ]),
                        _buildInfoPanelTab(scrollController, "Notes", [
                          if (algorithm.notes != null &&
                              algorithm.notes!.isNotEmpty)
                            Text(algorithm.notes!)
                          else
                            const Text(
                              "No additional notes for this algorithm.",
                            ),
                        ]),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Helper widget for the content of each tab in the bottom sheet
  Widget _buildInfoPanelTab(
    ScrollController scrollController,
    String title,
    List<Widget> children,
  ) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      children: children,
    );
  }
}

// You might want to define this theme in a separate file or at the top
const atomOneDarkTheme = {
  'root': TextStyle(
    backgroundColor: Color(0xff282c34),
    color: Color(0xffabb2bf),
  ),
  'comment': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'doctag': TextStyle(color: Color(0xffc678dd)),
  'keyword': TextStyle(color: Color(0xffc678dd)),
  'formula': TextStyle(color: Color(0xffc678dd)),
  'section': TextStyle(color: Color(0xffe06c75)),
  'name': TextStyle(color: Color(0xffe06c75)),
  'selector-tag': TextStyle(color: Color(0xffe06c75)),
  'deletion': TextStyle(color: Color(0xffe06c75)),
  'subst': TextStyle(color: Color(0xffe06c75)),
  'literal': TextStyle(color: Color(0xff56b6c2)),
  'string': TextStyle(color: Color(0xff98c379)),
  'regexp': TextStyle(color: Color(0xff98c379)),
  'addition': TextStyle(color: Color(0xff98c379)),
  'attribute': TextStyle(color: Color(0xff98c379)),
  'meta-string': TextStyle(color: Color(0xff98c379)),
  'built_in': TextStyle(color: Color(0xffe6c07b)),
  'class': TextStyle(color: Color(0xffe6c07b)),
  'attr': TextStyle(color: Color(0xffd19a66)),
  'variable': TextStyle(color: Color(0xffd19a66)),
  'template-variable': TextStyle(color: Color(0xffd19a66)),
  'type': TextStyle(color: Color(0xffd19a66)),
  'selector-class': TextStyle(color: Color(0xffd19a66)),
  'selector-attr': TextStyle(color: Color(0xffd19a66)),
  'selector-pseudo': TextStyle(color: Color(0xffd19a66)),
  'number': TextStyle(color: Color(0xffd19a66)),
  'symbol': TextStyle(color: Color(0xff61aeee)),
  'bullet': TextStyle(color: Color(0xff61aeee)),
  'link': TextStyle(color: Color(0xff61aeee)),
  'meta': TextStyle(color: Color(0xff61aeee)),
  'selector-id': TextStyle(color: Color(0xff61aeee)),
  'title': TextStyle(color: Color(0xff61aeee)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
