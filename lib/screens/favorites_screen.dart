import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visualization_provider.dart';
import '../services/algorithm_service.dart';
import '../models/algorithm_info.dart';
import 'visualization_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final algorithmService = Provider.of<AlgorithmService>(
      context,
      listen: false,
    );
    final visualizationProvider = Provider.of<VisualizationProvider>(context);
    final favoriteIds = visualizationProvider.favoriteAlgorithmIds;

    List<AlgorithmInfo> favoriteAlgorithms = [];
    if (favoriteIds.isNotEmpty) {
      favoriteAlgorithms =
          favoriteIds
              .map((id) => algorithmService.getAlgorithmById(id))
              .whereType<AlgorithmInfo>()
              .toList();
    }

    return favoriteAlgorithms.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No favorites yet!",
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                "Tap the heart icon on an algorithm to add it here.",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        : ListView.builder(
          itemCount: favoriteAlgorithms.length,
          itemBuilder: (context, index) {
            final algorithm = favoriteAlgorithms[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(
                  algorithm.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  algorithm.category
                      .toString()
                      .split('.')
                      .last
                      .replaceAll('_', ' '),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              VisualizationScreen(algorithmId: algorithm.id),
                    ),
                  );
                },
              ),
            );
          },
        );
  }
}
