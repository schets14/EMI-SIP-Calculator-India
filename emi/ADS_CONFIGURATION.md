# Ads configuration

Ads are controlled only at build time. There is no user-facing ads-disable setting.

## AdMob IDs

- App ID: `ca-app-pub-8841998984547985~1611912172`
- Interstitial: `ca-app-pub-8841998984547985/1166855310`
- Banner: `ca-app-pub-8841998984547985/7850940908`

The Android manifest uses the App ID above, and the Flutter ad service uses the banner/interstitial unit IDs above.

## Closed/Internal testing

Build with ads disabled:

```bash
flutter build appbundle --release --dart-define=ADS_ENABLED=false
```

No banner or interstitial requests are made in this build.

## Production

Build with ads enabled:

```bash
flutter build appbundle --release --dart-define=ADS_ENABLED=true
```

When enabled, the app uses the production AdMob IDs above.

Google recommends using dedicated test ad units while developing/testing and replacing them with your own ad units before publishing.
