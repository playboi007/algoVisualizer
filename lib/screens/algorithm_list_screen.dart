import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added for ProgressProvider
import '../services/algorithm_service.dart';
import '../models/algorithm_info.dart';
import '../providers/progress_provider.dart'; // Added for actions
import 'algorithm_category_screen.dart';
import 'progress_tracker_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class AlgorithmListScreen extends StatefulWidget {
  const AlgorithmListScreen({super.key});

  @override
  State<AlgorithmListScreen> createState() => _AlgorithmListScreenState();
}

class _AlgorithmListScreenState extends State<AlgorithmListScreen> {
  final AlgorithmService _algorithmService = AlgorithmService();
  int _selectedIndex = 0;

  // Titles for each tab
  static const List<String> _appBarTitles = <String>[
    'AlgoVisualizer',
    'My Progress',
    'My Favorites',
    'Settings',
  ];

  // Helper to get actions for the AppBar based on the selected tab
  List<Widget> _getAppBarActions(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        return [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Search Algorithms",
            onPressed: () {
              /* TODO: Implement search functionality */
            },
          ),
        ];
      case 1: // Learn Path / Progress
        final progressProvider = Provider.of<ProgressProvider>(
          context,
          listen: false,
        );
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Progress",
            onPressed: () => progressProvider.loadProgress(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: "Clear All Progress",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text("Confirm Reset"),
                      content: const Text(
                        "Are you sure you want to clear all your progress data? This cannot be undone.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            "Clear All",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                await progressProvider.clearAllProgressData();
              }
            },
          ),
        ];
      // No specific actions for Favorites or Settings tabs by default in AppBar
      case 2: // Favorites
      case 3: // Settings
      default:
        return [];
    }
  }

  String _formatCategoryName(AlgorithmCategory category) {
    return category.toString().split('.').last.replaceAll('_', ' ');
  }

  IconData _getCategoryIcon(AlgorithmCategory category) {
    switch (category) {
      case AlgorithmCategory.SORTING:
        return Icons.sort_by_alpha;
      case AlgorithmCategory.SEARCHING:
        return Icons.search_sharp;
      case AlgorithmCategory.GRAPH:
        return Icons.share;
      case AlgorithmCategory.TREE:
        return Icons.account_tree_outlined;
      case AlgorithmCategory.SLIDING_WINDOW:
        return Icons.view_day_outlined;
      case AlgorithmCategory.TWO_POINTERS:
        return Icons.compare_arrows_outlined;
      case AlgorithmCategory.DYNAMIC_PROGRAMMING:
        return Icons.memory;
      case AlgorithmCategory.STRING:
        return Icons.text_fields;
      case AlgorithmCategory.MATH:
        return Icons.calculate_outlined;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAlgorithms = _algorithmService.getAllAlgorithms();
    final categories =
        AlgorithmCategory.values.where((category) {
          return allAlgorithms.any((alg) => alg.category == category);
        }).toList();

    final List<Widget> widgetOptions = <Widget>[
      categories.isEmpty && _selectedIndex == 0
          ? const Center(child: Text("No algorithm categories available."))
          : ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = _formatCategoryName(category);
              final categoryIcon = _getCategoryIcon(category);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  leading: Icon(
                    categoryIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                  ),
                  title: Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                AlgorithmCategoryScreen(category: category),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      const ProgressTrackerScreen(),
      const FavoritesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]), // Dynamic title
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: _getAppBarActions(context, _selectedIndex), // Dynamic actions
      ),
      body: IndexedStack(index: _selectedIndex, children: widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline_outlined),
            label: 'Learn Path',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
