import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/ad_banner.dart';

class GstScreen extends StatefulWidget {
  const GstScreen({super.key});

  @override
  State<GstScreen> createState() => _GstScreenState();
}

class _GstScreenState extends State<GstScreen> {
  final amount = TextEditingController(text: '1000');
  double gst = 18;
  bool add = true;

  @override
  Widget build(BuildContext context) {
    final base = double.tryParse(amount.text) ?? 0;
    final gstAmount = add ? base * gst / 100 : base * gst / (100 + gst);
    final total = add ? base + gstAmount : base - gstAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('GST Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Add GST')),
                    ButtonSegment(value: false, label: Text('Remove GST')),
                  ],
                  selected: {add},
                  onSelectionChanged: (v) => setState(() => add = v.first),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<double>(
                  initialValue: gst,
                  decoration: const InputDecoration(
                    labelText: 'GST rate',
                    border: OutlineInputBorder(),
                  ),
                  items: [5, 12, 18, 28]
                      .map((v) => DropdownMenuItem(value: v.toDouble(), child: Text('$v%')))
                      .toList(),
                  onChanged: (v) => setState(() => gst = v ?? 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const FinanceBannerAd(),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                _row('Base amount', money(total)),
                _row('GST', money(gstAmount)),
                const Divider(),
                _row('Final amount', money(add ? total : base)),
              ],
            ),
          ),
        ],
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
