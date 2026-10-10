import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/startup_screen.dart';
import 'services/ad_service.dart';
import 'services/local_store.dart';
import 'services/app_strings.dart';
import 'services/app_update_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(AdService.initialize());
  runApp(const FinCalcApp());
}

class FinCalcApp extends StatefulWidget {
  const FinCalcApp({super.key});
  @override State<FinCalcApp> createState() => _FinCalcAppState();
}

class _FinCalcAppState extends State<FinCalcApp> {
  bool? onboarding;
  String language = AppLanguage.english;
  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadStartupPreferences();
  }

  Future<void> _loadStartupPreferences() async {
    final results = await Future.wait<Object>([
      LocalStore.onboardingDone(),
      LocalStore.themeMode(),
      Future<void>.delayed(const Duration(milliseconds: 1400)).then<Object>((_) => ''),
    ]);
    if (!mounted) return;
    setState(() {
      onboarding = !(results[0] as bool);
      language = AppLanguage.english;
      themeMode = _themeModeFromString(results[1] as String);
    });
    // Do not interrupt first-time onboarding. Existing users get the native
    // Google Play update prompt shortly after the home screen is ready.
    if (results[0] as bool) {
      Future<void>.delayed(const Duration(milliseconds: 900), () => AppUpdateService.checkForUpdate());
    }
  }

  void _setLanguage(String value) {
    setState(() => language = value);
    LocalStore.setLanguage(value);
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  void _setThemeMode(ThemeMode value) {
    setState(() => themeMode = value);
    LocalStore.setThemeMode(value.name);
  }

  @override Widget build(BuildContext context) => MaterialApp(
    title: 'EMI SIP Calculator India', debugShowCheckedModeBanner: false,
    locale: const Locale('en', 'IN'),
    theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: themeMode,
    home: onboarding == null
      ? const StartupScreen()
      : onboarding!
        ? OnboardingScreen(language: language, onDone: () => setState(() => onboarding = false))
        : HomeScreen(language: language, onLanguageChanged: _setLanguage, onThemeModeChanged: _setThemeMode, themeMode: themeMode),
  );
}
