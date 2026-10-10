import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';
import '../services/ad_service.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import 'amortization_screen.dart';
import '../widgets/ad_banner.dart';
import '../widgets/finance_charts.dart';
import '../widgets/finance_input_slider.dart';

class EmiScreen extends StatefulWidget {
  const EmiScreen({super.key});

  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen> {
  final amount = TextEditingController();
  final rate = TextEditingController();
  final years = TextEditingController();

  @override
  void initState() {
    super.initState();
    amount.text = '2500000';
    rate.text = '8.5';
    years.text = '20';
  }

  void _recordHistory() {
    final principal = double.tryParse(amount.text.replaceAll(',', '').trim()) ?? 0;
    final annualRate = double.tryParse(rate.text.trim()) ?? 0;
    final tenureYears = int.tryParse(years.text.trim()) ?? 0;
    if (principal <= 0 || annualRate < 0 || tenureYears <= 0) return;
    final result = FinanceCalculator.emi(principal: principal, annualRate: annualRate, tenureMonths: tenureYears * 12);
    LocalStore.addHistory(CalculationRecord(
      type: 'emi', title: 'Loan EMI',
      summary: 'EMI ${money(result.emi)} • ${money(principal)} • ${annualRate.toStringAsFixed(1)}% • $tenureYears years',
      createdAt: DateTime.now(),
      inputs: {'principal': principal, 'rate': annualRate, 'years': tenureYears},
    ));
  }

  @override
  void dispose() {
    amount.dispose();
    rate.dispose();
    years.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final principal = double.tryParse(amount.text) ?? 0;
    final annualRate = double.tryParse(rate.text) ?? 0;
    final tenureYears = int.tryParse(years.text) ?? 0;
    final tenureMonths = tenureYears * 12;

    final result = FinanceCalculator.emi(
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
    );

    final interestRatio = result.totalPayment == 0
        ? 0.0
        : result.totalInterest / result.totalPayment;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) AdService.popWithInterstitial(context, eligible: principal > 0 && tenureMonths > 0 && rate.text.trim().isNotEmpty);
      },
      child: Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AdService.popWithInterstitial(context, eligible: principal > 0 && tenureMonths > 0 && rate.text.trim().isNotEmpty),
        ),
        title: Text(AppStrings.translate(context, 'Loan EMI'),
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          _inputCard(),
          const SizedBox(height: 16),
          if (principal > 0 && tenureMonths > 0 && annualRate >= 0) ...[
            _resultCard(result.emi),
            const SizedBox(height: 14),
            const FinanceBannerAd(),
            const SizedBox(height: 8),
            FinanceChartCard(
              title: 'Loan composition',
              subtitle: 'Principal vs interest across the full repayment',
              icon: Icons.pie_chart_rounded,
              child: AnimatedCompositionChart(
                first: result.principal,
                second: result.totalInterest,
                firstLabel: 'Principal',
                secondLabel: 'Interest',
                firstColor: const Color(0xFF3B82F6),
                secondColor: const Color(0xFFA78BFA),
              ),
            ),
            const SizedBox(height: 14),
            _smartInsight(interestRatio),
          ] else
            _emptyState(),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17)),
            ),
            onPressed: tenureMonths > 0 && principal > 0
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AmortizationScreen(
                          principal: principal,
                          annualRate: annualRate,
                          tenureMonths: tenureMonths,
                        ),
                      ),
                    )
                : null,
            icon: const Icon(Icons.table_chart_rounded),
            label: Text(AppStrings.translate(context, 'View full amortization')),
          ),
        ],
      ),
      ),
    );
  }

  Widget _inputCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          FinanceInputSlider(label: 'Loan amount', controller: amount, suffix: '₹', min: 100000, max: 50000000, divisions: 4999, step: 10000, onChanged: (_) { setState(() {}); _recordHistory(); }),
          FinanceInputSlider(label: 'Interest rate', controller: rate, suffix: '%', min: 0, max: 20, divisions: 200, step: .1, onChanged: (_) { setState(() {}); _recordHistory(); }),
          FinanceInputSlider(label: 'Tenure', controller: years, suffix: 'yr', min: 1, max: 30, divisions: 29, integer: true, onChanged: (_) { setState(() {}); _recordHistory(); }),
        ],
      ),
    );
  }

  Widget _resultCard(double emi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A0A0A) : const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR MONTHLY EMI',
              style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 7),
          TweenAnimationBuilder<double>(
            key: ValueKey(emi),
            tween: Tween(begin: 0, end: emi),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              money(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _pill(Icons.check_circle_rounded, 'Instant result'),
              const SizedBox(width: 7),
              _pill(Icons.lock_outline_rounded, 'Private'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _smartInsight(double ratio) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = ratio >= .35
        ? 'A meaningful part of your total payment goes toward interest. Try the Prepayment tool to see how a lump-sum payment could change the scenario.'
        : 'Your principal makes up most of the projected payment. You can still compare a prepayment scenario before making a decision.';
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF1EDFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFDCD3FF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF5B43C6),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  'Smart insight',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF211A3D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark
                        ? const Color(0xFFD5D0E5)
                        : const Color(0xFF4B465B),
                  ),
                ),
              ])),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .06)),
      ),
      child: const Row(
        children: [
          Icon(Icons.calculate_rounded, color: Color(0xFF3B82F6), size: 25),
          SizedBox(width: 12),
          Expanded(child: Text('Enter the loan amount, rate and tenure to see the animated EMI breakdown.', style: TextStyle(fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }

}
