import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/local_store.dart';
import '../services/app_strings.dart';
import '../services/ad_service.dart';
import '../utils/formatters.dart';
import '../services/finance_calculator.dart';
import '../widgets/app_card.dart';
import '../widgets/ad_banner.dart';

class GstItem {
  GstItem({String? name, double amount = 10000, double rate = 18})
      : name = TextEditingController(text: name ?? ''),
        amount = TextEditingController(text: amount.toStringAsFixed(0)),
        rate = rate;

  final TextEditingController name;
  final TextEditingController amount;
  double rate;

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

class GstScreen extends StatefulWidget {
  const GstScreen({super.key});

  @override
  State<GstScreen> createState() => _GstScreenState();
}

class _GstScreenState extends State<GstScreen> {
  final items = <GstItem>[
    GstItem(name: 'Item 1', amount: 10000, rate: 18),
    GstItem(name: 'Item 2', amount: 5000, rate: 5),
    GstItem(name: 'Item 3', amount: 2500, rate: 12),
  ];
  bool add = true;

  void _recordHistory() {
    if (!items.any((item) => _amount(item) > 0)) return;
    LocalStore.addHistory(CalculationRecord(type: 'gst', title: 'GST Calculator', summary: 'Total ${money(grandTotal)} • GST ${money(totalGst)} • ${items.length} items', createdAt: DateTime.now(), inputs: {'addTax': add, 'items': items.map((item) => {'name': item.name.text, 'amount': _amount(item), 'rate': item.rate}).toList()}));
  }

  @override
  void dispose() {
    for (final item in items) {
      item.dispose();
    }
    super.dispose();
  }

  double _amount(GstItem item) => double.tryParse(item.amount.text.replaceAll(',', '').trim()) ?? 0;

  double get totalBase => items.fold(0, (sum, item) {
        final result = FinanceCalculator.gst(amount: _amount(item), rate: item.rate, addTax: add);
        return sum + result.baseAmount;
      });

  double get totalGst => items.fold(0, (sum, item) {
        final result = FinanceCalculator.gst(amount: _amount(item), rate: item.rate, addTax: add);
        return sum + result.gstAmount;
      });

  double get grandTotal => items.fold(0, (sum, item) {
        final result = FinanceCalculator.gst(amount: _amount(item), rate: item.rate, addTax: add);
        return sum + result.totalAmount;
      });

  @override
  Widget build(BuildContext context) {
    final valid = items.any((item) => _amount(item) > 0);
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
          title: Text(AppStrings.translate(context, 'GST Calculator')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Multiple GST items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Add different products with their own GST rate and get one combined invoice total.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 14),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Add GST')),
                      ButtonSegment(value: false, label: Text('Remove GST')),
                    ],
                    selected: {add},
                    onSelectionChanged: (v) { setState(() => add = v.first); _recordHistory(); },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(items.length, (index) => _itemCard(index, items[index])),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => setState(() => items.add(GstItem(name: 'Item ${items.length + 1}', amount: 1000, rate: 18))),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add another item'),
            ),
            const SizedBox(height: 14),
            const FinanceBannerAd(),
            const SizedBox(height: 8),
            if (valid)
              AppCard(
                child: Column(
                  children: [
                    _row('Taxable amount', money(totalBase)),
                    _row('Total GST', money(totalGst)),
                    const Divider(),
                    _row(add ? 'Invoice total' : 'Original amount', money(grandTotal)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(int index, GstItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: item.name,
                    decoration: const InputDecoration(labelText: 'Item name', border: InputBorder.none),
                  ),
                ),
                if (items.length > 1)
                  IconButton(
                    tooltip: 'Remove item',
                    onPressed: () => setState(() {
                      item.dispose();
                      items.removeAt(index);
                    }),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
            const Divider(height: 8),
            TextField(
              controller: item.amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) { setState(() {}); _recordHistory(); },
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<double>(
              initialValue: item.rate,
              decoration: const InputDecoration(labelText: 'GST rate', border: OutlineInputBorder()),
              items: [0, 5, 12, 18, 28]
                  .map((v) => DropdownMenuItem(value: v.toDouble(), child: Text('$v%')))
                  .toList(),
              onChanged: (v) { setState(() => item.rate = v ?? 18); _recordHistory(); },
            ),
            const SizedBox(height: 10),
            Builder(builder: (_) {
              final result = FinanceCalculator.gst(amount: _amount(item), rate: item.rate, addTax: add);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GST: ${money(result.gstAmount)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(add ? 'Total: ${money(result.totalAmount)}' : 'Base: ${money(result.baseAmount)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
