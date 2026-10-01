import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import 'amortization_screen.dart';
import '../widgets/ad_banner.dart';

class EmiScreen extends StatefulWidget {
  const EmiScreen({super.key});

  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen> {
  final amount = TextEditingController(text: '1000000');
  final rate = TextEditingController(text: '9.5');
  final years = TextEditingController(text: '5');

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan EMI',
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
          _resultCard(result.emi),
          const SizedBox(height: 14),
          const FinanceBannerAd(),
          const SizedBox(height: 8),
          _breakdownCard(result.principal, result.totalInterest, interestRatio),
          const SizedBox(height: 14),
          _smartInsight(interestRatio),
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
            label: const Text('View full amortization'),
          ),
        ],
      ),
    );
  }

  Widget _inputCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A111827), blurRadius: 22, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          _field('Loan amount', amount, '₹'),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(child: _field('Interest rate', rate, '% p.a.')),
              const SizedBox(width: 10),
              Expanded(child: _field('Tenure', years, 'years')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, String suffix) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }

  Widget _resultCard(double emi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
        color: isDark ? const Color(0xFF292442) : const Color(0xFFF1EDFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF51447D) : const Color(0xFFDCD3FF),
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

  Widget _breakdownCard(double principal, double interest, double ratio) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 30,
                sectionsSpace: 2,
                sections: [
                  PieChartSectionData(
                    value: principal,
                    title: '${((1 - ratio) * 100).round()}%',
                    radius: 25,
                    titleStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800),
                    color: const Color(0xFF6366F1),
                  ),
                  PieChartSectionData(
                    value: interest,
                    title: '${(ratio * 100).round()}%',
                    radius: 25,
                    titleStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800),
                    color: const Color(0xFFA78BFA),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment breakdown',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                _legend('Principal', principal, const Color(0xFF6366F1)),
                const SizedBox(height: 8),
                _legend('Interest', interest, const Color(0xFFA78BFA)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, double value, Color color) {
    return Row(
      children: [
        Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text(money(value),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ],
    );
  }
}
