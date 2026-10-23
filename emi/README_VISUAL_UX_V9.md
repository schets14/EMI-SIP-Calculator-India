# Visual UX v9

## What changed
- Added reusable animated finance charts using the existing `fl_chart` dependency.
- SIP Calculator now shows a live, input-driven growth line chart and an invested-vs-returns donut chart.
- EMI Calculator now shows an animated principal-vs-interest donut and no longer shows a fake zero-value chart before inputs are entered.
- Step-up SIP chart now animates the actual year-wise corpus and shows an input prompt when there is no valid data.
- Loan Prepayment now shows an animated before-vs-after interest comparison bar chart.
- Home primary calculator cards use a subtle staggered entrance animation.
- All visualizations are driven only by user-entered/calculated data. No demo financial numbers were added.
- Empty states explicitly ask the user to enter inputs rather than displaying fake ₹0 results.

## Design rules
- Motion is short and purposeful: mostly 600–900ms ease-out transitions.
- Charts appear only when the underlying calculation has valid user input.
- Light and dark themes inherit the app theme; chart surfaces remain readable in both modes.
- Existing calculation formulas were not changed by the visual work.

## Research basis
Flutter's official animation guidance recommends implicit animations for simple state transitions and explicit animation APIs for more complex motion. The implementation uses `TweenAnimationBuilder` for result/chart reveal and keeps the motion bounded rather than continuously animating the UI.
