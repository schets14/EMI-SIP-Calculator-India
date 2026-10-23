import 'dart:math' as math;

/// Secondary deposit/goal calculations. Inputs are assumptions, not guaranteed returns.
class FinanceExtra {
  static const int _maxMonths = 1200;
  // Keep the ceiling below the exact-integer range when values are represented in paise.
  static const double _maxMoney = 9e13;
  static const double _maxRate = 1000.0;
  static const int _moneyScale = 100;

  static double _roundMoney(double value) {
    if (!value.isFinite) return value;
    return (value * _moneyScale).roundToDouble() / _moneyScale;
  }

  static bool _validMoney(double value, {bool allowZero = true}) =>
      value.isFinite && value >= (allowZero ? 0.0 : 1e-12) && value <= _maxMoney;

  static bool _validRate(double value) =>
      value.isFinite && value >= 0.0 && value <= _maxRate;

  static double _log1p(double x) {
    if (x.abs() < 1e-8) {
      var term = x;
      var sum = x;
      for (var n = 2; n <= 12; n++) {
        term *= -x * (n - 1) / n;
        sum += term;
      }
      return sum;
    }
    return math.log(1.0 + x);
  }

  /// FD maturity assuming [compoundingPerYear] compounding periods per year.
  /// The rate is nominal annual percent. The UI may choose quarterly compounding
  /// to mirror common Indian FD illustrations.
  static double fdMaturity({
    required double principal,
    required double annualRate,
    required int years,
    int compoundingPerYear = 4,
  }) {
    if (!_validMoney(principal) || !_validRate(annualRate) || years <= 0 ||
        compoundingPerYear <= 0 || years * compoundingPerYear > _maxMonths) return 0.0;
    if (principal == 0) return 0.0;
    if (annualRate == 0) return _roundMoney(principal);

    final periods = years * compoundingPerYear;
    final periodicRate = annualRate / 100.0 / compoundingPerYear;
    final exponent = periods * _log1p(periodicRate);
    final result = principal * math.exp(exponent);
    return result.isFinite && result <= _maxMoney ? _roundMoney(result) : 0.0;
  }

  /// Indian RD convention: monthly deposits, quarterly-compounded interest.
  /// Uses the standard Indian RD calculator approximation:
  /// M = P*n + P*n(n+1)/2 * r/400.
  static double rdMaturity({
    required double monthlyDeposit,
    required double annualRate,
    required int months,
  }) {
    if (!_validMoney(monthlyDeposit) || !_validRate(annualRate) ||
        months <= 0 || months > _maxMonths) return 0.0;
    if (annualRate == 0) return _roundMoney(monthlyDeposit * months);

    final n = months.toDouble();
    final result = monthlyDeposit * n +
        monthlyDeposit * n * (n + 1.0) * annualRate / 400.0;
    return result.isFinite && result <= _maxMoney ? _roundMoney(result) : 0.0;
  }

  /// PPF illustration assuming the yearly contribution is made at the beginning
  /// of each financial year and the stated annual rate remains constant.
  /// This is an illustration, not an official PPF interest calculator, because
  /// actual PPF interest depends on monthly balance timing and notified rates.
  static double ppfMaturity({
    required double yearlyDeposit,
    required double annualRate,
    required int years,
  }) {
    if (!_validMoney(yearlyDeposit) || !_validRate(annualRate) || years <= 0 || years > 100) return 0.0;
    var corpus = 0.0;
    final r = annualRate / 100.0;
    for (var year = 0; year < years; year++) {
      corpus = (corpus + yearlyDeposit) * (1.0 + r);
      if (!corpus.isFinite || corpus > _maxMoney) return 0.0;
    }
    return _roundMoney(corpus);
  }

  /// Monthly SIP required for a target using beginning-of-month contributions,
  /// consistent with the main SIP calculator.
  static double goalSip({
    required double goal,
    required double currentSavings,
    required double annualRate,
    required int years,
  }) {
    if (!_validMoney(goal) || !_validMoney(currentSavings) || !_validRate(annualRate) ||
        years <= 0 || years * 12 > _maxMonths) return 0.0;

    final months = years * 12;
    final r = annualRate / 1200.0;
    final growth = math.exp(months * _log1p(r));
    final futureSavings = currentSavings * growth;
    if (!futureSavings.isFinite) return 0.0;

    final required = goal - futureSavings;
    if (required <= 0) return 0.0;
    if (r.abs() < 1e-12) return _roundMoney(required / months);

    final annuityFactor = (growth - 1.0) / r * (1.0 + r);
    if (!annuityFactor.isFinite || annuityFactor <= 0) return 0.0;
    final result = required / annuityFactor;
    return result.isFinite && result <= _maxMoney ? _roundMoney(result) : 0.0;
  }
}
