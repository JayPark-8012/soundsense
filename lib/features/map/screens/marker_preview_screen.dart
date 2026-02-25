import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/features/map/widgets/noise_map_marker.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// 마커 미리보기 화면 — 개발용
/// 5단계 레벨별 NoiseMapMarker 리플 애니메이션 확인
class MarkerPreviewScreen extends StatelessWidget {
  const MarkerPreviewScreen({super.key});

  /// 테스트용 dB 값 (레벨별 대표값)
  static const _samples = [
    (db: 20.0, label: 'Silent (20 dB)'),
    (db: 45.0, label: 'Quiet (45 dB)'),
    (db: 65.0, label: 'Moderate (65 dB)'),
    (db: 80.0, label: 'Loud (80 dB)'),
    (db: 95.0, label: 'Danger (95 dB)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Marker Preview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── 설명 ───
            Text(
              'NoiseMapMarker Ripple Animation',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Size, color, and speed scale with dB level',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 32),

            // ─── 5단계 마커 그리드 ───
            ..._samples.map((sample) {
              final level = DbLevel.fromDb(sample.db);
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    // 마커
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: Center(
                        child: NoiseMapMarker(
                          avgDb: sample.db,
                          level: level,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: level.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              level.labelEn,
                              style: AppTextStyles.body.copyWith(
                                color: level.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sample.label,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatSpec(sample.db),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 스펙 정보 문자열 생성
  String _formatSpec(double db) {
    final clamped = db.clamp(40.0, 100.0);
    final t = (clamped - 40.0) / 60.0;
    final radius = (30.0 + t * 50.0).toStringAsFixed(0);
    final speed = (3.0 - t * 2.0).toStringAsFixed(1);
    return 'Radius: ${radius}px | Speed: ${speed}s';
  }
}
