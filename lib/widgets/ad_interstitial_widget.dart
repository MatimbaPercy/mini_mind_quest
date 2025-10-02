import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdInterstitialWidget extends StatefulWidget {
  const AdInterstitialWidget({super.key});

  @override
  State<AdInterstitialWidget> createState() => _AdInterstitialWidgetState();
}

class _AdInterstitialWidgetState extends State<AdInterstitialWidget> {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isShowingAd = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  /// Call this to show the ad
  Future<void> showAd() async {
    if (_interstitialAd != null && _isInterstitialAdReady) {
      _isShowingAd = true;

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _resetAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _resetAd();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
      setState(() {}); // refresh widget if needed
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // test ad unit
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _resetAd() {
    _isShowingAd = false;
    _loadInterstitialAd();
    setState(() {});
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Full screen cover while ad is showing
    if (_isShowingAd) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Loading your quest...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Otherwise, widget stays invisible
    return const SizedBox.shrink();
  }
}
