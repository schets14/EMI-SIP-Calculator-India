import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/ad_service.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/finance_input_slider.dart';

class SipSwpScreen extends StatefulWidget {
  const SipSwpScreen({super.key});
  @override State<SipSwpScreen> createState() => _SipSwpScreenState();
}

class _SipSwpScreenState extends State<SipSwpScreen> {
  final sip = TextEditingController();
  final years = TextEditingController();
  final rate = TextEditingController();
  final withdrawal = TextEditingController();
  final swpYears = TextEditingController();
  @override
  void initState() {
    super.initState();
    sip.text = '10000';
    years.text = '15';
    rate.text = '12';
    withdrawal.text = '25000';
    swpYears.text = '10';
  }

  void _recordHistory() {
    final monthly = d(sip), yrs = n(years), rr = d(rate), w = d(withdrawal), wy = n(swpYears);
    if (monthly <= 0 || yrs <= 0 || rr < 0 || w <= 0 || wy <= 0) return;
    final corpus = FinanceCalculator.sipFutureValue(monthlyInvestment: monthly, annualRate: rr, years: yrs);
    final balance = FinanceCalculator.swpEndingBalance(corpus: corpus, annualRate: rr, monthlyWithdrawal: w, years: wy);
    LocalStore.addHistory(CalculationRecord(type: 'sip_swp', title: 'SIP → SWP Planner', summary: 'Corpus ${money(corpus)} • Withdrawal ${money(w)}/month • Balance ${money(balance)}', createdAt: DateTime.now(), inputs: {'sip': monthly, 'sipYears': yrs, 'rate': rr, 'withdrawal': w, 'swpYears': wy}));
  }

  @override void dispose() { for (final c in [sip, years, rate, withdrawal, swpYears]) { c.dispose(); } super.dispose(); }
  double d(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0;
  int n(TextEditingController c) => int.tryParse(c.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final monthly = d(sip), yrs = n(years), rr = d(rate), w = d(withdrawal), wy = n(swpYears);
    final corpus = FinanceCalculator.sipFutureValue(monthlyInvestment: monthly, annualRate: rr, years: yrs);
    final invested = monthly * yrs * 12;
    final balance = FinanceCalculator.swpEndingBalance(corpus: corpus, annualRate: rr, monthlyWithdrawal: w, years: wy);
    final exhausted = balance <= 0 && w > 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) AdService.popWithInterstitial(context, eligible: monthly > 0 && yrs > 0 && rr >= 0 && w > 0 && wy > 0);
      },
      child: Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AdService.popWithInterstitial(context, eligible: monthly > 0 && yrs > 0 && rr >= 0 && w > 0 && wy > 0),
        ),
        title: const Text('SIP → SWP Planner', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
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
      ),
    );
  }
  Widget _field(String label, TextEditingController c, String suffix) {
    final moneyField = suffix == '₹';
    final rateField = suffix == '%';
    return FinanceInputSlider(
      label: label, controller: c, suffix: suffix,
      min: moneyField ? 500 : 1,
      max: moneyField ? 1000000 : (rateField ? 30 : 40),
      divisions: moneyField ? 1999 : (rateField ? 300 : 39),
      step: moneyField ? 500 : (rateField ? .1 : 1),
      integer: !moneyField && !rateField,
      onChanged: (_) { setState(() {}); _recordHistory(); },
    );
  }
  Widget _card(String title, List<Widget> children) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(height: 12), ...children])));
  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(a)), Text(b, style: const TextStyle(fontWeight: FontWeight.w900))]));
}
