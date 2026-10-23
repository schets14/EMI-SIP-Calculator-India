import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';
import '../services/finance_extra.dart';
import '../services/finance_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/ad_banner.dart';
import '../widgets/finance_input_slider.dart';

class ExtraCalculatorsScreen extends StatelessWidget {
  const ExtraCalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More calculators', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: const [
          _ExtraCard(title: 'Fixed Deposit', subtitle: 'Estimate maturity and interest', icon: Icons.savings_rounded, child: FdCalculator()),
          SizedBox(height: 12),
          _ExtraCard(title: 'Recurring Deposit', subtitle: 'Estimate maturity from monthly deposits', icon: Icons.event_repeat_rounded, child: RdCalculator()),
          SizedBox(height: 12),
          _ExtraCard(title: 'PPF', subtitle: 'Plan a long-term PPF corpus', icon: Icons.account_balance_rounded, child: PpfCalculator()),
          SizedBox(height: 12),
          _ExtraCard(title: 'Home Loan', subtitle: 'EMI, interest and total repayment', icon: Icons.home_work_rounded, child: HomeLoanCalculator()),
          SizedBox(height: 12),
          _ExtraCard(title: 'Financial Goal', subtitle: 'Find the monthly SIP needed for a goal', icon: Icons.flag_rounded, child: GoalCalculator()),
        ],
      ),
    );
  }
}

class _ExtraCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Widget child;
  const _ExtraCard({required this.title, required this.subtitle, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: accent),
        ),
        title: Text(AppStrings.translate(context, title), style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 3), child: Text(AppStrings.translate(context, subtitle))),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => child)),
      ),
    );
  }
}

abstract class _ExtraBaseState<T extends StatefulWidget> extends State<T> {
  Widget page({required String title, required List<Widget> inputs, required Widget result, String? note, CalculationRecord? historyRecord}) {
    if (historyRecord != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) LocalStore.addHistory(historyRecord);
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.translate(context, title), style: const TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
              child: Column(children: inputs),
            ),
          ),
          const SizedBox(height: 14),
          const FinanceBannerAd(),
          const SizedBox(height: 10),
          result,
          if (note != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Text(note, style: TextStyle(fontSize: 11, height: 1.45, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ],
        ],
      ),
    );
  }

  Widget emptyResult(String title, String subtitle) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Icon(Icons.tune_rounded, color: Theme.of(context).colorScheme.primary, size: 25),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.translate(context, title), style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(AppStrings.translate(context, subtitle), style: TextStyle(fontSize: 12, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
      ]),
    ),
  );

  Widget resultCard({required String label, required double value, List<MapEntry<String, String>> rows = const []}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(AppStrings.translate(context, label), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(money(value), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            ...rows.map((e) => _row(AppStrings.translate(context, e.key), e.value)),
          ],
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.w800))]),
  );
}

class FdCalculator extends StatefulWidget { const FdCalculator({super.key}); @override State<FdCalculator> createState() => _FdCalculatorState(); }
class _FdCalculatorState extends _ExtraBaseState<FdCalculator> {
  final p = TextEditingController(), r = TextEditingController(), y = TextEditingController();
  @override
  void initState() { super.initState(); p.text = '500000'; r.text = '7'; y.text = '5'; }
  @override void dispose() { p.dispose(); r.dispose(); y.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final principal = double.tryParse(p.text) ?? 0, rate = double.tryParse(r.text) ?? 0, years = int.tryParse(y.text) ?? 0;
    final valid = principal > 0 && rate >= 0 && years > 0;
    final maturity = valid ? FinanceExtra.fdMaturity(principal: principal, annualRate: rate, years: years) : 0.0;
    return page(title: 'Fixed Deposit', inputs: [
      FinanceInputSlider(label: 'Principal amount', controller: p, suffix: '₹', min: 1000, max: 10000000, divisions: 9999, step: 1000, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Interest rate', controller: r, suffix: '%', min: 0, max: 15, divisions: 150, step: .1, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Tenure', controller: y, suffix: 'yr', min: 1, max: 20, divisions: 19, integer: true, onChanged: (_) => setState(() {})),
    ], result: valid ? resultCard(label: 'Maturity value', value: maturity, rows: [MapEntry('Principal', money(principal)), MapEntry('Interest earned', money(maturity - principal))]) : emptyResult('Enter FD assumptions', 'Move the sliders or type the values to calculate maturity.'), note: 'Illustration assumes quarterly compounding for whole years and a constant rate. Actual bank/post-office terms may differ.', historyRecord: valid ? CalculationRecord(type: 'fd', title: 'Fixed Deposit', summary: 'Maturity ${money(maturity)} • Principal ${money(principal)} • ${rate.toStringAsFixed(1)}% • $years years', createdAt: DateTime.now(), inputs: {'principal': principal, 'rate': rate, 'years': years}) : null);
  }
}

class RdCalculator extends StatefulWidget { const RdCalculator({super.key}); @override State<RdCalculator> createState() => _RdCalculatorState(); }
class _RdCalculatorState extends _ExtraBaseState<RdCalculator> {
  final p = TextEditingController(), r = TextEditingController(), y = TextEditingController();
  @override
  void initState() { super.initState(); p.text = '5000'; r.text = '6.5'; y.text = '5'; }
  @override void dispose() { p.dispose(); r.dispose(); y.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final monthly = double.tryParse(p.text) ?? 0, rate = double.tryParse(r.text) ?? 0, years = int.tryParse(y.text) ?? 0, months = years * 12;
    final valid = monthly > 0 && rate >= 0 && years > 0;
    final maturity = valid ? FinanceExtra.rdMaturity(monthlyDeposit: monthly, annualRate: rate, months: months) : 0.0;
    final invested = monthly * months;
    return page(title: 'Recurring Deposit', inputs: [
      FinanceInputSlider(label: 'Monthly deposit', controller: p, suffix: '₹', min: 100, max: 100000, divisions: 999, step: 100, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Interest rate', controller: r, suffix: '%', min: 0, max: 15, divisions: 150, step: .1, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Tenure', controller: y, suffix: 'yr', min: 1, max: 10, divisions: 9, integer: true, onChanged: (_) => setState(() {})),
    ], result: valid ? resultCard(label: 'Maturity value', value: maturity, rows: [MapEntry('Total deposits', money(invested)), MapEntry('Interest earned', money(maturity - invested))]) : emptyResult('Enter RD assumptions', 'Set the monthly deposit, rate and tenure to see the maturity value.'), note: 'Uses the standard Indian RD calculator approximation documented in this app. Actual bank calculations can differ by product and deposit timing.', historyRecord: valid ? CalculationRecord(type: 'rd', title: 'Recurring Deposit', summary: 'Maturity ${money(maturity)} • Deposit ${money(monthly)}/month • ${rate.toStringAsFixed(1)}% • $years years', createdAt: DateTime.now(), inputs: {'monthly': monthly, 'rate': rate, 'years': years}) : null);
  }
}

class PpfCalculator extends StatefulWidget { const PpfCalculator({super.key}); @override State<PpfCalculator> createState() => _PpfCalculatorState(); }
class _PpfCalculatorState extends _ExtraBaseState<PpfCalculator> {
  final p = TextEditingController(), r = TextEditingController(), y = TextEditingController();
  @override
  void initState() { super.initState(); p.text = '100000'; r.text = '7.1'; y.text = '15'; }
  @override void dispose() { p.dispose(); r.dispose(); y.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final yearly = double.tryParse(p.text) ?? 0, rate = double.tryParse(r.text) ?? 0, years = int.tryParse(y.text) ?? 0;
    final valid = yearly > 0 && rate >= 0 && years > 0;
    final maturity = valid ? FinanceExtra.ppfMaturity(yearlyDeposit: yearly, annualRate: rate, years: years) : 0.0;
    final invested = yearly * years;
    return page(title: 'PPF', inputs: [
      FinanceInputSlider(label: 'Yearly contribution', controller: p, suffix: '₹', min: 500, max: 150000, divisions: 299, step: 500, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Interest rate', controller: r, suffix: '%', min: 0, max: 12, divisions: 120, step: .1, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Tenure', controller: y, suffix: 'yr', min: 1, max: 30, divisions: 29, integer: true, onChanged: (_) => setState(() {})),
    ], result: valid ? resultCard(label: 'Projected corpus', value: maturity, rows: [MapEntry('Total contributions', money(invested)), MapEntry('Projected interest', money(maturity - invested))]) : emptyResult('Enter PPF assumptions', 'Set contribution, rate and duration to see the projected corpus.'), note: 'Illustration assumes the yearly contribution is made at the beginning of each year and the entered rate remains constant. PPF rates are notified by the government and can change.', historyRecord: valid ? CalculationRecord(type: 'ppf', title: 'PPF Calculator', summary: 'Corpus ${money(maturity)} • ${money(yearly)}/year • ${rate.toStringAsFixed(1)}% • $years years', createdAt: DateTime.now(), inputs: {'yearly': yearly, 'rate': rate, 'years': years}) : null);
  }
}

class HomeLoanCalculator extends StatefulWidget { const HomeLoanCalculator({super.key}); @override State<HomeLoanCalculator> createState() => _HomeLoanCalculatorState(); }
class _HomeLoanCalculatorState extends _ExtraBaseState<HomeLoanCalculator> {
  final p = TextEditingController(), r = TextEditingController(), y = TextEditingController();
  @override
  void initState() { super.initState(); p.text = '5000000'; r.text = '8.5'; y.text = '20'; }
  @override void dispose() { p.dispose(); r.dispose(); y.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final principal = double.tryParse(p.text) ?? 0, rate = double.tryParse(r.text) ?? 0, years = int.tryParse(y.text) ?? 0, months = years * 12;
    final valid = principal > 0 && rate >= 0 && years > 0;
    final emi = valid ? FinanceCalculator.emi(principal: principal, annualRate: rate, tenureMonths: months) : null;
    return page(title: 'Home Loan', inputs: [
      FinanceInputSlider(label: 'Loan amount', controller: p, suffix: '₹', min: 100000, max: 50000000, divisions: 4999, step: 10000, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Interest rate', controller: r, suffix: '%', min: 0, max: 15, divisions: 150, step: .1, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Tenure', controller: y, suffix: 'yr', min: 1, max: 30, divisions: 29, integer: true, onChanged: (_) => setState(() {})),
    ], result: valid && emi != null ? resultCard(label: 'Monthly EMI', value: emi.emi, rows: [MapEntry('Total interest', money(emi.totalInterest)), MapEntry('Total repayment', money(emi.totalPayment)), MapEntry('Loan amount', money(principal))]) : emptyResult('Enter home-loan assumptions', 'Set loan amount, rate and tenure to calculate EMI.'), note: 'Uses a standard reducing-balance EMI formula. Actual lender costs can include processing fees, insurance, taxes and other charges.', historyRecord: valid && emi != null ? CalculationRecord(type: 'home_loan', title: 'Home Loan', summary: 'EMI ${money(emi.emi)} • Loan ${money(principal)} • ${rate.toStringAsFixed(1)}% • $years years', createdAt: DateTime.now(), inputs: {'principal': principal, 'rate': rate, 'years': years}) : null);
  }
}

class GoalCalculator extends StatefulWidget { const GoalCalculator({super.key}); @override State<GoalCalculator> createState() => _GoalCalculatorState(); }
class _GoalCalculatorState extends _ExtraBaseState<GoalCalculator> {
  final g = TextEditingController(), s = TextEditingController(), r = TextEditingController(), y = TextEditingController();
  @override
  void initState() { super.initState(); g.text = '2500000'; s.text = '250000'; r.text = '12'; y.text = '10'; }
  @override void dispose() { g.dispose(); s.dispose(); r.dispose(); y.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final goal = double.tryParse(g.text) ?? 0, savings = double.tryParse(s.text) ?? 0, rate = double.tryParse(r.text) ?? 0, years = int.tryParse(y.text) ?? 0;
    final valid = goal > 0 && savings >= 0 && rate >= 0 && years > 0;
    final monthly = valid ? FinanceExtra.goalSip(goal: goal, currentSavings: savings, annualRate: rate, years: years) : 0.0;
    final invested = monthly * years * 12;
    final alreadyReached = valid && monthly == 0;
    return page(title: 'Financial Goal', inputs: [
      FinanceInputSlider(label: 'Goal amount', controller: g, suffix: '₹', min: 10000, max: 50000000, divisions: 4999, step: 10000, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Current savings', controller: s, suffix: '₹', min: 0, max: 50000000, divisions: 5000, step: 10000, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Expected return', controller: r, suffix: '%', min: 0, max: 20, divisions: 200, step: .1, onChanged: (_) => setState(() {})),
      FinanceInputSlider(label: 'Time to goal', controller: y, suffix: 'yr', min: 1, max: 40, divisions: 39, integer: true, onChanged: (_) => setState(() {})),
    ], result: valid ? (alreadyReached ? resultCard(label: 'Additional monthly SIP', value: 0, rows: [MapEntry('Status', 'Current savings already cover the goal under these assumptions')]) : resultCard(label: 'Required monthly SIP', value: monthly, rows: [MapEntry('Total new SIP contributions', money(invested)), MapEntry('Goal amount', money(goal))])) : emptyResult('Enter your goal assumptions', 'Set your target, current savings, expected return and time horizon.'), note: 'The required SIP is an illustration using the same beginning-of-month SIP convention as the main calculator. Investment returns are not guaranteed.', historyRecord: valid ? CalculationRecord(type: 'goal', title: 'Financial Goal', summary: 'Required SIP ${money(monthly)} • Goal ${money(goal)} • $years years', createdAt: DateTime.now(), inputs: {'goal': goal, 'savings': savings, 'rate': rate, 'years': years}) : null);
  }
}
