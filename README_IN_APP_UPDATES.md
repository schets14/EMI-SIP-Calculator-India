# Google Play In-App Updates

This project now checks Google Play for app updates after startup for existing users.

## Behaviour

- Android only.
- Normal startup check is throttled to once every 12 hours.
- Uses Google Play In-App Updates, not a custom APK downloader.
- Flexible update is preferred so users can continue using the calculator while the update downloads.
- When Play reports the download is complete, the update is completed automatically.
- If Play only permits an immediate update, the native immediate flow is used.
- Debug/sideloaded builds fail closed and do not show a fake update popup.

## Production testing

Google Play In-App Updates must be tested from a Google Play-installed build, such as an internal testing track. A local debug/sideloaded APK is not sufficient.

## Important

Upload a higher `versionCode` to Play Console. Google Play decides whether an update is available and whether the chosen update flow is allowed.
