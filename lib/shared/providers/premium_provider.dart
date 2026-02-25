import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PRO 구독 상태 — 모든 PRO 기능은 이 Provider만 참조
/// Phase 9 RevenueCat 연동 시 실제 구독 상태로 교체
final isPremiumProvider = Provider<bool>((ref) {
  // TODO: RevenueCat 구독 상태 확인으로 교체
  return false;
});
