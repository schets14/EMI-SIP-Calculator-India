class PrepaymentResult {
  final double outstanding;
  final double prepayment;
  final double newBalance;
  final double oldTotalInterest;
  final double newTotalInterest;
  final double interestSaved;
  final int oldMonths;
  final int newMonths;
  final double newEmi;
  final bool valid;
  final String? error;

  const PrepaymentResult({
    required this.outstanding,
    required this.prepayment,
    required this.newBalance,
    required this.oldTotalInterest,
    required this.newTotalInterest,
    required this.interestSaved,
    required this.oldMonths,
    required this.newMonths,
    required this.newEmi,
    this.valid = true,
    this.error,
  });
}

class StepUpYear {
  final int year;
  final double monthlyInvestment;
  final double invested;
  final double corpus;

  const StepUpYear({
    required this.year,
    required this.monthlyInvestment,
    required this.invested,
    required this.corpus,
  });
}
class GstResult {
  final double baseAmount;
  final double gstAmount;
  final double totalAmount;

  const GstResult({
    required this.baseAmount,
    required this.gstAmount,
    required this.totalAmount,
  });
}
