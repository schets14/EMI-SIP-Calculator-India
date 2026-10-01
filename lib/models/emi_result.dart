class EmiResult {
  final double emi;
  final double totalInterest;
  final double totalPayment;
  final double principal;

  const EmiResult({
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.principal,
  });
}

class AmortizationRow {
  final int month;
  final double emi;
  final double principal;
  final double interest;
  final double balance;

  const AmortizationRow({
    required this.month,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}
