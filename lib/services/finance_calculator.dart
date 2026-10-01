import 'dart:math' as math;
import '../models/emi_result.dart';
import '../models/finance_models.dart';

class FinanceCalculator {
  static EmiResult emi({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) {
    final r = annualRate / 12 / 100;

    if (principal <= 0 || tenureMonths <= 0) {
      return const EmiResult(
        emi: 0,
        totalInterest: 0,
        totalPayment: 0,
        principal: 0,
      );
    }

    if (r == 0) {
      final payment = principal / tenureMonths;
      return EmiResult(
        emi: payment,
        totalInterest: 0,
        totalPayment: principal,
        principal: principal,
      );
    }

    final factor = math.pow(1.0 + r, tenureMonths).toDouble();
    final payment = principal * r * factor / (factor - 1.0);
    final total = payment * tenureMonths;

    return EmiResult(
      emi: payment,
      totalInterest: total - principal,
      totalPayment: total,
      principal: principal,
    );
  }

  static List<AmortizationRow> amortization({
    required double principal,
    required double annualRate,
    required int tenureMonths,
    double? fixedEmi,
  }) {
    final result = <AmortizationRow>[];
    final double calc = fixedEmi ??
        emi(
          principal: principal,
          annualRate: annualRate,
          tenureMonths: tenureMonths,
        ).emi;

    double balance = principal;
    final double monthlyRate = annualRate / 12.0 / 100.0;

    for (var month = 1; month <= tenureMonths && balance > 0.01; month++) {
      final interest = monthlyRate == 0.0 ? 0.0 : balance * monthlyRate;
      double principalPart = calc - interest;

      if (principalPart <= 0.0) break;
      if (principalPart > balance) principalPart = balance;

      final double actualEmi = principalPart + interest;
      balance -= principalPart;

      result.add(
        AmortizationRow(
          month: month,
          emi: actualEmi,
          principal: principalPart,
          interest: interest,
          balance: balance < 0.0 ? 0.0 : balance,
        ),
      );
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
    final safePrepayment = prepayment.clamp(0.0, outstanding).toDouble();
    final newBalance = outstanding - safePrepayment;

    final oldSchedule = amortization(
      principal: outstanding,
      annualRate: annualRate,
      tenureMonths: remainingMonths,
      fixedEmi: currentEmi,
    );
    final newSchedule = newBalance <= 0
        ? <AmortizationRow>[]
        : amortization(
            principal: newBalance,
            annualRate: annualRate,
            tenureMonths: remainingMonths,
            fixedEmi: currentEmi,
          );

    final oldInterest =
        oldSchedule.fold<double>(0.0, (sum, row) => sum + row.interest);
    final newInterest =
        newSchedule.fold<double>(0.0, (sum, row) => sum + row.interest);

    return PrepaymentResult(
      outstanding: outstanding,
      prepayment: safePrepayment,
      newBalance: newBalance,
      oldTotalInterest: oldInterest,
      newTotalInterest: newInterest,
      interestSaved: math.max(0.0, oldInterest - newInterest),
      oldMonths: oldSchedule.length,
      newMonths: newSchedule.length,
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
    final months = years * 12;
    final r = annualRate / 12 / 100;

    if (months <= 0) return 0.0;
    if (r == 0.0) return monthlyInvestment * months;

    return monthlyInvestment *
        ((math.pow(1.0 + r, months).toDouble() - 1.0) / r) *
        (1.0 + r);
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
    final result = <StepUpYear>[];
    double corpus = 0.0;
    double monthly = initialMonthlyInvestment;
    double investedTotal = 0.0;
    final double monthlyRate = annualRate / 12.0 / 100.0;

    for (int year = 1; year <= years; year++) {
      for (int month = 0; month < 12; month++) {
        corpus = corpus * (1.0 + monthlyRate) + monthly;
        investedTotal += monthly;
      }

      result.add(
        StepUpYear(
          year: year,
          monthlyInvestment: monthly,
          invested: investedTotal,
          corpus: corpus,
        ),
      );

      monthly *= 1.0 + annualStepUp / 100.0;
    }

    return result;
  }

  static double mathPow(double base, int exponent) {
    return math.pow(base, exponent).toDouble();
  }
}