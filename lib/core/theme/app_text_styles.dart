import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';

/// 앱 전체 텍스트 스타일 정의
/// 숫자 매직 넘버 금지 — 반드시 AppTextStyles 사용
abstract final class AppTextStyles {
  // ─── dB 숫자 (측정 화면 메인 디스플레이) ───
  static const dbDisplay = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -2.0,
  );

  // ─── 레벨 텍스트 (조용함, 보통, 시끄러움 등) ───
  static const levelLabel = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ─── 카드 제목 (세션 카드, 설정 항목 등) ───
  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ─── 본문 (일반 텍스트) ───
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ─── 캡션 (날짜, 보조 텍스트) ───
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );
}
