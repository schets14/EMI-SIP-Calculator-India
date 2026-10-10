# Calculation Standard — EMI SIP Calculator India

Finance calculations are safety-critical product functionality. The app keeps formulas in the service layer and tests them independently from the UI.

## Loan EMI

- Reducing-balance EMI.
- Monthly rate = annual nominal rate / 12 / 100.
- Formula calculations retain full floating-point precision internally.
- Monetary outputs use deterministic paise precision (2 decimal places).
- Loan schedules round interest, principal and instalment amounts to paise on every row.
- The final instalment reconciles the remaining principal exactly, so the schedule closes at ₹0.00.
- EMI headline totals are derived from the same paise-rounded schedule, so the EMI summary and amortization table reconcile exactly.
- EMI below the monthly interest cannot amortize the loan and is treated as invalid for schedule-based calculations.

## Monetary precision and rounding

- User-facing monetary values are represented to the nearest ₹0.01.
- Calculations are not prematurely rounded before formula evaluation.
- Schedule-level rounding is applied at each payment period, matching the way a customer-facing loan schedule is normally represented.
- The calculation engine caps supported monetary inputs below the IEEE-754 exact-integer boundary after conversion to paise.
- Rate solving uses the rounded EMI entered by the user, so the recovered rate is an estimate within a documented tolerance rather than an exact recovery of an unrounded internal rate.

## Reverse Interest Rate

- Solves the same reducing-balance EMI equation used by the EMI calculator.
- Uses bounded binary search rather than a hard-coded approximation.
- The search range expands up to 1000% p.a. before declaring the input unsolvable.
- Fees, insurance, taxes, overdue charges, daily-interest methods and irregular payment dates are not included, so this is a loan-rate estimate rather than an APR/EIR calculation.

## SIP

- Monthly contribution is assumed at the beginning of each month.
- Monthly planning rate = annual assumed return / 12.
- This is the conventional SIP formula used by many Indian calculators. Calculator providers can differ in whether they treat the annual return as a nominal rate or an effective annual rate, so two otherwise correct calculators can produce different projections.
- Returns are estimates and are not guaranteed.

## Step-up SIP

- Monthly contribution is increased once per year by the configured percentage.
- Each monthly contribution is modeled at the beginning of its month.
- The corpus is calculated month by month, avoiding a fragile closed-form approximation.

## Goal SIP

- Uses the inverse of the app's beginning-of-month SIP formula.
- Existing savings are compounded for the full period before calculating the remaining SIP requirement.

## FD

- Quarterly compounding by default.
- Whole-year tenure in the current UI.

## RD

- Monthly deposits.
- Uses the standard Indian RD calculator approximation: `M = P*n + P*n(n+1)/2 * r/400`, where `r` is annual rate in percent and `n` is the number of monthly instalments.

## PPF

- The current calculator is an illustration assuming the entered annual contribution is made at the beginning of each financial year and the entered annual rate remains constant.
- Real PPF interest is based on account rules and the lowest balance during the relevant period; contribution timing matters.

## GST

- Add GST: GST = base × rate / 100; final = base + GST.
- Remove GST from an inclusive amount: GST = inclusive × rate / (100 + rate); base = inclusive − GST.

## Validation and release rule

Any change to a calculation formula must update the corresponding automated tests and the calculation-standard documentation. The UI must not contain a second copy of the formula.
