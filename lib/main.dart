import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/startup_screen.dart';
import 'services/ad_service.dart';
import 'services/local_store.dart';
import 'services/app_strings.dart';
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

  @override
  void initState() {
    super.initState();
    _loadStartupPreferences();
  }

  Future<void> _loadStartupPreferences() async {
    final results = await Future.wait<Object>([
      LocalStore.onboardingDone(),
      LocalStore.language(),
      Future<void>.delayed(const Duration(milliseconds: 1400)).then<Object>((_) => ''),
    ]);
    if (!mounted) return;
    setState(() {
      onboarding = !(results[0] as bool);
      language = results[1] as String;
    });
  }

  void _setLanguage(String value) {
    setState(() => language = value);
    LocalStore.setLanguage(value);
  }

  @override Widget build(BuildContext context) => MaterialApp(
    title: 'EMI SIP Calculator India', debugShowCheckedModeBanner: false,
    locale: AppLanguage.locale(language),
    theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: ThemeMode.system,
    home: onboarding == null
      ? const StartupScreen()
      : onboarding!
        ? OnboardingScreen(language: language, onDone: () => setState(() => onboarding = false))
        : HomeScreen(language: language, onLanguageChanged: _setLanguage),
  );
}
