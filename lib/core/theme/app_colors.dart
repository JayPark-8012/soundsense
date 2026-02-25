import 'package:flutter/material.dart';

/// 앱 전체 색상 정의
/// 색상 하드코딩 금지 — 반드시 AppColors 사용
abstract final class AppColors {
  // ─── 배경 ───
  static const background = Color(0xFF0F0F14);
  static const surface = Color(0xFF1A1A24);
  static const surfaceLight = Color(0xFF24243A);
  static const card = Color(0xFF1E1E2E);

  // ─── 텍스트 ───
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0C0);
  static const textTertiary = Color(0xFF6E6E80);

  // ─── 소음 레벨 5단계 (파랑 → 초록 → 노랑 → 주황 → 빨강) ───
  static const levelSilent = Color(0xFF4A90D9);   // ~30 dB  조용함
  static const levelQuiet = Color(0xFF34C759);     // ~50 dB  보통
  static const levelModerate = Color(0xFFFFCC00);  // ~70 dB  약간 시끄러움
  static const levelLoud = Color(0xFFFF9500);      // ~85 dB  시끄러움
  static const levelDanger = Color(0xFFFF3B30);    // 85+ dB  위험

  /// dB 값에 따른 레벨 색상 반환
  static Color levelColor(double db) {
    if (db <= 30) return levelSilent;
    if (db <= 50) return levelQuiet;
    if (db <= 70) return levelModerate;
    if (db <= 85) return levelLoud;
    return levelDanger;
  }

  // ─── 소음 레벨 배경 (투명도 8~12%) ───
  static Color levelBackground(double db) => levelColor(db).withValues(alpha: 0.10);

  // ─── PRO / 프리미엄 ───
  static const proGold = Color(0xFFFFD700);
  static const proGoldLight = Color(0xFFFFE566);
  static const proGradientStart = Color(0xFFFFD700);
  static const proGradientEnd = Color(0xFFFFAA00);

  // ─── 액센트 / 인터랙션 ───
  static const primary = Color(0xFF6C5CE7);
  static const primaryLight = Color(0xFF8B7CF7);
  static const accent = Color(0xFF00D2FF);

  // ─── 기능 색상 ───
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const error = Color(0xFFFF3B30);

  // ─── 구분선 / 보더 ───
  static const divider = Color(0xFF2A2A3A);
  static const border = Color(0xFF3A3A4A);
}
