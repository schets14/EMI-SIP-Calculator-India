import 'package:flutter/material.dart';
import '../services/finance_extra.dart';
import '../utils/formatters.dart';
import '../widgets/ad_banner.dart';

class ExtraCalculatorsScreen extends StatelessWidget {
  const ExtraCalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More calculators',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ExtraCard(
            title: 'Fixed Deposit',
            subtitle: 'Estimate FD maturity',
            icon: Icons.savings_rounded,
            child: FdCalculator(),
          ),
          SizedBox(height: 12),
          _ExtraCard(
            title: 'Recurring Deposit',
            subtitle: 'Estimate RD maturity',
            icon: Icons.event_repeat_rounded,
            child: RdCalculator(),
          ),
          SizedBox(height: 12),
          _ExtraCard(
            title: 'PPF',
            subtitle: 'Plan long-term PPF corpus',
            icon: Icons.account_balance_rounded,
            child: PpfCalculator(),
          ),
          SizedBox(height: 12),
          _ExtraCard(
            title: 'Home Loan',
            subtitle: 'EMI and total interest',
            icon: Icons.home_work_rounded,
            child: HomeLoanCalculator(),
          ),
          SizedBox(height: 12),
          _ExtraCard(
            title: 'Financial Goal',
            subtitle: 'Monthly SIP needed for a goal',
            icon: Icons.flag_rounded,
            child: GoalCalculator(),
          ),
        ],
      ),
    );
  }
}

class _ExtraCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ExtraCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => child),
          );
        },
      ),
    );
  }
}

class _FieldSpec {
  final TextEditingController controller;
  final String label;
  final String suffix;

  const _FieldSpec(this.controller, this.label, this.suffix);
}

class FdCalculator extends StatefulWidget {
  const FdCalculator({super.key});

  @override
  State<FdCalculator> createState() => _FdCalculatorState();
}

class _FdCalculatorState extends State<FdCalculator> {
  final p = TextEditingController(text: '100000');
  final r = TextEditingController(text: '7');
  final y = TextEditingController(text: '5');

  @override
  void dispose() {
    p.dispose();
    r.dispose();
    y.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(p.text) ?? 0.0;
    final b = double.tryParse(r.text) ?? 0.0;
    final d = int.tryParse(y.text) ?? 0;
    final maturity = FinanceExtra.fdMaturity(
      principal: a,
      annualRate: b,
      years: d,
    );
    return _form(
      context,
      'Fixed Deposit',
      [_FieldSpec(p, 'Principal', '₹'), _FieldSpec(r, 'Rate', '%'), _FieldSpec(y, 'Years', '')],
      maturity,
      a,
      maturity - a,
    );
  }
}

class RdCalculator extends StatefulWidget {
  const RdCalculator({super.key});

  @override
  State<RdCalculator> createState() => _RdCalculatorState();
}

class _RdCalculatorState extends State<RdCalculator> {
  final p = TextEditingController(text: '5000');
  final r = TextEditingController(text: '6.5');
  final y = TextEditingController(text: '5');

  @override
  void dispose() {
    p.dispose();
    r.dispose();
    y.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(p.text) ?? 0.0;
    final b = double.tryParse(r.text) ?? 0.0;
    final d = (int.tryParse(y.text) ?? 0) * 12;
    final maturity = FinanceExtra.rdMaturity(
      monthlyDeposit: a,
      annualRate: b,
      months: d,
    );
    final invested = a * d;
    return _form(
      context,
      'Recurring Deposit',
      [_FieldSpec(p, 'Monthly deposit', '₹'), _FieldSpec(r, 'Rate', '%'), _FieldSpec(y, 'Years', '')],
      maturity,
      invested,
      maturity - invested,
    );
  }
}

class PpfCalculator extends StatefulWidget {
  const PpfCalculator({super.key});

  @override
  State<PpfCalculator> createState() => _PpfCalculatorState();
}

class _PpfCalculatorState extends State<PpfCalculator> {
  final p = TextEditingController(text: '150000');
  final r = TextEditingController(text: '7.1');
  final y = TextEditingController(text: '15');

  @override
  void dispose() {
    p.dispose();
    r.dispose();
    y.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(p.text) ?? 0.0;
    final b = double.tryParse(r.text) ?? 0.0;
    final d = int.tryParse(y.text) ?? 0;
    final maturity = FinanceExtra.ppfMaturity(
      yearlyDeposit: a,
      annualRate: b,
      years: d,
    );
    final invested = a * d;
    return _form(
      context,
      'PPF',
      [_FieldSpec(p, 'Yearly deposit', '₹'), _FieldSpec(r, 'Rate', '%'), _FieldSpec(y, 'Years', '')],
      maturity,
      invested,
      maturity - invested,
    );
  }
}

class HomeLoanCalculator extends StatefulWidget {
  const HomeLoanCalculator({super.key});

  @override
  State<HomeLoanCalculator> createState() => _HomeLoanCalculatorState();
}

class _HomeLoanCalculatorState extends State<HomeLoanCalculator> {
  final p = TextEditingController(text: '5000000');
  final r = TextEditingController(text: '8.5');
  final y = TextEditingController(text: '20');

  @override
  void dispose() {
    p.dispose();
    r.dispose();
    y.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(p.text) ?? 0.0;
    final b = double.tryParse(r.text) ?? 0.0;
    final years = int.tryParse(y.text) ?? 0;
    final months = years * 12;
    final monthlyEmi = FinanceExtra.homeLoanEmi(
      principal: a,
      annualRate: b,
      months: months,
    );
    final total = monthlyEmi * months;
    return _form(
      context,
      'Home Loan',
      [_FieldSpec(p, 'Loan amount', '₹'), _FieldSpec(r, 'Rate', '%'), _FieldSpec(y, 'Years', '')],
      monthlyEmi,
      total,
      total - a,
    );
  }
}

class GoalCalculator extends StatefulWidget {
  const GoalCalculator({super.key});

  @override
  State<GoalCalculator> createState() => _GoalCalculatorState();
}

class _GoalCalculatorState extends State<GoalCalculator> {
  final g = TextEditingController(text: '5000000');
  final s = TextEditingController(text: '500000');
  final r = TextEditingController(text: '12');
  final y = TextEditingController(text: '10');

  @override
  void dispose() {
    g.dispose();
    s.dispose();
    r.dispose();
    y.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = double.tryParse(g.text) ?? 0.0;
    final savings = double.tryParse(s.text) ?? 0.0;
    final rate = double.tryParse(r.text) ?? 0.0;
    final years = int.tryParse(y.text) ?? 0;
    final monthlySip = FinanceExtra.goalSip(
      goal: goal,
      currentSavings: savings,
      annualRate: rate,
      years: years,
    );
    final invested = monthlySip * years * 12;
    return _form(
      context,
      'Financial Goal',
      [_FieldSpec(g, 'Goal amount', '₹'), _FieldSpec(s, 'Current savings', '₹'), _FieldSpec(r, 'Expected return', '%'), _FieldSpec(y, 'Years', '')],
      monthlySip,
      invested,
      0.0,
    );
  }
}

Widget _form(
  BuildContext context,
  String title,
  List<_FieldSpec> fields,
  double main,
  double invested,
  double returns,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final field in fields) ...[
                  TextField(
                    controller: field.controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => (context as Element).markNeedsBuild(),
                    decoration: InputDecoration(
                      labelText: field.label,
                      suffixText: field.suffix,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const FinanceBannerAd(),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Estimated result',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 6),
                Text(
                  money(main),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                if (invested > 0.0) ...[
                  const SizedBox(height: 12),
                  _r('Invested / paid', money(invested)),
                  if (returns != 0.0) _r('Estimated benefit', money(returns)),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _r(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}
