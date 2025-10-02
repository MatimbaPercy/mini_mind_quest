import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static final AdHelper _instance = AdHelper._internal();
  factory AdHelper() => _instance;
  AdHelper._internal();

  InterstitialAd? _interstitialAd;

  /// Initialize Google Mobile Ads (call once in main)
  void initialize() {
    //MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-3940256099942544/1033173712', // replace with your ad unit
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad:
            (error) => print('Failed to load interstitial: $error'),
      ),
    );
  }

  /// Show an interstitial ad, automatically reloads the next ad
  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  /// Dispose the ad manually (if needed)
  void dispose() {
    _interstitialAd?.dispose();
  }
}
