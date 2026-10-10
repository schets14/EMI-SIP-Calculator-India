# EMI SIP Calculator India - Phase 7 Retention Dashboard

Phase 7 builds on the previous decision/planning features and adds a personalized home dashboard designed around repeat usage.

## Added
- Personalized "Your money snapshot" on Home
- Monthly surplus, debt-to-income and emergency-fund coverage snapshot
- Saved-plan count shortcut
- Upcoming reminder shortcut
- Last-calculation continuation surface
- Indian compact currency formatting (K / L / Cr)
- Home refreshes dashboard data when returning from screens

## Why
Current Indian finance apps are increasingly combining calculators with saved plans, loan tracking, reminders, goals, financial-health dashboards, offline/privacy positioning, and shareable results. The phase focuses on bringing those retention patterns into this app without adding bank-account access or unnecessary backend complexity.

## Run
```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```

## Notes
- Financial health values remain locally stored through SharedPreferences.
- The dashboard is a planning aid, not financial advice.
- Notification scheduling still requires a production notification plugin/configuration if true OS-level scheduled notifications are desired.
