import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  /// Build-time master switch. Keep this false for closed/internal testing
  /// and true for the production build. Users cannot disable ads in-app.
  static const bool buildAdsEnabled = bool.fromEnvironment(
    'ADS_ENABLED',
    defaultValue: false,
  );

  // Production Android ad unit IDs.
  static const interstitialAndroidId = 'ca-app-pub-8841998984547985/1166855310';
  static const bannerAndroidId = 'ca-app-pub-8841998984547985/7850940908';

  static InterstitialAd? _interstitial;
  static int _transitionCount = 0;
  static DateTime? _lastInterstitialAt;
  static bool _showing = false;
  static bool _initialized = false;

  static bool get canShowAds => buildAdsEnabled;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!buildAdsEnabled) return;
    await MobileAds.instance.initialize();
    loadInterstitial();
  }


  static void loadInterstitial() {
    if (!canShowAds || _interstitial != null) return;

    InterstitialAd.load(
      adUnitId: interstitialAndroidId,
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

  static Future<void> popWithInterstitial(BuildContext context, {required bool eligible}) async {
    Navigator.of(context).pop();
    if (eligible && canShowAds) {
      await Future<void>.delayed(Duration.zero);
      await showAfterMajorCalculation();
    }
  }

  @Deprecated('Use showAfterMajorCalculation instead.')
  static Future<bool> showAfterReportRequest() => showAfterMajorCalculation();

  static Future<bool> showAfterMajorCalculation() async {
    if (!canShowAds || _showing) return false;

    _transitionCount++;
    final now = DateTime.now();
    final cooldownActive = _lastInterstitialAt != null &&
        now.difference(_lastInterstitialAt!) < const Duration(minutes: 5);

    if (_transitionCount <= 2 || cooldownActive || _interstitial == null) {
      if (_interstitial == null) loadInterstitial();
      return false;
    }

    final ad = _interstitial!;
    _interstitial = null;
    _lastInterstitialAt = now;
    _showing = true;

    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showing = false;
        loadInterstitial();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial show failed: $error');
        ad.dispose();
        _showing = false;
        loadInterstitial();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show();
    return completer.future;
  }

}
