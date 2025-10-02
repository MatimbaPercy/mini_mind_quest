import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdBarWidget extends StatefulWidget {
  const AdBarWidget({super.key});

  @override
  State<AdBarWidget> createState() => _AdBarWidgetState();
}

class _AdBarWidgetState extends State<AdBarWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      //adUnitId:'ca-app-pub-7221384431047120/8337738449', // Replace with your real Ad Unit ID
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', //Test Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).cardColor,
      child: SizedBox(
        height: 80, // Increased height to fit ad + content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
