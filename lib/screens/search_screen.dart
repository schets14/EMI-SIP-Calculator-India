import 'package:flutter/material.dart';
import 'emi_screen.dart';
import 'sip_screen.dart';
import 'step_up_sip_screen.dart';
import 'prepayment_screen.dart';
import 'extra_calculators_screen.dart';
import 'decision_center_screen.dart';
import 'saved_plans_screen.dart';
import 'reminders_screen.dart';
import 'financial_health_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
  const _SearchItem(this.title, this.subtitle, this.icon, this.page);
}

class _SearchScreenState extends State<SearchScreen> {
  final q = TextEditingController();
  final items = <_SearchItem>[
    const _SearchItem('Loan EMI', 'Calculate EMI, interest and amortization', Icons.account_balance_rounded, EmiScreen()),
    const _SearchItem('SIP Planner', 'Estimate corpus and returns', Icons.trending_up_rounded, SipScreen()),
    const _SearchItem('Step-up SIP', 'Increase SIP every year', Icons.auto_graph_rounded, StepUpSipScreen()),
    const _SearchItem('Loan Prepayment', 'Estimate interest saved', Icons.payments_rounded, PrepaymentScreen()),
    const _SearchItem('Plan & Decide', 'Compare loan and money scenarios', Icons.explore_rounded, DecisionCenterScreen()),
    const _SearchItem('More Calculators', 'FD, RD, PPF, GST and goals', Icons.grid_view_rounded, ExtraCalculatorsScreen()),
    const _SearchItem('My Plans', 'Saved calculations and scenarios', Icons.bookmark_rounded, SavedPlansScreen()),
    const _SearchItem('Reminders', 'EMI, SIP and finance reminders', Icons.notifications_active_rounded, RemindersScreen()),
    const _SearchItem('Financial Health', 'Build a simple monthly money snapshot', Icons.insights_rounded, FinancialHealthScreen()),
  ];

  @override void dispose() { q.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final query = q.text.trim().toLowerCase();
    final filtered = items.where((e) => query.isEmpty || e.title.toLowerCase().contains(query) || e.subtitle.toLowerCase().contains(query)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Search', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: q,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Try “loan”, “SIP”, “retirement”…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: q.text.isEmpty ? null : IconButton(onPressed: () { q.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 9),
              itemBuilder: (_, i) {
                final x = filtered[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
                      child: Icon(x.icon, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(x.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(x.subtitle),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => x.page)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
