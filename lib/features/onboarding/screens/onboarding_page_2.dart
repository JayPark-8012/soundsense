import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/utils/haptic_utils.dart';

/// 온보딩 Step 2 — 소음 기준 안내
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ─── 타이틀 ───
          Text(
            context.l10n.onboardingTitle2,
            textAlign: TextAlign.center,
            style: AppTextStyles.dbDisplay.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // ─── 서브 ───
          Text(
            context.l10n.onboardingDesc2,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // ─── 레벨 카드 5개 ───
          _buildLevelCard(
            color: AppColors.levelSilent,
            label: context.l10n.levelSilent,
            db: '~40dB',
            description: context.l10n.levelSilentDesc,
          ),
          _buildLevelCard(
            color: AppColors.levelQuiet,
            label: context.l10n.levelQuiet,
            db: '~55dB',
            description: context.l10n.levelQuietDesc,
          ),
          _buildLevelCard(
            color: AppColors.levelModerate,
            label: context.l10n.levelModerate,
            db: '~65dB',
            description: context.l10n.levelModerateDesc,
          ),
          _buildLevelCard(
            color: AppColors.levelLoud,
            label: context.l10n.levelLoud,
            db: '~75dB',
            description: context.l10n.levelLoudDesc,
          ),
          _buildLevelCard(
            color: AppColors.levelDanger,
            label: context.l10n.levelDanger,
            db: '85dB+',
            description: context.l10n.levelDangerDesc,
            isDanger: true,
          ),

          const Spacer(flex: 2),

          // ─── Next 버튼 ───
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                HapticUtils.light();
                onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.next,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),

          // 하단 여백 (인디케이터 공간)
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required Color color,
    required String label,
    required String db,
    required String description,
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isDanger
            ? Border.all(color: color.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        children: [
          // 왼쪽 색상 바
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),

          // 중앙: 레벨명 + 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.body.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (isDanger) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.warning_amber_rounded,
                          size: 14, color: color),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 우측: dB 범위
          Text(
            db,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
