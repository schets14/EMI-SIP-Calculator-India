import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'favorites_screen.dart';
import '../services/app_strings.dart';
import 'saved_plans_screen.dart';
import 'reminders_screen.dart';
import 'financial_health_screen.dart';
import 'sip_swp_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ThemeMode themeMode;
  const SettingsScreen({super.key, required this.language, required this.onLanguageChanged, this.onThemeModeChanged, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(language);
    return Scaffold(
      appBar: AppBar(title: Text(s.settings, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.palette_outlined), title: Text(AppStrings.translate(context, 'Appearance')), subtitle: Text(_themeLabel(themeMode)), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => _showTheme(context)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.history_rounded), title: Text(s.history), subtitle: Text(s.historySub), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.bookmark_rounded), title: Text(s.favorites), subtitle: Text(s.favoritesSub), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.bookmark_added_rounded), title: Text(AppStrings.translate(context, 'My Plans')), subtitle: Text(AppStrings.translate(context, 'Saved calculations and scenarios')), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedPlansScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.notifications_active_rounded), title: Text(AppStrings.translate(context, 'Reminders')), subtitle: Text(AppStrings.translate(context, 'EMI, SIP and financial review reminders')), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.insights_rounded), title: Text(AppStrings.translate(context, 'Financial Health')), subtitle: Text(AppStrings.translate(context, 'Build a private monthly money snapshot')), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialHealthScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.compare_arrows_rounded), title: Text(AppStrings.translate(context, 'SIP → SWP Planner')), subtitle: Text(AppStrings.translate(context, 'Plan accumulation and withdrawals')), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SipSwpScreen()))),
          ])),
          const SizedBox(height: 12),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.shield_outlined), title: Text(s.privacy), subtitle: Text(s.privacySub)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.info_outline_rounded), title: Text(s.about), subtitle: Text(s.aboutSub)),
          ])),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(s.disclaimer, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.45))),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Light mode';
      case ThemeMode.dark: return 'Dark mode';
      case ThemeMode.system: return 'System default';
    }
  }

  void _showTheme(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(AppStrings.translate(context, 'Choose appearance'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Use the system setting or choose a theme manually.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 14),
            _themeTile(context, ThemeMode.system, Icons.brightness_auto_rounded, 'System default', 'Follow your phone theme'),
            _themeTile(context, ThemeMode.light, Icons.light_mode_rounded, 'Light', 'Bright and clean'),
            _themeTile(context, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark', 'Comfortable in low light'),
          ]),
        ),
      ),
    );
  }

  Widget _themeTile(BuildContext context, ThemeMode mode, IconData icon, String title, String subtitle) {
    final active = themeMode == mode;
    return ListTile(
      leading: Icon(icon), title: Text(title), subtitle: Text(subtitle),
      trailing: active ? const Icon(Icons.check_circle_rounded) : null,
      onTap: () {
        Navigator.pop(context);
        onThemeModeChanged?.call(mode);
      },
    );
  }

}
