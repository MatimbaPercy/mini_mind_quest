import 'package:flutter/material.dart';
import 'package:mini_mind_quest/services/ad_service.dart';

class AdProvider extends ChangeNotifier {
  final AdService _adService = AdService();

  void showRewarded(Function onReward) => _adService.showRewardedAd(onReward);

  void showInterstitial() => _adService.showInterstitialAd();

  Widget bannerAd() => _adService.buildBannerAd();
}
