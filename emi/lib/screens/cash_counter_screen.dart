import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class CashCounterScreen extends StatefulWidget {
  const CashCounterScreen({super.key});

  @override
  State<CashCounterScreen> createState() => _CashCounterScreenState();
}

class _CashCounterScreenState extends State<CashCounterScreen> {
  final Map<int, int> _counts = {
    2000: 0, 500: 0, 200: 0, 100: 0, 50: 0,
    20: 0, 10: 0, 5: 0, 2: 0, 1: 0,
  };
  final _countControllers = <int, TextEditingController>{};
  final _expectedController = TextEditingController();

  double get total => _counts.entries.fold<double>(
        0, (sum, entry) => sum + entry.key * entry.value,
      );

  double get expected => double.tryParse(
        _expectedController.text.replaceAll(',', '').trim(),
      ) ?? 0;

  @override
  void initState() {
    super.initState();
    for (final denomination in _counts.keys) {
      _countControllers[denomination] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    for (final controller in _countControllers.values) {
      controller.dispose();
    }
    _expectedController.dispose();
    super.dispose();
  }

  void _recordHistory() {
    if (total <= 0 && _expectedController.text.trim().isEmpty) return;
    LocalStore.addHistory(CalculationRecord(type: 'cash_counter', title: 'Cash Counter', summary: 'Cash ${money(total)}${_expectedController.text.trim().isNotEmpty ? ' • Expected ${money(expected)}' : ''}', createdAt: DateTime.now(), inputs: {'counts': Map<String, int>.fromEntries(_counts.entries.map((e) => MapEntry('${e.key}', e.value))), 'expected': expected}));
  }

  void _setCount(int denomination, int value) {
    final safe = value.clamp(0, 9999);
    setState(() {
      _counts[denomination] = safe;
      _countControllers[denomination]?.text = '$safe';
      _countControllers[denomination]?.selection = TextSelection.collapsed(offset: '$safe'.length);
    });
    _recordHistory();
  }

  void _change(int denomination, int delta) {
    _setCount(denomination, (_counts[denomination] ?? 0) + delta);
  }

  void _clear() {
    setState(() {
      for (final key in _counts.keys) {
        _counts[key] = 0;
        _countControllers[key]?.text = '0';
      }
      _expectedController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final difference = total - expected;
    final hasExpected = _expectedController.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.translate(context, 'Cash Counter')),
        actions: [
          IconButton(
            tooltip: 'Clear',
            onPressed: _clear,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(Icons.payments_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cash in hand', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(money(total), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Count notes & coins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('Enter the note/coin count directly, or use + / − for quick adjustments.', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
          const SizedBox(height: 14),
          ..._counts.keys.map(_denominationTile),
          const SizedBox(height: 16),
          TextField(
            controller: _expectedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) { setState(() {}); _recordHistory(); },
            decoration: InputDecoration(
              labelText: 'Expected cash (optional)',
              prefixText: '₹ ',
              prefixIcon: const Icon(Icons.compare_arrows_rounded),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
            ),
          ),
          if (hasExpected) ...[
            const SizedBox(height: 12),
            _reconciliationCard(difference),
          ],
        ],
      ),
    );
  }

  Widget _denominationTile(int value) {
    final denomination = value;
    final count = _counts[value] ?? 0;
    final subtotal = value * count;
    final controller = _countControllers[value]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .45)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('₹$value', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹$value × $count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text(money(subtotal.toDouble()), style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
              ],
            ),
          ),
          _roundButton(Icons.remove_rounded, () => _change(value, -1)),
          const SizedBox(width: 6),
          SizedBox(
            width: 58,
            height: 40,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.w900),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              onChanged: (text) {
                final countValue = int.tryParse(text) ?? 0;
                _counts[denomination] = countValue.clamp(0, 9999);
                setState(() {});
              },
              onSubmitted: (text) => _setCount(value, int.tryParse(text) ?? 0),
            ),
          ),
          const SizedBox(width: 6),
          _roundButton(Icons.add_rounded, () => _change(value, 1)),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) => Material(
        color: AppTheme.primary.withValues(alpha: .10),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 19, color: AppTheme.primary)),
        ),
      );

  Widget _reconciliationCard(double difference) {
    final matched = difference.abs() < 0.01;
    final positive = difference > 0;
    final color = matched ? Colors.green : Colors.orange;
    final title = matched ? 'Cash matched' : positive ? 'Cash excess' : 'Cash short';
    final amount = difference.abs();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Row(
        children: [
          Icon(matched ? Icons.check_circle_rounded : Icons.warning_amber_rounded, color: color, size: 26),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(matched ? 'Actual cash equals expected cash.' : 'Difference: ${money(amount)}', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          ])),
        ],
      ),
    );
  }
}
