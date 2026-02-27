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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.get('settings'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              t.get('dark_mode'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            value: settings.isDark,
            activeTrackColor: Colors.blue,
            onChanged: (value) => settings.toggleTheme(value),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Text(
              t.get('language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<String>(
            groupValue: settings.locale,
            onChanged: (value) => settings.setLocale(value!),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(
                    'English',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  value: 'en',
                ),
                RadioListTile<String>(
                  title: Text(
                    'Русский',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  value: 'ru',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
