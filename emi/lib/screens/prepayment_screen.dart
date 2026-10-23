import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';
import '../services/ad_service.dart';
import '../models/finance_models.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/ad_banner.dart';
import '../widgets/finance_charts.dart';
import '../widgets/finance_input_slider.dart';

class PrepaymentScreen extends StatefulWidget {
  const PrepaymentScreen({super.key});

  @override
  State<PrepaymentScreen> createState() => _PrepaymentScreenState();
}

class _PrepaymentScreenState extends State<PrepaymentScreen> {
  final outstanding = TextEditingController();
  final emi = TextEditingController();
  final rate = TextEditingController();
  final months = TextEditingController();
  final prepay = TextEditingController();

  @override
  void initState() {
    super.initState();
    outstanding.text = '2500000';
    emi.text = '25000';
    rate.text = '8.5';
    months.text = '180';
    prepay.text = '250000';
  }

  void _recordHistory() {
    final o = double.tryParse(outstanding.text.replaceAll(',', '').trim()) ?? 0;
    final e = double.tryParse(emi.text.replaceAll(',', '').trim()) ?? 0;
    final r = double.tryParse(rate.text.trim()) ?? 0;
    final m = int.tryParse(months.text.trim()) ?? 0;
    final pp = double.tryParse(prepay.text.replaceAll(',', '').trim()) ?? 0;
    final result = FinanceCalculator.prepayment(outstanding: o, annualRate: r, remainingMonths: m, currentEmi: e, prepayment: pp);
    if (!result.valid) return;
    LocalStore.addHistory(CalculationRecord(type: 'prepayment', title: 'Loan Prepayment', summary: 'Interest saved ${money(result.interestSaved)} • Prepayment ${money(pp)}', createdAt: DateTime.now(), inputs: {'outstanding': o, 'emi': e, 'rate': r, 'months': m, 'prepayment': pp}));
  }

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) AdService.popWithInterstitial(context, eligible: result.valid);
      },
      child: Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AdService.popWithInterstitial(context, eligible: result.valid),
        ),
        title: Text(AppStrings.translate(context, 'Loan Prepayment'),
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        children: [
          _inputs(),
          const SizedBox(height: 16),
          if (!result.valid) _errorCard(result.error ?? 'Check the entered values.'),
          if (!result.valid) const SizedBox(height: 12),
          if (result.valid) _savingCard(result),
          const FinanceBannerAd(),
          const SizedBox(height: 14),
          if (result.valid) _comparison(result),
          if (result.valid) const SizedBox(height: 14),
          if (result.valid)
            FinanceChartCard(
              title: 'Interest impact',
              subtitle: 'Visual comparison of remaining interest',
              icon: Icons.bar_chart_rounded,
              child: AnimatedComparisonBars(
                before: result.oldTotalInterest,
                after: result.newTotalInterest,
                beforeLabel: 'Before',
                afterLabel: 'After',
              ),
            ),
          if (result.valid) const SizedBox(height: 14),
          _tip(),
        ],
      ),
      ),
    );
  }

  Widget _inputs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 6),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(25)),
      child: Column(children: [
        FinanceInputSlider(label: 'Outstanding loan', controller: outstanding, suffix: '₹', min: 10000, max: 50000000, divisions: 4999, step: 10000, onChanged: (_) { setState(() {}); _recordHistory(); }),
        FinanceInputSlider(label: 'Current EMI', controller: emi, suffix: '₹', min: 500, max: 1000000, divisions: 1999, step: 500, onChanged: (_) { setState(() {}); _recordHistory(); }),
        FinanceInputSlider(label: 'Interest rate', controller: rate, suffix: '%', min: 0, max: 20, divisions: 200, step: .1, onChanged: (_) { setState(() {}); _recordHistory(); }),
        FinanceInputSlider(label: 'Remaining tenure', controller: months, suffix: 'mo', min: 1, max: 360, divisions: 359, integer: true, onChanged: (_) { setState(() {}); _recordHistory(); }),
        FinanceInputSlider(label: 'Part-payment', controller: prepay, suffix: '₹', min: 0, max: 10000000, divisions: 1000, step: 10000, onChanged: (_) { setState(() {}); _recordHistory(); }),
      ]),
    );
  }

  Widget _savingCard(PrepaymentResult r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
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

  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFC2410C)),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF9A3412), height: 1.4))),
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
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF1EDFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFDCD3FF),
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
