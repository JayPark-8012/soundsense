import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDebugPremiumKey = 'debug_is_premium';

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

/// PRO 구독 상태 — 모든 PRO 기능은 이 Provider만 참조
/// Phase 9 RevenueCat 연동 시 실제 구독 상태로 교체
final isPremiumProvider = Provider<bool>((ref) {
  if (kDebugMode) {
    return ref.watch(debugPremiumProvider);
  }
  // TODO: RevenueCat 구독 상태 확인으로 교체
  return false;
});
