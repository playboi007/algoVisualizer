import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return settingsProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Text(
              "Appearance",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildThemeModeSetting(context, settingsProvider),
            const Divider(height: 32, thickness: 1),
            Text(
              "Visualization",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildAnimationSpeedSetting(context, settingsProvider),
            // Add more settings sections here (e.g., Preferred Code Language)
          ],
        );
  }

  Widget _buildThemeModeSetting(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Theme Mode", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SegmentedButton<ThemeMode>(
              segments: const <ButtonSegment<ThemeMode>>[
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {provider.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                provider.updateThemeMode(newSelection.first);
              },
              style: SegmentedButton.styleFrom(
                selectedForegroundColor:
                    Theme.of(context).colorScheme.onPrimary,
                selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationSpeedSetting(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Default Animation Speed",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 0),
            Slider(
              value: provider.defaultAnimationSpeed,
              min: 0.0, // Represents fastest
              max: 1.0, // Represents slowest
              divisions: 10,
              label:
                  "Speed: ${((1.0 - provider.defaultAnimationSpeed) * 100).toStringAsFixed(0)}%", // Inverted for user perception
              onChanged: (double value) {
                provider.updateDefaultAnimationSpeed(value);
              },
            ),
            Center(
              child: Text(
                "Current Speed: ${((1.0 - provider.defaultAnimationSpeed) * 100).toStringAsFixed(0)}%",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
