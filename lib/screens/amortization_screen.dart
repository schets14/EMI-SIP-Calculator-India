import 'package:flutter/material.dart';
import '../services/finance_calculator.dart';
import '../services/pdf_service.dart';
import '../utils/formatters.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner.dart';

class AmortizationScreen extends StatelessWidget {
  final double principal;
  final double annualRate;
  final int tenureMonths;

  const AmortizationScreen({
    super.key,
    required this.principal,
    required this.annualRate,
    required this.tenureMonths,
  });

  @override
  Widget build(BuildContext context) {
    final rows = FinanceCalculator.amortization(
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
    );
    final summary = FinanceCalculator.emi(
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amortization', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            onPressed: () async {
              await AdService.showAfterReportRequest();
              await PdfService.shareAmortization(
                loanAmount: principal,
                annualRate: annualRate,
                tenureMonths: tenureMonths,
                summary: summary,
                rows: rows,
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Row(
              children: [
                Expanded(child: _summary('EMI', money(summary.emi))),
                Expanded(child: _summary('Interest', money(summary.totalInterest))),
                Expanded(child: _summary('Total', money(summary.totalPayment))),
              ],
            ),
          ),
          const FinanceBannerAd(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 44,
                  dataRowMinHeight: 43,
                  columns: const [
                    DataColumn(label: Text('Month')),
                    DataColumn(label: Text('EMI')),
                    DataColumn(label: Text('Principal')),
                    DataColumn(label: Text('Interest')),
                    DataColumn(label: Text('Balance')),
                  ],
                  rows: rows
                      .map(
                        (r) => DataRow(
                          cells: [
                            DataCell(Text('${r.month}')),
                            DataCell(Text(money(r.emi))),
                            DataCell(Text(money(r.principal))),
                            DataCell(Text(money(r.interest))),
                            DataCell(Text(money(r.balance))),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ],
    );
  }
}