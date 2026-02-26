import 'package:flutter/services.dart';

/// 햅틱 피드백 유틸리티
/// PLANNING.md 디자인 원칙: "햅틱 피드백 (버튼, 경고)"
abstract final class HapticUtils {
  /// 가벼운 탭 — 일반 버튼, 카드 탭
  static void light() => HapticFeedback.lightImpact();

  /// 중간 — 중요 액션 (Start/Stop, Free Trial)
  static void medium() => HapticFeedback.mediumImpact();

  /// 강한 — 경고, 위험 레벨 진입
  static void heavy() => HapticFeedback.heavyImpact();

  /// 성공 — 저장 완료, 온보딩 완료
  static void success() => HapticFeedback.mediumImpact();

  /// 경고 — 85dB 초과
  static void warning() => HapticFeedback.heavyImpact();

  /// 선택 변경 — 토글, 필터 전환
  static void selection() => HapticFeedback.selectionClick();
}
