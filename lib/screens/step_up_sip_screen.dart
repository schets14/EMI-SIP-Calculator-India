import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/ad_banner.dart';

class StepUpSipScreen extends StatefulWidget {
  const StepUpSipScreen({super.key});

  @override
  State<StepUpSipScreen> createState() => _StepUpSipScreenState();
}

class _StepUpSipScreenState extends State<StepUpSipScreen> {
  final monthly = TextEditingController(text: '10000');
  final rate = TextEditingController(text: '12');
  final step = TextEditingController(text: '10');
  final years = TextEditingController(text: '15');

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step-up SIP', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
        children: [
          _inputs(),
          const SizedBox(height: 15),
          _hero(corpus, invested),
          const FinanceBannerAd(),
          const SizedBox(height: 14),
          _chart(data),
          const SizedBox(height: 14),
          _yearList(data),
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
          _field('Starting monthly SIP', monthly, '₹'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _field('Return', rate, '%')),
              const SizedBox(width: 10),
              Expanded(child: _field('Yearly step-up', step, '%')),
            ],
          ),
          const SizedBox(height: 10),
          _field('Duration', years, 'years'),
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

  Widget _hero(double corpus, double invested) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF7C3AED)],
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
    final maxY = visible.isEmpty ? 1.0 : visible.map((e) => e.corpus).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 18, 18, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY * 1.12,
          gridData: const FlGridData(show: false),
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
                  FlSpot(i.toDouble(), visible[i].corpus),
              ],
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0x225B5FEF)),
            ),
          ],
        ),
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
          const Text('Year-wise plan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
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