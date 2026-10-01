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