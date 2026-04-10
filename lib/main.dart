import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/themes.dart';
import 'package:my_app/providers/settings_provider.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/services/firebase_service.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:my_app/viewmodels/cards_viewmodel.dart';
import 'package:my_app/viewmodels/exchange_rate_viewmodel.dart';
import 'package:my_app/viewmodels/notification_viewmodel.dart';
import 'package:my_app/viewmodels/search_viewmodel.dart';
import 'package:my_app/viewmodels/transaction_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase — gracefully skipped if google-services.json is still a placeholder
  await FirebaseService.initialize();

  // Local notifications
  await NotificationService.init();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(MyApp(settingsProvider: settingsProvider));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const MyApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => CardsViewModel()),
        ChangeNotifierProvider(create: (_) => ExchangeRateViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'MyFinance',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: settings.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
