# Final Android toolchain

- AGP: 9.1.1
- Gradle: 9.3.1
- Kotlin Gradle Plugin: 2.2.20 (explicitly pinned to satisfy Flutter 3.47+ validation)
- Built-in Kotlin: enabled
- JDK: 17
- compileSdk/targetSdk: 37
- minSdk: 26

Do not use `--android-skip-build-dependency-validation`.

Run:

```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```
