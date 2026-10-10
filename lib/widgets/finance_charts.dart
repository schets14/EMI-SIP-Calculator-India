import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class FinanceChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final IconData icon;

  const FinanceChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon = Icons.insights_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class AnimatedSipChart extends StatelessWidget {
  final List<double> invested;
  final List<double> corpus;
  final List<String> labels;
  final bool compact;

  const AnimatedSipChart({
    super.key,
    required this.invested,
    required this.corpus,
    required this.labels,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [...invested, ...corpus].fold<double>(0, (m, v) => v > m ? v : m);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue * 1.12;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return SizedBox(
          height: compact ? 185 : 235,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: safeMax,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: safeMax / 4,
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
                    interval: safeMax / 4,
                    getTitlesWidget: (v, meta) => Text(
                      compact ? _shortMoney(v) : _shortMoney(v),
                      style: const TextStyle(fontSize: 8.5),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: labels.length <= 6 ? 1 : (labels.length / 5).ceilToDouble(),
                    getTitlesWidget: (v, meta) {
                      final i = v.round();
                      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(labels[i], style: const TextStyle(fontSize: 8.5)),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < corpus.length; i++)
                      FlSpot(i.toDouble(), corpus[i] * progress),
                  ],
                  isCurved: true,
                  barWidth: 3.2,
                  color: const Color(0xFF10B981),
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0x18059669),
                  ),
                ),
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < invested.length; i++)
                      FlSpot(i.toDouble(), invested[i] * progress),
                  ],
                  isCurved: true,
                  barWidth: 2.2,
                  color: const Color(0xFF3B82F6),
                  dotData: const FlDotData(show: false),
                  dashArray: [7, 5],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _shortMoney(double value) {
    if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(0)}k';
    return '₹${value.toStringAsFixed(0)}';
  }
}

class AnimatedCompositionChart extends StatelessWidget {
  final double first;
  final double second;
  final String firstLabel;
  final String secondLabel;
  final Color firstColor;
  final Color secondColor;

  const AnimatedCompositionChart({
    super.key,
    required this.first,
    required this.second,
    required this.firstLabel,
    required this.secondLabel,
    required this.firstColor,
    required this.secondColor,
  });

  @override
  Widget build(BuildContext context) {
    final total = first + second;
    if (total <= 0) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return SizedBox(
          height: 150,
          child: Row(
            children: [
              SizedBox(
                width: 145,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 38,
                    sectionsSpace: 3,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: first * progress,
                        color: firstColor,
                        radius: 29,
                        title: '${(first / total * 100).round()}%',
                        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                      PieChartSectionData(
                        value: second * progress,
                        color: secondColor,
                        radius: 29,
                        title: '${(second / total * 100).round()}%',
                        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legend(context, firstLabel, first, firstColor),
                    const SizedBox(height: 12),
                    _legend(context, secondLabel, second, secondColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legend(BuildContext context, String label, double value, Color color) {
    return Row(
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5))),
        Text(money(value), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class AnimatedComparisonBars extends StatelessWidget {
  final double before;
  final double after;
  final String beforeLabel;
  final String afterLabel;

  const AnimatedComparisonBars({
    super.key,
    required this.before,
    required this.after,
    this.beforeLabel = 'Before',
    this.afterLabel = 'After',
  });

  @override
  Widget build(BuildContext context) {
    final max = before > after ? before : after;
    if (max <= 0) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              maxY: max * 1.15,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final label = value.toInt() == 0 ? beforeLabel : afterLabel;
                      return Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: before * progress, width: 38, borderRadius: BorderRadius.circular(9), color: const Color(0xFF3B82F6))]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: after * progress, width: 38, borderRadius: BorderRadius.circular(9), color: const Color(0xFF10B981))]),
              ],
            ),
          ),
        );
      },
    );
  }
}
