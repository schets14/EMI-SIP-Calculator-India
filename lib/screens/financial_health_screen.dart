import 'package:flutter/material.dart';
import '../models/user_planning_models.dart';
import '../services/local_store.dart';
import '../utils/formatters.dart';

class FinancialHealthScreen extends StatefulWidget {
  const FinancialHealthScreen({super.key});
  @override State<FinancialHealthScreen> createState() => _FinancialHealthScreenState();
}

class _FinancialHealthScreenState extends State<FinancialHealthScreen> {
  final income = TextEditingController(text: '85000');
  final expenses = TextEditingController(text: '30000');
  final emi = TextEditingController(text: '8000');
  final investments = TextEditingController(text: '20000');
  final emergency = TextEditingController(text: '150000');
  final savings = TextEditingController(text: '500000');
  bool loaded = false;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final h = await LocalStore.financialHealth(); if (h != null) { income.text = h.monthlyIncome.toStringAsFixed(0); expenses.text = h.monthlyExpenses.toStringAsFixed(0); emi.text = h.existingEmi.toStringAsFixed(0); investments.text = h.monthlyInvestments.toStringAsFixed(0); emergency.text = h.emergencyFund.toStringAsFixed(0); savings.text = h.savings.toStringAsFixed(0); } if (mounted) setState(() => loaded = true); }
  @override void dispose() { for (final c in [income, expenses, emi, investments, emergency, savings]) { c.dispose(); } super.dispose(); }
  double v(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0;
  Future<void> _save() => LocalStore.saveFinancialHealth(FinancialHealth(monthlyIncome: v(income), monthlyExpenses: v(expenses), existingEmi: v(emi), monthlyInvestments: v(investments), emergencyFund: v(emergency), savings: v(savings)));

  @override
  Widget build(BuildContext context) {
    if (!loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final inc = v(income), exp = v(expenses), e = v(emi), inv = v(investments), ef = v(emergency);
    final cash = inc - exp - e - inv;
    final savingsRate = inc > 0 ? ((inv + cash) / inc * 100).clamp(0, 100).toDouble() : 0.0;
    final months = exp + e > 0 ? ef / (exp + e) : 0.0;
    final debtRatio = inc > 0 ? e / inc * 100 : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Health', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
        children: [
          const Text('A simple snapshot using numbers you enter. Nothing is linked to your bank.', style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          _field('Monthly income', income), _field('Monthly expenses', expenses), _field('Existing EMI', emi), _field('Monthly investments', investments), _field('Emergency fund', emergency), _field('Current savings / investments', savings),
          const SizedBox(height: 10),
          FilledButton.icon(onPressed: () async { await _save(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Financial snapshot saved on this device.'))); }, icon: const Icon(Icons.save_rounded), label: const Text('Save snapshot')),
          const SizedBox(height: 18),
          _metricCard('Monthly surplus', money(cash), cash >= 0 ? Colors.green : Colors.orange),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _small('Investment rate', '${savingsRate.toStringAsFixed(0)}%')), const SizedBox(width: 10), Expanded(child: _small('Debt / income', '${debtRatio.toStringAsFixed(0)}%')), const SizedBox(width: 10), Expanded(child: _small('Emergency cover', '${months.toStringAsFixed(1)} mo'))]),
          const SizedBox(height: 14),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Your next checks', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(height: 10), Text(cash < 0 ? 'Your entered monthly outgo exceeds income. Review the assumptions first.' : 'You have a positive monthly surplus. Consider assigning it between goals, emergency savings and investing.', style: const TextStyle(height: 1.45)), const SizedBox(height: 8), Text(months < 3 ? 'Emergency fund is below a 3-month planning benchmark.' : 'Your entered emergency fund covers about ${months.toStringAsFixed(1)} months of expenses + EMI.', style: const TextStyle(color: Color(0xFF6B7280), height: 1.4))]))),
          const SizedBox(height: 12),
          const Text('Planning only, not financial advice. Use your actual income, expenses, debt and savings figures.', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
  Widget _field(String label, TextEditingController c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: label, prefixText: '₹ '), onChanged: (_) => setState(() {})));
  Widget _metricCard(String title, String value, Color color) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [color.withValues(alpha: .14), Theme.of(context).cardColor])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF6B7280))), const SizedBox(height: 5), Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: color))]));
  Widget _small(String label, String value) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))), const SizedBox(height: 5), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))])));
}
