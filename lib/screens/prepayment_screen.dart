import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/ad_banner.dart';

class PrepaymentScreen extends StatefulWidget {
  const PrepaymentScreen({super.key});

  @override
  State<PrepaymentScreen> createState() => _PrepaymentScreenState();
}

class _PrepaymentScreenState extends State<PrepaymentScreen> {
  final outstanding = TextEditingController(text: '800000');
  final emi = TextEditingController(text: '20000');
  final rate = TextEditingController(text: '9.5');
  final months = TextEditingController(text: '48');
  final prepay = TextEditingController(text: '100000');

  @override
  void dispose() {
    for (final c in [outstanding, emi, rate, months, prepay]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = double.tryParse(outstanding.text) ?? 0.0;
    final e = double.tryParse(emi.text) ?? 0.0;
    final r = double.tryParse(rate.text) ?? 0.0;
    final m = int.tryParse(months.text) ?? 0;
    final p = double.tryParse(prepay.text) ?? 0.0;

    final result = FinanceCalculator.prepayment(
      outstanding: o,
      annualRate: r,
      remainingMonths: m,
      currentEmi: e,
      prepayment: p,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Prepayment',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        children: [
          _inputs(),
          const SizedBox(height: 16),
          _savingCard(result),
          const FinanceBannerAd(),
          const SizedBox(height: 14),
          _comparison(result),
          const SizedBox(height: 14),
          _tip(),
        ],
      ),
    );
  }

  Widget _inputs() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _field('Outstanding loan', outstanding, '₹'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _field('Current EMI', emi, '₹')),
              const SizedBox(width: 10),
              Expanded(child: _field('Interest', rate, '%')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _field('Remaining', months, 'months')),
              const SizedBox(width: 10),
              Expanded(child: _field('Part-payment', prepay, '₹')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String suffix) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }

  Widget _savingCard(PrepaymentResult r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTIMATED INTEREST SAVED',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(
            money(r.interestSaved),
            style: const TextStyle(
                color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 9),
          Text(
            'After a ${money(r.prepayment)} part-payment',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _comparison(PrepaymentResult r) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _row('Loan balance after payment', money(r.newBalance)),
          _row('Old remaining tenure', '${r.oldMonths} months'),
          _row('New estimated tenure', '${r.newMonths} months'),
          _row('Interest before', money(r.oldTotalInterest)),
          _row('Interest after', money(r.newTotalInterest)),
          const Divider(height: 22),
          _row('Illustrative EMI on new balance', money(r.newEmi),
              strong: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value,
              style: TextStyle(
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _tip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF292442) : const Color(0xFFF1EDFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF51447D) : const Color(0xFFDCD3FF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF5B43C6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use the calculator as an estimate. Actual lender schedules can differ because of daily interest, fees, payment dates and lender rules.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color:
                    isDark ? const Color(0xFFD5D0E5) : const Color(0xFF4B465B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
