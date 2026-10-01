class FinanceExtra {
  static double fdMaturity({
    required double principal,
    required double annualRate,
    required int years,
    int compoundingPerYear = 4,
  }) {
    final n = compoundingPerYear;
    final periods = years * n;
    final r = annualRate / 100 / n;
    return principal * _pow(1 + r, periods);
  }

  static double rdMaturity({
    required double monthlyDeposit,
    required double annualRate,
    required int months,
  }) {
    final r = annualRate / 100 / 4;
    final quarters = (months / 3).ceil();
    if (r == 0) return monthlyDeposit * months;
    return monthlyDeposit * ((1 + r) * (_pow(1 + r, quarters) - 1) / r);
  }

  static double ppfMaturity({
    required double yearlyDeposit,
    required double annualRate,
    required int years,
  }) {
    double corpus = 0;
    final r = annualRate / 100;
    for (var year = 0; year < years; year++) {
      corpus = (corpus + yearlyDeposit) * (1 + r);
    }
    return corpus;
  }

  static double homeLoanEmi({
    required double principal,
    required double annualRate,
    required int months,
  }) {
    final r = annualRate / 12 / 100;
    if (months <= 0) return 0;
    if (r == 0) return principal / months;
    final factor = _pow(1 + r, months);
    return principal * r * factor / (factor - 1);
  }

  static double goalSip({
    required double goal,
    required double currentSavings,
    required double annualRate,
    required int years,
  }) {
    final months = years * 12;
    final r = annualRate / 12 / 100;
    final futureSavings = currentSavings * _pow(1 + r, months);
    final required = goal - futureSavings;
    if (required <= 0) return 0;
    if (r == 0) return required / months;
    return required * r / ((_pow(1 + r, months) - 1) * (1 + r));
  }

  static double _pow(double base, int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) result *= base;
    return result;
  }
}
