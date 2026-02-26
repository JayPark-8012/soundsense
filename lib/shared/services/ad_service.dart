import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSaveCountKey = 'save_count';

/// AdMob 광고 서비스 — 전면(Interstitial) + 리워드(Rewarded)
class AdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  // ─── 테스트 광고 ID ───
  String get _interstitialAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';

  String get _rewardedAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';

  // ═══════════════════════════════════════════
  // 전면 광고 (Interstitial)
  // ═══════════════════════════════════════════

  /// 전면 광고 프리로드
  void loadInterstitialAd() {
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('전면 광고 로드 완료');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          debugPrint('전면 광고 로드 실패: $error');
        },
      ),
    );
  }

  /// 저장 횟수 증가 + 광고 표시 여부 확인
  /// 규칙: saveCount > 1 && saveCount % 3 == 0
  Future<bool> incrementSaveAndCheckAd() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_kSaveCountKey) ?? 0) + 1;
    await prefs.setInt(_kSaveCountKey, count);
    debugPrint('저장 횟수: $count');
    return count > 1 && count % 3 == 0;
  }

  /// 전면 광고 표시 (로드되어 있으면)
  Future<void> showInterstitialAd() async {
    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitialAd();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // 다음 광고 프리로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        debugPrint('전면 광고 표시 실패: $error');
      },
    );

    _interstitialAd = null;
    await ad.show();
  }

  // ═══════════════════════════════════════════
  // 리워드 광고 (Rewarded)
  // ═══════════════════════════════════════════

  /// 리워드 광고 프리로드
  void loadRewardedAd() {
    if (_rewardedAd != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          debugPrint('리워드 광고 로드 완료');
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          debugPrint('리워드 광고 로드 실패: $error');
        },
      ),
    );
  }

  /// 리워드 광고 표시 — 리워드 획득 시 [onRewarded] 콜백 호출
  /// 광고 미로드 시 false 반환
  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    final ad = _rewardedAd;
    if (ad == null) {
      loadRewardedAd();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // 다음 광고 프리로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        debugPrint('리워드 광고 표시 실패: $error');
      },
    );

    _rewardedAd = null;
    await ad.show(onUserEarnedReward: (_, _) => onRewarded());
    return true;
  }

  /// 광고 리소스 해제
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

/// AdService Provider — 앱 전역 싱글톤
final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  // 앱 시작 시 광고 프리로드
  service.loadInterstitialAd();
  service.loadRewardedAd();
  ref.onDispose(() => service.dispose());
  return service;
});
