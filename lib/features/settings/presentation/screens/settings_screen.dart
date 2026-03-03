import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:flutter_riverpod_clean_architecture/main.dart';

/// Settings screen with various app configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        children: [
          // Language settings
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.tr('language')),
            subtitle: Text(context.tr('change_language')),
            onTap: () => context.push('/settings/language'),
          ),

          const Divider(),

          // Theme settings
          ListTile(
            leading: Icon(
              currentTheme == ThemeMode.dark
                  ? Icons.dark_mode
                  : currentTheme == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
            ),
            title: Text(context.tr('theme')),
            subtitle: Text(_getThemeLabel(currentTheme)),
            onTap: () => _showThemeDialog(context, ref, currentTheme),
          ),

          const Divider(),

          // Biometric settings
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometrics'),
            subtitle: const Text('Face ID / Fingerprint authentication'),
            onTap: () => context.push('/settings/biometrics'),
          ),

          const Divider(),

          // Localization demos
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(context.tr('localization_demo')),
            subtitle: Text(context.tr('localization_demo_description')),
            onTap: () => context.push('/settings/localization-demo'),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              secondary: const Icon(Icons.light_mode),
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).set(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              secondary: const Icon(Icons.dark_mode),
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).set(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              secondary: const Icon(Icons.brightness_auto),
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).set(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
