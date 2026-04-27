import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Appearance ──────────────────────────────────────────────────
          _SectionHeader(label: t.get('dark_mode')),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              title: Text(t.get('dark_mode'),
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(
                settings.isDark ? 'On' : 'Off',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant),
              ),
              secondary: Icon(
                settings.isDark ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
              ),
              value: settings.isDark,
              onChanged: (value) => settings.toggleTheme(value),
            ),
          ),

          const SizedBox(height: 20),

          // ── Language ────────────────────────────────────────────────────
          _SectionHeader(label: t.get('language')),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: RadioGroup<String>(
              groupValue: settings.locale,
              onChanged: (value) => settings.setLocale(value!),
              child: Column(
                children: [
                  RadioListTile<String>(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    title: Row(
                      children: [
                        const Text('🇬🇧', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text('English',
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                    value: 'en',
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: colorScheme.outline,
                  ),
                  RadioListTile<String>(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    title: Row(
                      children: [
                        const Text('🇷🇺', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text('Русский',
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                    value: 'ru',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'PoppinsMedium',
          fontSize: 11,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
