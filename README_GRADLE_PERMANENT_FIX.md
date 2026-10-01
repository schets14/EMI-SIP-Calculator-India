# Permanent Android Gradle / Kotlin fix

Updated for Flutter 3.47+ built-in Kotlin and Android 17:
- AGP 9.1.1
- Gradle 9.3.1
- compileSdk 37 / targetSdk 37
- minSdk 26 (Android 8.0+)
- built-in Kotlin enabled
- legacy kotlin-android plugin removed
- legacy kotlinOptions removed
- old android.newDsl / android.builtInKotlin=false flags removed

Based on current Flutter migration guidance and Android AGP 9.1 compatibility.
