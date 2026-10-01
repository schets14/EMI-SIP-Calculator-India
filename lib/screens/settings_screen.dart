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
  const SettingsScreen({super.key, required this.language, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(language);
    return Scaffold(
      appBar: AppBar(title: Text(s.settings, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.language_rounded), title: Text(s.appLanguage), subtitle: Text(AppLanguage.label(language)), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => _showLanguage(context)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.history_rounded), title: Text(s.history), subtitle: Text(s.historySub), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.bookmark_rounded), title: Text(s.favorites), subtitle: Text(s.favoritesSub), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.bookmark_added_rounded), title: const Text('My Plans'), subtitle: const Text('Saved calculations and scenarios'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedPlansScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.notifications_active_rounded), title: const Text('Reminders'), subtitle: const Text('EMI, SIP and financial review reminders'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.insights_rounded), title: const Text('Financial Health'), subtitle: const Text('Build a private monthly money snapshot'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialHealthScreen()))),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.compare_arrows_rounded), title: const Text('SIP → SWP Planner'), subtitle: const Text('Plan accumulation and withdrawals'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SipSwpScreen()))),
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
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(s.languageNote, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), height: 1.4))),
        ],
      ),
    );
  }

  void _showLanguage(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Choose language', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('English is the default for a wider Indian audience.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 14),
            ListTile(leading: const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), title: const Text('English'), trailing: language == AppLanguage.english ? const Icon(Icons.check_circle_rounded) : null, onTap: () { Navigator.pop(context); onLanguageChanged(AppLanguage.english); }),
            ListTile(leading: const Text('अ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), title: const Text('हिन्दी'), trailing: language == AppLanguage.hindi ? const Icon(Icons.check_circle_rounded) : null, onTap: () { Navigator.pop(context); onLanguageChanged(AppLanguage.hindi); }),
          ]),
        ),
      ),
    );
  }
}
