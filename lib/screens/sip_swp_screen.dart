import 'package:flutter/material.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';

class SipSwpScreen extends StatefulWidget {
  const SipSwpScreen({super.key});
  @override State<SipSwpScreen> createState() => _SipSwpScreenState();
}

class _SipSwpScreenState extends State<SipSwpScreen> {
  final sip = TextEditingController(text: '15000');
  final years = TextEditingController(text: '15');
  final rate = TextEditingController(text: '12');
  final withdrawal = TextEditingController(text: '50000');
  final swpYears = TextEditingController(text: '20');
  @override void dispose() { for (final c in [sip, years, rate, withdrawal, swpYears]) { c.dispose(); } super.dispose(); }
  double d(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0;
  int n(TextEditingController c) => int.tryParse(c.text) ?? 0;
  double swpBalance(double corpus, double annualRate, double monthlyWithdrawal, int years) { double b = corpus; final r = annualRate / 12 / 100; for (var i = 0; i < years * 12 && b > 0; i++) { b = b * (1 + r) - monthlyWithdrawal; if (b < 0) b = 0; } return b; }

  @override
  Widget build(BuildContext context) {
    final monthly = d(sip), yrs = n(years), rr = d(rate), w = d(withdrawal), wy = n(swpYears);
    final corpus = FinanceCalculator.sipFutureValue(monthlyInvestment: monthly, annualRate: rr, years: yrs);
    final invested = monthly * yrs * 12;
    final balance = swpBalance(corpus, rr, w, wy);
    final exhausted = balance <= 0 && w > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('SIP → SWP Planner', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
        children: [
          const Text('Plan the accumulation phase, then test a monthly withdrawal from the estimated corpus.', style: TextStyle(color: Color(0xFF6B7280), height: 1.4)),
          const SizedBox(height: 16),
          _field('Monthly SIP', sip, '₹'), _field('SIP years', years, 'years'), _field('Expected return', rate, '%'),
          const SizedBox(height: 10),
          _card('Accumulation phase', [_row('Total invested', money(invested)), _row('Estimated corpus', money(corpus)), _row('Estimated gains', money(corpus - invested))]),
          const SizedBox(height: 12),
          _field('Monthly SWP withdrawal', withdrawal, '₹'), _field('SWP years', swpYears, 'years'),
          _card('Withdrawal phase', [_row('Estimated balance', money(balance)), _row('Planned withdrawals', money(w * wy * 12)), Text(exhausted ? 'At these assumptions, the estimated corpus is exhausted before the selected period.' : 'At these assumptions, the estimated corpus remains after the selected period.', style: TextStyle(color: exhausted ? Colors.orange : Colors.green, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 12),
          const Text('Illustration only. Actual investment returns, taxes, exit loads and withdrawal outcomes can differ.', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
  Widget _field(String label, TextEditingController c, String suffix) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: label, suffixText: suffix), onChanged: (_) => setState(() {})));
  Widget _card(String title, List<Widget> children) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(height: 12), ...children])));
  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(a)), Text(b, style: const TextStyle(fontWeight: FontWeight.w900))]));
}
