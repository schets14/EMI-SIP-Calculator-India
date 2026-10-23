# Calculation Engine V35

## What changed

V35 hardens the financial calculation layer with deterministic rupee/paise handling.

### Monetary precision
- All user-facing monetary outputs are rounded to 2 decimal places.
- EMI amortization rounds interest, principal and installment amounts to paise per month.
- Final loan installment reconciles the exact remaining principal and closes at ₹0.00.
- EMI summary totals are calculated from the same amortization model, so the summary and schedule reconcile.
- GST, SIP, Step-up SIP, FD, RD, PPF, Goal SIP and SWP outputs use the same 2-decimal monetary boundary.

### Safety limits
- Monetary inputs are capped below the IEEE-754 exact-integer boundary after conversion to paise.
- Existing finite/rate/tenure validation remains in place.
- Pathological values return safe invalid/empty results rather than NaN/Infinity.

### Testing
Added tests for:
- EMI/schedule paise reconciliation
- Zero-rate loan paise reconciliation
- GST paise rounding
- Existing formula, edge-case and pathological-input coverage

## Verification limitation
The current build environment does not contain the Flutter/Dart SDK, so `flutter test`, `flutter analyze`, and `flutter build appbundle` could not be executed here. Source-level structural checks and test updates were completed.

Run locally:

```bash
flutter clean
flutter pub get
flutter format lib test
flutter analyze
flutter test
```

Then build the release bundle using the app's normal production build command.
