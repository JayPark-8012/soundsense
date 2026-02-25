import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// 소음 레벨 뱃지 위젯
/// 레벨 텍스트 + 레벨 색상 배경, 레벨 변화 시 크로스페이드
class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.level,
    this.locale = 'en',
  });

  final DbLevel level;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = locale == 'ko' ? level.labelKo : level.labelEn;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        // key로 레벨 구분 → 레벨 바뀔 때만 크로스페이드 트리거
        key: ValueKey(level),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: level.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: level.color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.levelLabel.copyWith(color: level.color),
        ),
      ),
    );
  }
}
