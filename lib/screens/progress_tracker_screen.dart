import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/algorithm_info.dart'; // For AlgorithmCategory enum to display names

class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  String _formatCategoryName(AlgorithmCategory category) {
    return category.toString().split('.').last.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        if (progressProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final double overallProgress = progressProvider.overallProgress;
        final int algorithmsViewed = progressProvider.algorithmsViewedCount;
        final int categoriesExplored = progressProvider.categoriesExploredCount;
        final String timeSpentLearning = progressProvider.formattedTimeSpent;

        final categoryProgressData = progressProvider.progressByCategory;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Overall Progress (${progressProvider.totalAlgorithmsAvailable} Algorithms)",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CircularProgressIndicator(
                          value: overallProgress,
                          strokeWidth: 10,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Center(
                          child: Text(
                            "${(overallProgress * 100).toStringAsFixed(0)}%",
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Text(
                "Statistics",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      _buildStatRow(
                        context,
                        Icons.list_alt,
                        "Algorithms Viewed",
                        algorithmsViewed.toString(),
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.category_outlined,
                        "Categories Explored (${progressProvider.totalCategoriesAvailable} Total)",
                        categoriesExplored.toString(),
                      ),
                      const Divider(),
                      _buildStatRow(
                        context,
                        Icons.timer_outlined,
                        "Time Spent Learning",
                        timeSpentLearning,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                "Progress by Category",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              if (categoryProgressData.isEmpty)
                const Center(
                  child: Text(
                    "No categories found or progress not yet loaded.",
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryProgressData.length,
                  itemBuilder: (context, index) {
                    final categoryEnum = categoryProgressData.keys.elementAt(
                      index,
                    );
                    final progress = categoryProgressData[categoryEnum]!;
                    final categoryName = _formatCategoryName(categoryEnum);
                    final double categoryProgressValue =
                        progress.total == 0
                            ? 0.0
                            : progress.completed / progress.total;

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              categoryName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            LinearProgressIndicator(
                              value: categoryProgressValue,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary,
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 4.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${progress.completed}/${progress.total} completed",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
