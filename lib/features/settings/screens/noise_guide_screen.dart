import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';

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

const _levels = [
  _NoiseLevel(db: 30, description: 'Whisper, dawn', color: AppColors.levelSilent),
  _NoiseLevel(db: 50, description: 'Quiet office', color: AppColors.levelQuiet),
  _NoiseLevel(db: 60, description: 'Normal conversation', color: AppColors.levelModerate),
  _NoiseLevel(db: 70, description: 'TV, vacuum cleaner', color: AppColors.levelModerate),
  _NoiseLevel(db: 80, description: 'Alarm, busy street', color: AppColors.levelLoud),
  _NoiseLevel(
    db: 85,
    description: 'Prolonged exposure risk',
    color: AppColors.levelDanger,
    isDanger: true,
  ),
  _NoiseLevel(db: 100, description: 'Construction, subway', color: AppColors.levelDanger),
  _NoiseLevel(db: 120, description: 'Airplane takeoff', color: AppColors.levelDanger),
];

/// 소음 레벨 가이드 화면
class NoiseGuideScreen extends StatelessWidget {
  const NoiseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Noise Level Guide'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 상단 설명
          Text(
            'Understanding Noise Levels',
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How loud is the world around you?',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 레벨 카드 8개
          for (final level in _levels) _buildLevelCard(level),

          const SizedBox(height: 16),

          // WHO 기준 설명 카드
          _buildWhoCard(),
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
  Widget _buildWhoCard() {
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
                  'WHO Guideline',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.levelDanger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Continuous exposure to 85 dB or above for 8 hours '
                  'can cause permanent hearing damage.',
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
