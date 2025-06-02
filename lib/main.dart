import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/visualization_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';
import 'services/progress_repository.dart';
import 'services/algorithm_service.dart';
import 'services/favorites_repository.dart';
import 'services/settings_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AlgorithmService algorithmService = AlgorithmService();
    final ProgressRepository progressRepository = ProgressRepository();
    final FavoritesRepository favoritesRepository = FavoritesRepository();
    final SettingsRepository settingsRepository = SettingsRepository();

    return MultiProvider(
      providers: [
        Provider<AlgorithmService>.value(value: algorithmService),
        ChangeNotifierProvider(
          create:
              (context) => VisualizationProvider(
                favoritesRepository: favoritesRepository,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) =>
                  ProgressProvider(progressRepository, algorithmService),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(settingsRepository),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Algorithm Visualizer',
            themeMode: settingsProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.deepPurple,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ).copyWith(secondary: Colors.deepPurpleAccent),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.deepPurple,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ).copyWith(secondary: Colors.deepPurpleAccent),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
