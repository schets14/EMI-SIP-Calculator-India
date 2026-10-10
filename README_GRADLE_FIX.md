# Gradle / Flutter Android build fix

- Gradle Wrapper: 8.14
- Android Gradle Plugin: 8.13.0
- Kotlin Gradle Plugin: 2.2.20
- minSdk: 26 (Android 8.0)
- compileSdk/targetSdk: 36
- Java: 17
- `android.newDsl=false` and `android.builtInKotlin=false` retained for compatibility with the legacy `kotlin-android` setup.

Android 17 is API 37. The app remains installable/runnable on Android 17 because minSdk is 26; targetSdk 36 is intentional for a stable AGP 8.x production toolchain. Targeting API 37 requires AGP 9.1.1+ and Gradle 9.3.1+ plus the newer Kotlin/DSL migration path.

Run:

```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```
