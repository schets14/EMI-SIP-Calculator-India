import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// A lightweight inline adaptive banner used only at result/decision points.
/// It collapses completely when an ad is unavailable, so it never leaves a gap.
class FinanceBannerAd extends StatefulWidget {
  const FinanceBannerAd({super.key});

  @override
  State<FinanceBannerAd> createState() => _FinanceBannerAdState();
}

class _FinanceBannerAdState extends State<FinanceBannerAd> {
  BannerAd? _banner;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_banner == null && _loading) {
      _load();
    }
  }

  Future<void> _load() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final ad = BannerAd(
      adUnitId: AdService.bannerAndroidId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _banner = ad as BannerAd;
            _loading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _loading = false);
        },
      ),
    );

    await ad.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (banner == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Advertisement',
            style: TextStyle(fontSize: 9, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ],
      ),
    );
  }
}
