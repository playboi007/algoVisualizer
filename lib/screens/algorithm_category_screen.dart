import 'package:flutter/material.dart';
import '../models/algorithm_info.dart';
import '../services/algorithm_service.dart';
import 'visualization_screen.dart'; // Assuming this screen exists and takes algorithmId

class AlgorithmCategoryScreen extends StatelessWidget {
  final AlgorithmCategory category;
  final AlgorithmService _algorithmService = AlgorithmService();

  AlgorithmCategoryScreen({super.key, required this.category});

  String _formatCategoryName(AlgorithmCategory category) {
    return category.toString().split('.').last.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final algorithmsInCategory =
        _algorithmService
            .getAllAlgorithms()
            .where((alg) => alg.category == category)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatCategoryName(category)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body:
          algorithmsInCategory.isEmpty
              ? const Center(
                child: Text("No algorithms found in this category."),
              )
              : ListView.builder(
                itemCount: algorithmsInCategory.length,
                itemBuilder: (context, index) {
                  final algorithm = algorithmsInCategory[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      leading: Icon(
                        Icons
                            .functions, // Placeholder, consider algorithm-specific or consistent icons
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                      title: Text(
                        algorithm.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        algorithm.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
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
                                (context) => VisualizationScreen(
                                  algorithmId: algorithm.id,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
