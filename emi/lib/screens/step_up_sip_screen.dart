import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';
import '../services/ad_service.dart';
import '../models/finance_models.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/ad_banner.dart';
import '../widgets/finance_input_slider.dart';

class StepUpSipScreen extends StatefulWidget {
  const StepUpSipScreen({super.key});

  @override
  State<StepUpSipScreen> createState() => _StepUpSipScreenState();
}

class _StepUpSipScreenState extends State<StepUpSipScreen> {
  final monthly = TextEditingController();
  final rate = TextEditingController();
  final step = TextEditingController();
  final years = TextEditingController();

  @override
  void initState() {
    super.initState();
    monthly.text = '10000';
    rate.text = '12';
    step.text = '10';
    years.text = '15';
  }

  void _recordHistory() {
    final m = double.tryParse(monthly.text.replaceAll(',', '').trim()) ?? 0;
    final r = double.tryParse(rate.text.trim()) ?? 0;
    final st = double.tryParse(step.text.trim()) ?? 0;
    final y = int.tryParse(years.text.trim()) ?? 0;
    final data = FinanceCalculator.stepUpSipBreakdown(initialMonthlyInvestment: m, annualRate: r, annualStepUp: st, years: y);
    if (data.isEmpty) return;
    final last = data.last;
    LocalStore.addHistory(CalculationRecord(type: 'step_up_sip', title: 'Step-up SIP', summary: 'Corpus ${money(last.corpus)} • ${money(m)}/month • ${st.toStringAsFixed(1)}% step-up • $y years', createdAt: DateTime.now(), inputs: {'monthly': m, 'rate': r, 'stepUp': st, 'years': y}));
  }

  @override
  void dispose() {
    for (final c in [monthly, rate, step, years]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = double.tryParse(monthly.text) ?? 0.0;
    final r = double.tryParse(rate.text) ?? 0.0;
    final s = double.tryParse(step.text) ?? 0.0;
    final y = int.tryParse(years.text) ?? 0;

    final data = FinanceCalculator.stepUpSipBreakdown(
      initialMonthlyInvestment: m,
      annualRate: r,
      annualStepUp: s,
      years: y,
    );
    final corpus = data.isEmpty ? 0.0 : data.last.corpus;
    final invested = data.isEmpty ? 0.0 : data.last.invested;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) AdService.popWithInterstitial(context, eligible: data.isNotEmpty);
      },
      child: Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AdService.popWithInterstitial(context, eligible: data.isNotEmpty),
        ),
        title: Text(AppStrings.translate(context, 'Step-up SIP'), style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        children: [
          _inputs(),
          const SizedBox(height: 15),
          if (data.isEmpty)
            _emptyState()
          else ...[
            _hero(corpus, invested),
            const FinanceBannerAd(),
            const SizedBox(height: 14),
            _chart(data),
            const SizedBox(height: 14),
            _yearList(data),
          ],
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'Calculation basis: SIP contributions are assumed at the beginning of each month, with the monthly planning rate derived by dividing the annual assumed return by 12. Returns are illustrative.',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.4),
            ),
          ),
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
        FinanceInputSlider(label: 'Starting monthly SIP', controller: monthly, suffix: '₹', min: 500, max: 1000000, divisions: 1999, step: 500, onChanged: (_) { setState(() {}); _recordHistory(); }),
        FinanceInputSlider(label: 'Expected return', controller: rate, suffix: '%', min: 0, max: 30, divisions: 300, step: .1, onChanged: (_) { setState(() {}); _recordHistory(); }),
        FinanceInputSlider(label: 'Yearly step-up', controller: step, suffix: '%', min: 0, max: 50, divisions: 100, step: .5, onChanged: (_) { setState(() {}); _recordHistory(); }),
        FinanceInputSlider(label: 'Duration', controller: years, suffix: 'yr', min: 1, max: 40, divisions: 39, integer: true, onChanged: (_) { setState(() {}); _recordHistory(); }),
      ]),
    );
  }

  Widget _hero(double corpus, double invested) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTIMATED CORPUS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(money(corpus), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 13),
          Row(
            children: [
              _pill('Invested', money(invested)),
              const SizedBox(width: 7),
              _pill('Returns', money(corpus - invested)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _chart(List<StepUpYear> data) {
    final visible = data.length > 15 ? data.sublist(data.length - 15) : data;
    final maxY = visible.map((e) => e.corpus).reduce((a, b) => a > b ? a : b);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => Container(
        height: 250,
        padding: const EdgeInsets.fromLTRB(10, 18, 18, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY <= 0 ? 1 : maxY * 1.12,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .07),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (v, meta) => Text(
                    v >= 100000 ? '${(v / 100000).toStringAsFixed(0)}L' : '${(v / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 9),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: visible.length <= 6 ? 1 : (visible.length / 5).ceilToDouble(),
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= visible.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text('${visible[i].year}', style: const TextStyle(fontSize: 9)),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int i = 0; i < visible.length; i++)
                    FlSpot(i.toDouble(), visible[i].corpus * progress),
                ],
                isCurved: true,
                barWidth: 3.2,
                color: const Color(0xFF7C3AED),
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: const Color(0x187C3AED)),
              ),
            ],
          ),
        ),
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
          Icon(Icons.trending_up_rounded, color: Color(0xFF7C3AED), size: 25),
          SizedBox(width: 12),
          Expanded(child: Text('Enter your SIP, return, step-up and duration to see the animated wealth journey.', style: TextStyle(fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }

  Widget _yearList(List<StepUpYear> data) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.translate(context, 'Year-wise plan'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 8),
          ...data.take(10).map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(radius: 14, child: Text('${e.year}', style: const TextStyle(fontSize: 10))),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Monthly SIP ${money(e.monthlyInvestment)}')),
                  Text(money(e.corpus), style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}