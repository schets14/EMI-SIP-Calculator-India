import 'package:flutter_test/flutter_test.dart';
import 'package:fincalc_india/models/finance_models.dart';
import 'package:fincalc_india/services/finance_calculator.dart';
import 'package:fincalc_india/services/finance_extra.dart';
import 'package:fincalc_india/models/emi_result.dart';

void main() {
  group('Loan calculations', () {
    test('EMI matches standard reducing-balance formula', () {
      final r = FinanceCalculator.emi(principal: 1000000, annualRate: 9.5, tenureMonths: 60);
      expect(r.emi, 21001.86);
      expect(r.totalInterest, closeTo(260111.72, 1e-9));
      expect(r.totalPayment, closeTo(1260111.72, 1e-9));
    });

    test('zero-rate EMI is principal divided by months', () {
      final r = FinanceCalculator.emi(principal: 120000, annualRate: 0, tenureMonths: 12);
      expect(r.emi, 10000);
      expect(r.totalInterest, 0);
    });

    test('amortization closes balance and sums to total payment', () {
      final summary = FinanceCalculator.emi(principal: 1000000, annualRate: 9.5, tenureMonths: 60);
      final rows = FinanceCalculator.amortization(principal: 1000000, annualRate: 9.5, tenureMonths: 60);
      expect(rows.length, 60);
      expect(rows.last.balance, 0);
      expect(rows.fold<double>(0, (s, r) => s + r.principal), closeTo(1000000, 1e-6));
      expect(rows.fold<double>(0, (s, r) => s + r.interest), closeTo(summary.totalInterest, 1e-9));
      expect(rows.fold<double>(0, (s, r) => s + r.emi), closeTo(summary.totalPayment, 1e-9));
    });


    test('EMI remains stable at an extremely small positive rate', () {
      final r = FinanceCalculator.emi(principal: 1000000, annualRate: 0.000001, tenureMonths: 360);
      expect(r.emi, closeTo(1000000 / 360, 1e-3));
      expect(r.emi.isFinite, isTrue);
    });

    test('EMI remains finite for high-rate long-tenure inputs', () {
      final r = FinanceCalculator.emi(principal: 100000, annualRate: 1000, tenureMonths: 1200);
      expect(r.emi.isFinite, isTrue);
      expect(r.totalPayment.isFinite, isTrue);
      expect(r.totalInterest, greaterThan(0));
    });

    test('amortization rejects a non-amortizing fixed EMI instead of returning a partial schedule', () {
      final rows = FinanceCalculator.amortization(
        principal: 100000,
        annualRate: 12,
        tenureMonths: 12,
        fixedEmi: 500,
      );
      expect(rows, isEmpty);
    });

    test('invalid pathological inputs fail safely', () {
      expect(FinanceCalculator.emi(principal: double.infinity, annualRate: 10, tenureMonths: 120),
          equals(const EmiResult(emi: 0, totalInterest: 0, totalPayment: 0, principal: 0)));
      expect(FinanceCalculator.emi(principal: 100000, annualRate: -1, tenureMonths: 120).emi, 0);
      expect(FinanceCalculator.emi(principal: 100000, annualRate: 10, tenureMonths: 0).emi, 0);
    });

    test('fixed EMI schedule adjusts final instalment instead of overpaying', () {
      final rows = FinanceCalculator.amortization(principal: 100000, annualRate: 12, tenureMonths: 12, fixedEmi: 9000);
      expect(rows.last.balance, 0);
      expect(rows.length, 12);
      expect(rows.last.emi, lessThan(9000));
    });

    test('reverse interest rate round-trips', () {
      final source = FinanceCalculator.emi(principal: 800000, annualRate: 9.5, tenureMonths: 48);
      final rate = FinanceCalculator.interestRateFromEmi(principal: 800000, emi: source.emi, tenureMonths: 48);
      expect(rate, isNotNull);
      expect(rate!, closeTo(9.5, 2e-5));
    });
  });


  group('Paise precision and reconciliation', () {
    test('EMI and amortization totals reconcile to the paise', () {
      final summary = FinanceCalculator.emi(
        principal: 1000000,
        annualRate: 9.5,
        tenureMonths: 60,
      );
      final rows = FinanceCalculator.amortization(
        principal: 1000000,
        annualRate: 9.5,
        tenureMonths: 60,
      );
      expect(summary.emi, 21001.86);
      expect(rows.last.balance, 0);
      expect(rows.every((row) => (row.emi * 100).roundToDouble() == row.emi * 100), isTrue);
      expect(rows.every((row) => (row.interest * 100).roundToDouble() == row.interest * 100), isTrue);
      expect(rows.every((row) => (row.principal * 100).roundToDouble() == row.principal * 100), isTrue);
      expect(rows.fold<double>(0, (s, r) => s + r.principal), 1000000.0);
      expect(rows.fold<double>(0, (s, r) => s + r.emi), summary.totalPayment);
      expect(rows.fold<double>(0, (s, r) => s + r.interest), summary.totalInterest);
    });

    test('zero-rate EMI reconciles despite paise rounding of installments', () {
      final summary = FinanceCalculator.emi(principal: 100000, annualRate: 0, tenureMonths: 12);
      final rows = FinanceCalculator.amortization(principal: 100000, annualRate: 0, tenureMonths: 12);
      expect(summary.emi, 8333.33);
      expect(rows.last.balance, 0);
      expect(rows.fold<double>(0, (s, r) => s + r.principal), 100000.0);
      expect(rows.fold<double>(0, (s, r) => s + r.emi), 100000.0);
      expect(summary.totalInterest, 0);
      expect(summary.totalPayment, 100000.0);
    });

    test('GST outputs are rounded to paise', () {
      final result = FinanceCalculator.gst(amount: 1234.567, rate: 18, addTax: true);
      expect(result.baseAmount, 1234.57);
      expect(result.gstAmount, 222.22);
      expect(result.totalAmount, 1456.79);
    });
  });

  group('Investment calculations', () {
    test('SIP uses beginning-of-month conventional formula', () {
      final fv = FinanceCalculator.sipFutureValue(monthlyInvestment: 10000, annualRate: 12, years: 10);
      expect(fv, 2323390.76);
    });

    test('step-up SIP matches month-by-month calculation', () {
      final data = FinanceCalculator.stepUpSipBreakdown(initialMonthlyInvestment: 10000, annualRate: 12, annualStepUp: 10, years: 15);
      expect(data.last.corpus, 8597870.72);
      expect(data.last.invested, 3812697.80);
    });

    test('goal SIP is inverse of the main SIP formula', () {
      const goal = 5000000.0;
      const rate = 12.0;
      const years = 10;
      final sip = FinanceExtra.goalSip(goal: goal, currentSavings: 0, annualRate: rate, years: years);
      final corpus = FinanceCalculator.sipFutureValue(monthlyInvestment: sip, annualRate: rate, years: years);
      expect(corpus, closeTo(goal, 0.5));
    });

    test('PPF yearly-deposit convention is internally consistent', () {
      final corpus = FinanceExtra.ppfMaturity(yearlyDeposit: 150000, annualRate: 7.1, years: 15);
      expect(corpus, 4068209.22);
    });

    test('RD uses monthly deposits rather than quarter count', () {
      final maturity = FinanceExtra.rdMaturity(monthlyDeposit: 5000, annualRate: 6.5, months: 60);
      expect(maturity, 448687.50);
      expect(maturity, greaterThan(300000));
    });
  });


  group('Edge-case investment calculations', () {
    test('zero-rate SIP is exactly principal contributions', () {
      expect(FinanceCalculator.sipFutureValue(monthlyInvestment: 10000, annualRate: 0, years: 10), 1200000);
    });

    test('step-up breakdown preserves invested amount', () {
      final rows = FinanceCalculator.stepUpSipBreakdown(
        initialMonthlyInvestment: 10000, annualRate: 12, annualStepUp: 10, years: 2,
      );
      expect(rows.last.invested, closeTo(12 * 10000 + 12 * 11000, 1e-6));
      expect(rows.last.corpus.isFinite, isTrue);
    });

    test('goal SIP returns zero when existing savings already meet the future goal', () {
      expect(FinanceExtra.goalSip(goal: 100000, currentSavings: 200000, annualRate: 12, years: 10), 0);
    });

    test('FD zero-rate returns principal', () {
      expect(FinanceExtra.fdMaturity(principal: 100000, annualRate: 0, years: 5), 100000);
    });

    test('RD zero-rate returns total deposits', () {
      expect(FinanceExtra.rdMaturity(monthlyDeposit: 5000, annualRate: 0, months: 60), 300000);
    });
  });

  test('GST add and remove are exact inverses for the same rate', () {
    final added = FinanceCalculator.gst(amount: 1000, rate: 18, addTax: true);
    final removed = FinanceCalculator.gst(amount: added.totalAmount, rate: 18, addTax: false);
    expect(added.gstAmount, 180);
    expect(added.totalAmount, 1180);
    expect(removed.baseAmount, closeTo(1000, 1e-10));
    expect(removed.gstAmount, closeTo(180, 1e-10));
  });

  test('SWP balance follows the documented timing convention', () {
    final balance = FinanceCalculator.swpEndingBalance(corpus: 100000, annualRate: 0, monthlyWithdrawal: 5000, years: 1);
    expect(balance, 40000);
  });

  test('prepayment rejects an EMI that cannot amortize the loan', () {
    final result = FinanceCalculator.prepayment(outstanding: 100000, annualRate: 12, remainingMonths: 12, currentEmi: 500, prepayment: 10000);
    expect(result.valid, isFalse);
    expect(result.error, isNotNull);
  });

  test('prepayment model remains constructible', () {
    const result = PrepaymentResult(outstanding: 100, prepayment: 10, newBalance: 90, oldTotalInterest: 10, newTotalInterest: 8, interestSaved: 2, oldMonths: 12, newMonths: 10, newEmi: 9, valid: true);
    expect(result.interestSaved, 2);
  });
}
