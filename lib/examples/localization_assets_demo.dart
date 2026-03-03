import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/localization/language_selector_widget.dart';
import 'package:flutter_riverpod_clean_architecture/core/localization/localized_asset_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// Demo screen to showcase localization features
/// Includes language-specific assets demo
class LocalizationAssetsDemo extends ConsumerWidget {
  const LocalizationAssetsDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(persistentLocaleProvider);

    // Create AppLocalizations instance for formatting
    final l10n = AppLocalizations(locale);

    // Current date for formatting examples
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('localization_assets_demo')),
        actions: const [
          // Language popup menu in the app bar
          LanguagePopupMenuButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current locale information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('current_language'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.tr('language_code')}: ${locale.languageCode}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('language_name')}: ${getLanguageName(locale.languageCode)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Date and number formatting examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('formatting_examples'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.tr('date_full')}: ${DateFormat.yMMMMEEEEd(locale.toString()).format(now)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('date_short')}: ${DateFormat.yMd(locale.toString()).format(now)}',
                    ),
                    const SizedBox(height: 4),
                    Text('${context.tr('time')}: ${l10n.formatTime(now)}'),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('currency')}: ${l10n.formatCurrency(1234.56)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('percent')}: ${NumberFormat.percentPattern(locale.toString()).format(0.1234)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Localized assets examples
            Text(
              context.tr('localized_assets'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Display a note about language-specific assets
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('localized_assets_explanation'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Localized content example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Localized Content Example',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Show different greeting based on locale
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.language,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getLocalizedGreeting(locale.languageCode),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current locale: ${locale.languageCode.toUpperCase()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Localized image
                    Text(
                      'Localized Image',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: const LocalizedImage(
                          imageName: 'welcome.png',
                          width: 240,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Image changes based on selected language',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Common logo
                    Text(
                      'Common Image (shared)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: const LocalizedImage(
                          imageName: 'logo.png',
                          useCommonPath: true,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // RTL/LTR indicator
                    Text(
                      'Text Direction Example',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.format_textdirection_l_to_r),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getSampleText(locale.languageCode),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to get language name from code
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ja':
        return '日本語';
      case 'bn':
        return 'বাংলা';
      default:
        return languageCode;
    }
  }

  /// Helper to get localized greeting
  String _getLocalizedGreeting(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Hello! Welcome to the app.';
      case 'es':
        return '¡Hola! Bienvenido a la aplicación.';
      case 'fr':
        return 'Bonjour! Bienvenue dans l\'application.';
      case 'de':
        return 'Hallo! Willkommen in der App.';
      case 'ja':
        return 'こんにちは！アプリへようこそ。';
      case 'bn':
        return 'হ্যালো! অ্যাপে স্বাগতম।';
      default:
        return 'Hello! Welcome to the app.';
    }
  }

  /// Helper to get sample text for each language
  String _getSampleText(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'The quick brown fox jumps over the lazy dog.';
      case 'es':
        return 'El veloz murciélago hindú comía feliz cardillo y kiwi.';
      case 'fr':
        return 'Portez ce vieux whisky au juge blond qui fume.';
      case 'de':
        return 'Victor jagt zwölf Boxkämpfer quer über den großen Sylter Deich.';
      case 'ja':
        return 'いろはにほへとちりぬるを。';
      case 'bn':
        return 'আমি বাংলায় গান গাই।';
      default:
        return 'The quick brown fox jumps over the lazy dog.';
    }
  }
}
