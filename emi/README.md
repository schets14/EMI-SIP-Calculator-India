# EMI SIP Calculator India - Phase 7

Phase 7 builds on Phase 6 and focuses on repeat usage and retention instead of adding a large number of generic calculators.

## Added
- My Plans: local saved-plan library, with import from recent calculation history.
- Universal Search: search calculators, planning tools, saved plans, reminders and financial health.
- Reminders: local in-app finance reminders for EMI, SIP, reviews and goals.
- SIP -> SWP Planner: accumulation corpus followed by withdrawal scenario.
- Financial Health: private monthly snapshot with surplus, investment rate, debt/income and emergency-fund coverage.
- Home shortcuts for Search, My Plans and Reminders.
- Direct shortcuts for Financial Health and SIP -> SWP.
- Settings links for all new planning features.

## Privacy
Planning data is stored locally with SharedPreferences. No bank connection or account is required.

## Important reminder limitation
The Reminders screen currently stores and displays reminders locally inside the app. It does not schedule Android push notifications yet. Push notification scheduling should be added in the production Android project after the notification permission/channel configuration is finalized.

## Run
```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```
