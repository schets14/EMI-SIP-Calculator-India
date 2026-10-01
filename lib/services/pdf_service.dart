import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/emi_result.dart';
import '../utils/formatters.dart';

class PdfService {
  static Future<void> shareAmortization({
    required double loanAmount,
    required double annualRate,
    required int tenureMonths,
    required EmiResult summary,
    required List<AmortizationRow> rows,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'EMI SIP Calculator India',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Loan Amortization Report'),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _pdfRow('Loan amount', money(loanAmount)),
              _pdfRow('Interest rate', '${annualRate.toStringAsFixed(2)}% p.a.'),
              _pdfRow('Tenure', '$tenureMonths months'),
              _pdfRow('Monthly EMI', money(summary.emi)),
              _pdfRow('Total interest', money(summary.totalInterest)),
              _pdfRow('Total payment', money(summary.totalPayment)),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Monthly schedule',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Month', 'EMI', 'Principal', 'Interest', 'Balance'],
            data: rows
                .map(
                  (r) => [
                    '${r.month}',
                    money(r.emi),
                    money(r.principal),
                    money(r.interest),
                    money(r.balance),
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Calculated by EMI SIP Calculator India. This report is for informational purposes.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'emi_sip_calculator_amortization.pdf',
    );
  }

  static pw.TableRow _pdfRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static Future<Uint8List> buildBytes({
    required String title,
    required List<List<String>> rows,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(data: rows),
          ],
        ),
      ),
    );
    return doc.save();
  }
}