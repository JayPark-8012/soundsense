import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';

/// 소음 레벨 가이드 데이터
class _NoiseLevel {
  const _NoiseLevel({
    required this.db,
    required this.description,
    required this.color,
    this.isDanger = false,
  });

  final int db;
  final String description;
  final Color color;
  final bool isDanger;
}

List<_NoiseLevel> _getLevels(BuildContext context) => [
  _NoiseLevel(db: 30, description: context.l10n.guideWhisper, color: AppColors.levelSilent),
  _NoiseLevel(db: 50, description: context.l10n.guideQuietOffice, color: AppColors.levelQuiet),
  _NoiseLevel(db: 60, description: context.l10n.guideConversation, color: AppColors.levelModerate),
  _NoiseLevel(db: 70, description: context.l10n.guideTvVacuum, color: AppColors.levelModerate),
  _NoiseLevel(db: 80, description: context.l10n.guideAlarmStreet, color: AppColors.levelLoud),
  _NoiseLevel(
    db: 85,
    description: context.l10n.guideProlongedRisk,
    color: AppColors.levelDanger,
    isDanger: true,
  ),
  _NoiseLevel(db: 100, description: context.l10n.guideConstruction, color: AppColors.levelDanger),
  _NoiseLevel(db: 120, description: context.l10n.guideAirplane, color: AppColors.levelDanger),
];

/// 소음 레벨 가이드 화면
class NoiseGuideScreen extends StatelessWidget {
  const NoiseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.l10n.noiseGuide),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 상단 설명
          Text(
            context.l10n.understandingNoiseLevels,
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.howLoudIsWorld,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 레벨 카드 8개
          for (final level in _getLevels(context)) _buildLevelCard(level),

          const SizedBox(height: 16),

          // WHO 기준 설명 카드
          _buildWhoCard(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 레벨 카드 — 왼쪽 색상 바 + dB 수치 + 설명
  Widget _buildLevelCard(_NoiseLevel level) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: level.isDanger
            ? Border.all(color: AppColors.levelDanger.withValues(alpha: 0.5), width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            // 왼쪽 색상 바
            Container(
              width: 5,
              height: 64,
              color: level.color,
            ),
            const SizedBox(width: 16),

            // dB 수치
            SizedBox(
              width: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${level.db}',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: level.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'dB',
                    style: AppTextStyles.caption.copyWith(
                      color: level.color.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 설명 + 경고 아이콘
            Expanded(
              child: Row(
                children: [
                  if (level.isDanger) ...[
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: AppColors.levelDanger,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      level.description,
                      style: AppTextStyles.body.copyWith(
                        color: level.isDanger
                            ? AppColors.levelDanger
                            : AppColors.textSecondary,
                        fontWeight:
                            level.isDanger ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  /// WHO 기준 경고 카드
  Widget _buildWhoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.levelDanger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.levelDanger.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            size: 28,
            color: AppColors.levelDanger.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.whoGuideline,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.levelDanger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.whoWarningText,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
