import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDebugPremiumKey = 'debug_is_premium';
const _kEntitlementId = 'pro';

/// Debug용 PRO 상태 토글 — kDebugMode에서만 사용
/// SharedPreferences에 저장되어 앱 재시작 후에도 유지
final debugPremiumProvider = StateNotifierProvider<DebugPremiumNotifier, bool>(
  (ref) => DebugPremiumNotifier(),
);

class DebugPremiumNotifier extends StateNotifier<bool> {
  DebugPremiumNotifier() : super(false) {
    if (kDebugMode) _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kDebugPremiumKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDebugPremiumKey, state);
  }
}

/// RevenueCat 기반 PRO 상태 — CustomerInfo 리스너로 실시간 갱신
final premiumStatusProvider =
    StateNotifierProvider<PremiumStatusNotifier, bool>(
  (ref) => PremiumStatusNotifier(),
);

class PremiumStatusNotifier extends StateNotifier<bool> {
  PremiumStatusNotifier() : super(false) {
    _init();
  }

  late final void Function(CustomerInfo) _listener;

  Future<void> _init() async {
    try {
      final info = await Purchases.getCustomerInfo();
      state = info.entitlements.active.containsKey(_kEntitlementId);
    } catch (e) {
      debugPrint('PRO 상태 초기 확인 실패: $e');
    }

    // CustomerInfo 변경 감시 (구매/복원 시 자동 갱신)
    _listener = (CustomerInfo info) {
      state = info.entitlements.active.containsKey(_kEntitlementId);
    };
    Purchases.addCustomerInfoUpdateListener(_listener);
  }

  /// 수동 갱신 (구매/복원 후 호출)
  Future<void> refresh() async {
    try {
      final info = await Purchases.getCustomerInfo();
      state = info.entitlements.active.containsKey(_kEntitlementId);
    } catch (e) {
      debugPrint('PRO 상태 갱신 실패: $e');
    }
  }

  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_listener);
    super.dispose();
  }
}

/// PRO 상태 — 모든 PRO 기능은 이 Provider만 참조
/// kDebugMode: 디버그 토글 OR RevenueCat 실제 구매 / Production: RevenueCat 상태
final isPremiumProvider = Provider<bool>((ref) {
  if (kDebugMode) {
    return ref.watch(debugPremiumProvider) || ref.watch(premiumStatusProvider);
  }
  return ref.watch(premiumStatusProvider);
});
