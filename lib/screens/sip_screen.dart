import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';
import '../services/ad_service.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/ad_banner.dart';
import '../widgets/finance_charts.dart';
import '../widgets/finance_input_slider.dart';

class SipScreen extends StatefulWidget {
  const SipScreen({super.key});

  @override
  State<SipScreen> createState() => _SipScreenState();
}

class _SipScreenState extends State<SipScreen> {
  final investment = TextEditingController();
  final rate = TextEditingController();
  final years = TextEditingController();

  @override
  void initState() {
    super.initState();
    investment.text = '10000';
    rate.text = '12';
    years.text = '15';
  }

  void _recordHistory() {
    final monthly = double.tryParse(investment.text.replaceAll(',', '').trim()) ?? 0;
    final annualRate = double.tryParse(rate.text.trim()) ?? 0;
    final duration = int.tryParse(years.text.trim()) ?? 0;
    if (monthly <= 0 || annualRate < 0 || duration <= 0) return;
    final future = FinanceCalculator.sipFutureValue(monthlyInvestment: monthly, annualRate: annualRate, years: duration);
    LocalStore.addHistory(CalculationRecord(
      type: 'sip', title: 'SIP Calculator',
      summary: 'Corpus ${money(future)} • ${money(monthly)}/month • ${annualRate.toStringAsFixed(1)}% • $duration years',
      createdAt: DateTime.now(), inputs: {'monthly': monthly, 'rate': annualRate, 'years': duration},
    ));
  }

  @override
  void dispose() {
    investment.dispose();
    rate.dispose();
    years.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthly = double.tryParse(investment.text) ?? 0;
    final annualRate = double.tryParse(rate.text) ?? 0;
    final duration = int.tryParse(years.text) ?? 0;
    final valid = monthly > 0 && annualRate >= 0 && duration > 0;
    final future = valid
        ? FinanceCalculator.sipFutureValue(
            monthlyInvestment: monthly,
            annualRate: annualRate,
            years: duration,
          )
        : 0.0;
    final invested = valid ? monthly * duration * 12 : 0.0;
    final yearlyInvested = <double>[];
    final yearlyCorpus = <double>[];
    if (valid) {
      for (var year = 1; year <= duration; year++) {
        final v = FinanceCalculator.sipFutureValue(
          monthlyInvestment: monthly, annualRate: annualRate, years: year);
        yearlyInvested.add(monthly * year * 12);
        yearlyCorpus.add(v);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) AdService.popWithInterstitial(context, eligible: valid);
      },
      child: Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AdService.popWithInterstitial(context, eligible: valid),
        ),
        title: Text(AppStrings.translate(context, 'SIP Calculator')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                _field('Monthly investment', investment, '₹'),
                _field('Expected return', rate, '% p.a.'),
                _field('Duration', years, 'years'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const FinanceBannerAd(),
          const SizedBox(height: 8),
          if (!valid)
            _emptyState()
          else ...[
          AppCard(
            child: Column(
              children: [
                const Text('Estimated value'),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: future),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => Text(
                  money(value),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                ),
                const SizedBox(height: 16),
                _row('Invested amount', money(invested)),
                _row('Estimated returns', money(future - invested)),
                const SizedBox(height: 14),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Calculation basis: monthly SIP is assumed at the beginning of each month; annual return is divided by 12. Actual mutual fund returns can differ.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.4),
                  ),
                ),
                const SizedBox(height: 4),
                Builder(builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF292442)
                          : const Color(0xFFF1EDFF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF51447D)
                            : const Color(0xFFDCD3FF),
                      ),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: isDark
                                ? const Color(0xFFC4B5FD)
                                : const Color(0xFF5B43C6),
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Smart insight: use the result as a scenario, not a guaranteed return. Try Step-up SIP to see how increasing the monthly amount changes the outcome.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: isDark
                                    ? const Color(0xFFD5D0E5)
                                    : const Color(0xFF4B465B),
                              ),
                            ),
                          ),
                        ]),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FinanceChartCard(
            title: 'Growth journey',
            subtitle: 'Projected corpus vs total amount invested',
            icon: Icons.show_chart_rounded,
            child: AnimatedSipChart(
              invested: yearlyInvested,
              corpus: yearlyCorpus,
              labels: [for (var i = 1; i <= duration; i++) 'Y$i'],
            ),
          ),
          const SizedBox(height: 14),
          FinanceChartCard(
            title: 'Invested vs returns',
            subtitle: 'See where the projected corpus comes from',
            icon: Icons.pie_chart_rounded,
            child: AnimatedCompositionChart(
              first: invested,
              second: future - invested,
              firstLabel: 'Invested',
              secondLabel: 'Estimated returns',
              firstColor: const Color(0xFF3B82F6),
              secondColor: const Color(0xFF059669),
            ),
          ),
          ],
        ],
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
          Icon(Icons.auto_graph_rounded, color: Color(0xFF3B82F6), size: 25),
          SizedBox(width: 12),
          Expanded(child: Text('Enter your SIP amount, return and duration to see animated projections.', style: TextStyle(fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, String suffix) {
    final isMoney = suffix.startsWith('₹');
    final isRate = suffix.startsWith('%');
    return FinanceInputSlider(
      label: label, controller: controller, suffix: suffix,
      min: isMoney ? 500 : (isRate ? 0 : 1),
      max: isMoney ? 1000000 : (isRate ? 30 : 40),
      divisions: isMoney ? 1999 : (isRate ? 300 : 39),
      step: isMoney ? 500 : (isRate ? .1 : 1),
      integer: !isMoney && !isRate,
      onChanged: (_) { setState(() {}); _recordHistory(); },
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
