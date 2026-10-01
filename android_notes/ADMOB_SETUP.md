# AdMob setup and placement

The project uses Google's test ad IDs during development. Replace them with your own production IDs before release.

## Current placement strategy

1. **Inline adaptive banner** on the home screen after the Plan & Decide card.
2. **Inline adaptive banner** on calculator result flows, after the primary result and before secondary details.
3. **Inline adaptive banner** on the amortization screen between the summary and long table.
4. **Interstitial** only after a PDF/report export request, not during data entry or immediately after opening a calculator.
5. The first two report exports are ad-free. After that, an interstitial is eligible no more than once every 5 minutes.

This follows Google's guidance to place interstitials at natural transition points and avoid flooding users with ads. Banner ads use anchored adaptive sizing. During development, use Google's test IDs to avoid invalid activity.

Official docs:
- https://developers.google.com/admob/flutter/banner
- https://developers.google.com/admob/android/interstitial
- https://developers.google.com/admob/flutter/test-ads
