import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';

/// 소음 레벨 5단계 정의
/// dB 범위, 색상, 텍스트를 한곳에서 관리
enum DbLevel {
  silent(
    minDb: 0,
    maxDb: 30,
    color: AppColors.levelSilent,
    labelEn: 'Silent',
    labelKo: '조용함',
  ),
  quiet(
    minDb: 31,
    maxDb: 50,
    color: AppColors.levelQuiet,
    labelEn: 'Quiet',
    labelKo: '보통',
  ),
  moderate(
    minDb: 51,
    maxDb: 70,
    color: AppColors.levelModerate,
    labelEn: 'Moderate',
    labelKo: '약간 시끄러움',
  ),
  loud(
    minDb: 71,
    maxDb: 85,
    color: AppColors.levelLoud,
    labelEn: 'Loud',
    labelKo: '시끄러움',
  ),
  danger(
    minDb: 86,
    maxDb: 130,
    color: AppColors.levelDanger,
    labelEn: 'Danger',
    labelKo: '위험',
  );

  const DbLevel({
    required this.minDb,
    required this.maxDb,
    required this.color,
    required this.labelEn,
    required this.labelKo,
  });

  final int minDb;
  final int maxDb;
  final Color color;
  final String labelEn;
  final String labelKo;

  /// dB 값으로 레벨 판별
  static DbLevel fromDb(double db) {
    if (db <= 30) return silent;
    if (db <= 50) return quiet;
    if (db <= 70) return moderate;
    if (db <= 85) return loud;
    return danger;
  }
}
