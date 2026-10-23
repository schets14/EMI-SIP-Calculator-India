# Android support

This project is configured for Android 8.0 through Android 17:

- minSdk = 26 (Android 8.0 Oreo)
- compileSdk = 37 (Android 17)
- targetSdk = 37 (Android 17)
- Java/Kotlin JVM target = 17
- Android Gradle Plugin = 8.9.2
- Gradle = 8.11.1

Google Play currently requires new apps and updates to target Android 16 (API 36) or higher from 31 Aug 2026. This project targets Android 17 (API 37) while retaining Android 8.0 compatibility through minSdk 26.

Before production release, replace the Google test AdMob application ID in AndroidManifest.xml with the production App ID from AdMob.

Flutter will populate android/local.properties on a developer machine after running Flutter tooling. Run `flutter clean && flutter pub get` before building.
