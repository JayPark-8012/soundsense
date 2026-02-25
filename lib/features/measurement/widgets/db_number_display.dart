import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

/// dB 숫자 디스플레이 위젯
/// 72sp Bold 숫자 + "dB" 단위, 값 변화 시 부드러운 애니메이션
class DbNumberDisplay extends StatelessWidget {
  const DbNumberDisplay({
    super.key,
    required this.db,
    this.color,
  });

  final double db;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // dB 숫자 — 카운트 애니메이션
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: db),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.dbDisplay.copyWith(
                color: color ?? AppColors.textPrimary,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        // "dB" 단위
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'dB',
            style: AppTextStyles.levelLabel.copyWith(
              color: color?.withValues(alpha: 0.7) ??
                  AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
