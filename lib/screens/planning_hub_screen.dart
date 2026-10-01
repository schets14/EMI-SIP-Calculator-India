import 'package:flutter/material.dart';
import '../services/app_strings.dart';
import 'prepayment_screen.dart';
import 'sip_screen.dart';
import 'extra_calculators_screen.dart';

class PlanningHubScreen extends StatelessWidget {
  final String language;
  const PlanningHubScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(language);
    return Scaffold(
      appBar: AppBar(title: Text(s.planAndDecide, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
        children: [
          Text(s.planAndDecideSub, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 18),
          _decisionCard(context, icon: Icons.payments_outlined, color: const Color(0xFF059669), title: s.lowerLoanCost, subtitle: s.lowerLoanCostSub, page: const PrepaymentScreen()),
          const SizedBox(height: 12),
          _decisionCard(context, icon: Icons.trending_up_rounded, color: const Color(0xFF5B5FEF), title: s.growSavings, subtitle: s.growSavingsSub, page: const SipScreen()),
          const SizedBox(height: 12),
          _decisionCard(context, icon: Icons.flag_rounded, color: const Color(0xFFEA580C), title: s.reachGoal, subtitle: s.reachGoalSub, page: const GoalCalculator()),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline_rounded, color: Color(0xFF5B5FEF)),
                SizedBox(width: 10),
                Expanded(child: Text('These tools compare scenarios using the assumptions you enter. They are not bank approval, investment or tax advice.', style: TextStyle(fontSize: 12, height: 1.45, color: Color(0xFF6B7280)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decisionCard(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required Widget page}) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(17)), child: Icon(icon, color: color)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.35, color: Color(0xFF6B7280)))])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}
