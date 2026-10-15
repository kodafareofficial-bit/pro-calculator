import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_info.dart';
import 'core/app_theme.dart';
import 'logic/calculator_controller.dart';
import 'logic/settings_controller.dart';
import 'ui/calculator_screen.dart';
import 'ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsController(prefs);
  final controller = CalculatorController(prefs, settings);

  runApp(ProCalculatorApp(settings: settings, controller: controller));
}

class ProCalculatorApp extends StatelessWidget {
  const ProCalculatorApp({
    super.key,
    required this.settings,
    required this.controller,
  });

  final SettingsController settings;
  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    // فقط با تغییر تنظیمات (تم) MaterialApp دوباره ساخته می‌شود.
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: AppInfo.appName,
          debugShowCheckedModeBanner: false,
          locale: const Locale('fa', 'IR'),
          supportedLocales: const [Locale('fa', 'IR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: settings.themeMode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: SplashGate(
            child: CalculatorScreen(
              settings: settings,
              controller: controller,
            ),
          ),
        );
      },
    );
  }
}
