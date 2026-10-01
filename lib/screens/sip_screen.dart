import 'package:flutter/material.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/ad_banner.dart';

class SipScreen extends StatefulWidget {
  const SipScreen({super.key});

  @override
  State<SipScreen> createState() => _SipScreenState();
}

class _SipScreenState extends State<SipScreen> {
  final investment = TextEditingController(text: '10000');
  final rate = TextEditingController(text: '12');
  final years = TextEditingController(text: '10');

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
    final future = FinanceCalculator.sipFutureValue(
      monthlyInvestment: monthly,
      annualRate: annualRate,
      years: duration,
    );
    final invested = monthly * duration * 12;

    return Scaffold(
      appBar: AppBar(title: const Text('SIP Calculator')),
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
          AppCard(
            child: Column(
              children: [
                const Text('Estimated value'),
                const SizedBox(height: 4),
                Text(
                  money(future),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _row('Invested amount', money(invested)),
                _row('Estimated returns', money(future - invested)),
                const SizedBox(height: 14),
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
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
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
