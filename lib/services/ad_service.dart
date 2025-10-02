import 'package:flutter/material.dart';

class AdService {
  void showRewardedAd(Function onReward) {
    print('Showing rewarded ad...');
    onReward(); // Simulate reward
  }

  Widget buildBannerAd() {
    return Container(
      height: 50,
      color: Colors.blueGrey,
      child: Center(child: Text('Banner Ad Placeholder')),
    );
  }

  void showInterstitialAd() {
    print('Showing interstitial ad...');
  }
}
