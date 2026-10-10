import 'dart:math' as math;

import '../models/emi_result.dart';
import '../models/finance_models.dart';

/// Central source of truth for every loan/investment calculation in the app.
///
/// Conventions:
/// - Loan rates are nominal annual reducing-balance rates; monthly rate = annual / 12 / 100.
/// - EMI math is kept at full precision internally. UI formatting rounds only for display.
/// - Amortization uses the calculated EMI and adjusts the final instalment so the balance
///   reaches exactly zero. This avoids artificial residual balances caused by rounding.
/// - SIP assumes contributions at the beginning of each month and annual return / 12 as
///   the monthly planning rate. This matches the conventional SIP formula used by many
///   Indian calculators. Returns are estimates, not guarantees.
class FinanceCalculator {
  static const double _epsilon = 1e-12;
  static const int _maxMonths = 1200; // 100 years; prevents pathological input.
  static const double _maxRate = 1000.0; // percentage/year; keeps calculations finite.
  // Keep the monetary ceiling below the exact-integer range of IEEE-754 doubles
  // once values are converted to paise (2^53 / 100 ~= 9.0e13).
  static const double _maxMoney = 9e13;
  static const int _moneyScale = 100; // paise precision for user-facing monetary values.

  static bool _validFinite(double value) => value.isFinite;

  /// Deterministic financial rounding: nearest paise, away from the zero boundary
  /// only through the normal half-up behavior of [double]. Internal math remains
  /// full precision; rounding is applied at monetary boundaries/schedule rows.
  static double _roundMoney(double value) {
    if (!value.isFinite) return value;
    return (value * _moneyScale).roundToDouble() / _moneyScale;
  }

  static bool _validMoney(double value, {bool allowZero = true}) =>
      value.isFinite && value >= (allowZero ? 0.0 : _epsilon) && value <= _maxMoney;

  static bool _validRate(double value) =>
      value.isFinite && value >= 0.0 && value <= _maxRate;

  static bool _validMonths(int value) => value > 0 && value <= _maxMonths;

  static double _monthlyLoanRate(double annualRate) => annualRate / 1200.0;

  static double _monthlySipRate(double annualRate) => annualRate / 1200.0;

  // Stable equivalents for the ranges used by financial calculations. Dart's
  // math library does not expose log1p/expm1 on all supported runtimes.
  static double _log1p(double x) {
    if (x.abs() < 1e-8) {
      // Alternating series avoids losing precision when x is very small.
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

  static double _expm1(double x) {
    if (x.abs() < 1e-6) {
      var term = x;
      var sum = x;
      for (var n = 2; n <= 12; n++) {
        term *= x / n;
        sum += term;
      }
      return sum;
    }
    return math.exp(x) - 1.0;
  }

  static double _futureValueFactor(double monthlyRate, int months) {
    if (months <= 0) return 0.0;
    if (monthlyRate.abs() < _epsilon) return months.toDouble();
    final logGrowth = _log1p(monthlyRate) * months;
    final numerator = _expm1(logGrowth);
    if (!numerator.isFinite) return double.infinity;
    return numerator / monthlyRate;
  }

  static double? _rawEmi({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) {
    if (!_validMoney(principal, allowZero: false) ||
        !_validRate(annualRate) ||
        !_validMonths(tenureMonths)) return null;

    if (annualRate.abs() < _epsilon) return principal / tenureMonths;

    final r = _monthlyLoanRate(annualRate);
    final denominator = -_expm1(-tenureMonths * _log1p(r));
    if (!denominator.isFinite || denominator <= 0) return null;

    final payment = principal * r / denominator;
    return payment.isFinite && payment > 0 ? payment : null;
  }

  static EmiResult emi({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) {
    final payment = _rawEmi(
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
    );
    if (payment == null) {
      return const EmiResult(emi: 0, totalInterest: 0, totalPayment: 0, principal: 0);
    }

    final roundedPayment = _roundMoney(payment);
    if (!_validMoney(roundedPayment, allowZero: false)) {
      return const EmiResult(emi: 0, totalInterest: 0, totalPayment: 0, principal: 0);
    }

    // Derive totals from the same paise-rounded amortization model used by the
    // schedule screen. This guarantees that headline totals and the detailed
    // schedule reconcile exactly.
    final schedule = amortization(
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
      fixedEmi: roundedPayment,
    );
    if (schedule.isEmpty || schedule.last.balance != 0.0) {
      return const EmiResult(emi: 0, totalInterest: 0, totalPayment: 0, principal: 0);
    }
    final totalPayment = _roundMoney(
      schedule.fold<double>(0.0, (sum, row) => sum + row.emi),
    );
    final totalInterest = _roundMoney(
      schedule.fold<double>(0.0, (sum, row) => sum + row.interest),
    );
    return EmiResult(
      emi: roundedPayment,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      principal: _roundMoney(principal),
    );
  }

  /// Generates a reducing-balance schedule.
  ///
  /// If [fixedEmi] is supplied, it is treated as the actual recurring payment and
  /// the schedule continues until the balance is cleared (or until [tenureMonths]
  /// is reached). The last payment is automatically reduced when necessary.
  static List<AmortizationRow> amortization({
    required double principal,
    required double annualRate,
    required int tenureMonths,
    double? fixedEmi,
  }) {
    if (!_validMoney(principal, allowZero: false) || !_validRate(annualRate) ||
        !_validMonths(tenureMonths)) {
      return const <AmortizationRow>[];
    }

    final calculatedEmi = _rawEmi(
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
    );
    final payment = fixedEmi ?? (calculatedEmi == null ? 0.0 : _roundMoney(calculatedEmi));
    if (!_validMoney(payment, allowZero: false)) return const <AmortizationRow>[];

    final monthlyRate = _monthlyLoanRate(annualRate);
    final result = <AmortizationRow>[];
    var balance = principal;

    for (var month = 1; month <= tenureMonths && balance > 0.005; month++) {
      final rawInterest = balance * monthlyRate;
      var rawPrincipalPart = payment - rawInterest;

      // EMI below monthly interest can never amortize the loan.
      if (rawPrincipalPart <= 0) return const <AmortizationRow>[];

      // Apply paise rounding to each schedule component, then reconcile the
      // principal against the rounded opening balance. This mirrors how a
      // customer-facing loan schedule is normally represented.
      final interest = _roundMoney(rawInterest);
      var principalPart = _roundMoney(rawPrincipalPart);
      final openingBalance = _roundMoney(balance);
      if (principalPart > openingBalance || month == tenureMonths) {
        principalPart = openingBalance;
      }

      final actualPayment = _roundMoney(principalPart + interest);
      balance = _roundMoney(openingBalance - principalPart);
      if (balance.abs() <= 0.01) balance = 0.0;

      result.add(AmortizationRow(
        month: month,
        emi: actualPayment,
        principal: principalPart,
        interest: interest,
        balance: balance,
      ));
    }

    return result;
  }

  static PrepaymentResult prepayment({
    required double outstanding,
    required double annualRate,
    required int remainingMonths,
    required double currentEmi,
    required double prepayment,
  }) {
    if (!_validMoney(outstanding, allowZero: false) ||
        !_validRate(annualRate) ||
        !_validMoney(currentEmi, allowZero: false) ||
        !_validMoney(prepayment) ||
        !_validMonths(remainingMonths)) {
      return const PrepaymentResult(
        outstanding: 0,
        prepayment: 0,
        newBalance: 0,
        oldTotalInterest: 0,
        newTotalInterest: 0,
        interestSaved: 0,
        oldMonths: 0,
        newMonths: 0,
        newEmi: 0,
        valid: false,
        error: 'Enter a valid outstanding balance, EMI, rate and remaining tenure.',
      );
    }

    final safePrepayment = prepayment.clamp(0.0, outstanding).toDouble();
    final newBalance = outstanding - safePrepayment;

    final oldSchedule = amortization(
      principal: outstanding,
      annualRate: annualRate,
      tenureMonths: remainingMonths,
      fixedEmi: currentEmi,
    );
    final newSchedule = newBalance <= 0
        ? const <AmortizationRow>[]
        : amortization(
            principal: newBalance,
            annualRate: annualRate,
            tenureMonths: remainingMonths,
            fixedEmi: currentEmi,
          );

    final oldInterest = oldSchedule.fold<double>(0.0, (sum, row) => sum + row.interest);
    final newInterest = newSchedule.fold<double>(0.0, (sum, row) => sum + row.interest);

    // If current EMI is too small to amortize the loan, surface zero savings instead
    // of pretending that the truncated schedule is a valid payoff schedule.
    final oldValid = oldSchedule.isNotEmpty && oldSchedule.last.balance <= 0.005;
    final newValid = newBalance <= 0 || (newSchedule.isNotEmpty && newSchedule.last.balance <= 0.005);

    if (!oldValid) {
      return PrepaymentResult(
        outstanding: outstanding,
        prepayment: safePrepayment,
        newBalance: newBalance,
        oldTotalInterest: 0.0,
        newTotalInterest: 0.0,
        interestSaved: 0.0,
        oldMonths: 0,
        newMonths: 0,
        newEmi: newBalance <= 0 ? 0.0 : emi(principal: newBalance, annualRate: annualRate, tenureMonths: remainingMonths).emi,
        valid: false,
        error: 'Current EMI is too low to clear the loan within the entered remaining tenure.',
      );
    }

    return PrepaymentResult(
      outstanding: outstanding,
      prepayment: safePrepayment,
      newBalance: newBalance,
      oldTotalInterest: oldValid ? oldInterest : 0.0,
      newTotalInterest: newValid ? newInterest : 0.0,
      interestSaved: oldValid && newValid ? math.max(0.0, oldInterest - newInterest) : 0.0,
      oldMonths: oldValid ? oldSchedule.length : 0,
      newMonths: newValid ? newSchedule.length : 0,
      // This is the illustrative EMI if the borrower keeps the original remaining
      // tenure after prepayment. It is NOT the EMI when the lender keeps EMI unchanged.
      newEmi: newBalance <= 0
          ? 0.0
          : emi(
              principal: newBalance,
              annualRate: annualRate,
              tenureMonths: remainingMonths,
            ).emi,
    );
  }

  static double sipFutureValue({
    required double monthlyInvestment,
    required double annualRate,
    required int years,
  }) {
    if (!_validMoney(monthlyInvestment) || !_validRate(annualRate) || years <= 0 || years * 12 > _maxMonths) {
      return 0.0;
    }

    final months = years * 12;
    final r = _monthlySipRate(annualRate);
    final factor = _futureValueFactor(r, months);
    if (!factor.isFinite) return 0.0;

    final result = monthlyInvestment * factor * (1.0 + r);
    return result.isFinite ? _roundMoney(result) : 0.0;
  }

  static GstResult gst({
    required double amount,
    required double rate,
    required bool addTax,
  }) {
    if (!_validMoney(amount) || !_validRate(rate)) {
      return const GstResult(baseAmount: 0, gstAmount: 0, totalAmount: 0);
    }

    if (addTax) {
      final tax = amount * rate / 100.0;
      final total = amount + tax;
      if (!tax.isFinite || !total.isFinite || total > _maxMoney) {
        return const GstResult(baseAmount: 0, gstAmount: 0, totalAmount: 0);
      }
      return GstResult(baseAmount: _roundMoney(amount), gstAmount: _roundMoney(tax), totalAmount: _roundMoney(total));
    }

    // When the entered amount is GST-inclusive, extract the tax portion.
    final tax = amount * rate / (100.0 + rate);
    final base = amount - tax;
    if (!tax.isFinite || !base.isFinite || base < 0) {
      return const GstResult(baseAmount: 0, gstAmount: 0, totalAmount: 0);
    }
    return GstResult(baseAmount: _roundMoney(base), gstAmount: _roundMoney(tax), totalAmount: _roundMoney(amount));
  }

  /// Simulates a monthly SWP with growth applied before each month's withdrawal.
  /// This makes the timing assumption explicit and reusable across screens.
  static double swpEndingBalance({
    required double corpus,
    required double annualRate,
    required double monthlyWithdrawal,
    required int years,
  }) {
    if (!_validMoney(corpus) || !_validRate(annualRate) || !_validMoney(monthlyWithdrawal) ||
        years <= 0 || years * 12 > _maxMonths) return 0.0;

    var balance = corpus;
    final r = _monthlySipRate(annualRate);
    for (var i = 0; i < years * 12 && balance > 1e-7; i++) {
      balance = balance * (1.0 + r) - monthlyWithdrawal;
      if (!balance.isFinite) return 0.0;
      if (balance < 0) balance = 0.0;
    }
    return _roundMoney(balance);
  }

  static double stepUpSipFutureValue({
    required double initialMonthlyInvestment,
    required double annualRate,
    required double annualStepUp,
    required int years,
  }) {
    final breakdown = stepUpSipBreakdown(
      initialMonthlyInvestment: initialMonthlyInvestment,
      annualRate: annualRate,
      annualStepUp: annualStepUp,
      years: years,
    );
    return breakdown.isEmpty ? 0.0 : breakdown.last.corpus;
  }

  static List<StepUpYear> stepUpSipBreakdown({
    required double initialMonthlyInvestment,
    required double annualRate,
    required double annualStepUp,
    required int years,
  }) {
    if (!_validMoney(initialMonthlyInvestment) || !_validRate(annualRate) ||
        !_validFinite(annualStepUp) || annualStepUp < -100 ||
        annualStepUp > 1000 || years <= 0 || years * 12 > _maxMonths) {
      return const <StepUpYear>[];
    }

    final result = <StepUpYear>[];
    var corpus = 0.0;
    var monthly = initialMonthlyInvestment;
    var investedTotal = 0.0;
    final monthlyRate = _monthlySipRate(annualRate);

    for (var year = 1; year <= years; year++) {
      for (var month = 0; month < 12; month++) {
        // Contribution at the beginning of the month, then one month of growth.
        corpus = (corpus + monthly) * (1.0 + monthlyRate);
        investedTotal += monthly;
        if (!corpus.isFinite || !investedTotal.isFinite) return const <StepUpYear>[];
      }

      result.add(StepUpYear(
        year: year,
        monthlyInvestment: _roundMoney(monthly),
        invested: _roundMoney(investedTotal),
        corpus: _roundMoney(corpus),
      ));

      monthly *= 1.0 + annualStepUp / 100.0;
      if (!monthly.isFinite || monthly > _maxMoney) return const <StepUpYear>[];
    }

    return result;
  }

  /// Reverse-solves annual nominal reducing-balance rate from principal, EMI and
  /// remaining tenure. The solution is unique for non-negative rates.
  static double? interestRateFromEmi({
    required double principal,
    required double emi,
    required int tenureMonths,
  }) {
    if (!_validMoney(principal, allowZero: false) ||
        !_validMoney(emi, allowZero: false) ||
        !_validMonths(tenureMonths)) return null;

    final zeroRateEmi = principal / tenureMonths;
    final tolerance = math.max(0.005, zeroRateEmi * 1e-10);
    if (emi < zeroRateEmi - tolerance) return null;
    if ((emi - zeroRateEmi).abs() <= tolerance) return 0.0;

    double paymentAt(double annualRate) => FinanceCalculator.emi(
          principal: principal,
          annualRate: annualRate,
          tenureMonths: tenureMonths,
        ).emi;

    var low = 0.0;
    var high = 12.0;
    while (paymentAt(high) < emi && high < _maxRate) {
      high = math.min(_maxRate, high * 2.0);
    }
    if (paymentAt(high) < emi) return null;

    for (var i = 0; i < 100; i++) {
      final mid = (low + high) / 2.0;
      if (paymentAt(mid) < emi) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return (low + high) / 2.0;
  }

  static double mathPow(double base, int exponent) => math.pow(base, exponent).toDouble();
}
