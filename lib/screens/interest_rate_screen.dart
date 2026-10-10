import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';
import '../services/ad_service.dart';
import '../services/finance_calculator.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/finance_input_slider.dart';

class InterestRateScreen extends StatefulWidget {
  const InterestRateScreen({super.key});

  @override
  State<InterestRateScreen> createState() => _InterestRateScreenState();
}

class _InterestRateScreenState extends State<InterestRateScreen> {
  final _amount = TextEditingController();
  final _emi = TextEditingController();
  final _months = TextEditingController();
  double? _rate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amount.text = '2500000';
    _emi.text = '25000';
    _months.text = '180';
  }

  @override
  void dispose() {
    _amount.dispose();
    _emi.dispose();
    _months.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amount.text.replaceAll(',', '').trim());
    final emi = double.tryParse(_emi.text.replaceAll(',', '').trim());
    final months = int.tryParse(_months.text.trim());
    if (amount == null || emi == null || months == null || amount <= 0 || emi <= 0 || months <= 0) {
      setState(() { _error = 'Enter a valid loan amount, EMI and remaining months.'; _rate = null; });
      return;
    }
    final minimumEmi = amount / months;
    if (emi < minimumEmi - 0.01) {
      setState(() { _error = 'EMI is too low for this amount and tenure. Check the values.'; _rate = null; });
      return;
    }
    final rate = FinanceCalculator.interestRateFromEmi(
      principal: amount,
      emi: emi,
      tenureMonths: months,
    );
    setState(() {
      _rate = rate;
      _error = rate == null ? 'These numbers do not produce a valid positive interest rate.' : null;
    });
    if (rate != null) {
      LocalStore.addHistory(CalculationRecord(type: 'interest_rate', title: 'Interest Rate Finder', summary: 'Rate ${rate.toStringAsFixed(2)}% • EMI ${money(emi)} • ${months} months', createdAt: DateTime.now(), inputs: {'amount': amount, 'emi': emi, 'months': months}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) AdService.popWithInterstitial(context, eligible: _rate != null);
      },
      child: Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AdService.popWithInterstitial(context, eligible: _rate != null),
        ),
        title: Text(AppStrings.translate(context, 'Interest Rate Finder')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(children: [
              Icon(Icons.percent_rounded, color: Colors.white, size: 30),
              SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Find the rate hidden in your EMI', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('Enter loan amount, EMI and remaining months.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 18),
          _field(_amount, 'Current loan amount', Icons.account_balance_wallet_rounded),
          const SizedBox(height: 12),
          _field(_emi, 'Monthly EMI', Icons.payments_rounded),
          const SizedBox(height: 12),
          _field(_months, 'Remaining months', Icons.calendar_month_rounded, integer: true),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_rounded),
              label: Text(AppStrings.translate(context, 'Calculate interest rate'), style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: .09), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [const Icon(Icons.info_outline_rounded, color: Colors.orange), const SizedBox(width: 9), Expanded(child: Text(_error!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))]),
            ),
          ],
          if (_rate != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: AppTheme.primary.withValues(alpha: .20)),
              ),
              child: Column(children: [
                const Text('Estimated annual interest rate', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                const SizedBox(height: 4),
                Text('${_rate!.toStringAsFixed(2)}% p.a.', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                const SizedBox(height: 9),
                Text('For ${indianCompact(double.parse(_amount.text))} outstanding and ${indianCompact(double.parse(_emi.text))} EMI over ${_months.text} months.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
              ]),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(17)),
            child: const Text('This is an estimate based on a standard reducing-balance EMI formula. Processing fees, insurance, GST, overdue charges and irregular payments can change the effective cost of a real loan.', style: TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.45)),
          ),
        ],
      ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool integer = false}) {
    final isAmount = label.contains('amount');
    final isEmi = label.contains('EMI');
    return FinanceInputSlider(
      label: label,
      controller: controller,
      suffix: isAmount || isEmi ? '₹' : 'mo',
      min: isAmount ? 10000 : (isEmi ? 500 : 1),
      max: isAmount ? 50000000 : (isEmi ? 1000000 : 360),
      divisions: isAmount ? 4999 : (isEmi ? 1999 : 359),
      step: isAmount ? 10000 : (isEmi ? 500 : 1),
      integer: integer || !isAmount && !isEmi,
      onChanged: (_) {
        if (_error != null || _rate != null) setState(() { _error = null; _rate = null; });
        else setState(() {});
      },
    );
  }
}
