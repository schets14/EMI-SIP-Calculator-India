import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

String money(double value) => _currency.format(value);

String percent(double value) => '${value.toStringAsFixed(2)}%';

String indianCompact(double value) {
  final v = value.abs();
  final sign = value < 0 ? '-₹' : '₹';
  if (v >= 10000000) return '$sign${(v / 10000000).toStringAsFixed(v >= 100000000 ? 0 : 1)} Cr';
  if (v >= 100000) return '$sign${(v / 100000).toStringAsFixed(v >= 1000000 ? 0 : 1)} L';
  if (v >= 1000) return '$sign${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}K';
  return money(value);
}
