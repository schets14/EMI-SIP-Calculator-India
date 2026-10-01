import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const bannerAndroidId = 'ca-app-pub-8841998984547985/7850940908';

  static InterstitialAd? _interstitial;
  static int _exportCount = 0;
  static DateTime? _lastInterstitialAt;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadInterstitial();
  }

  static void loadInterstitial() {
    if (_interstitial != null) return;
    if (kReleaseMode) return;

    InterstitialAd.load(
      adUnitId: testInterstitialAndroid,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: $error');
          _interstitial = null;
        },
      ),
    );
  }

  /// Shows an interstitial only after a completed PDF/report request.
  /// First two exports are friction-free. Afterwards, an ad is eligible
  /// at most once every 5 minutes. This keeps the ad at a natural transition
  /// instead of interrupting calculation or data entry.
  static Future<bool> showAfterReportRequest() async {
    _exportCount++;
    final now = DateTime.now();
    final cooldownActive = _lastInterstitialAt != null &&
        now.difference(_lastInterstitialAt!) < const Duration(minutes: 5);

    if (_exportCount < 3 || cooldownActive || _interstitial == null) {
      if (_interstitial == null) loadInterstitial();
      return false;
    }

    final ad = _interstitial!;
    _interstitial = null;
    _lastInterstitialAt = now;

    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial show failed: $error');
        ad.dispose();
        loadInterstitial();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show();
    return completer.future;
  }
}
