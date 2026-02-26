import 'package:flutter/material.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/features/map/widgets/marker_info_sheet.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// Google Maps 대체 — 웹에서 지도 대신 표시
class WebMapPlaceholder extends StatelessWidget {
  const WebMapPlaceholder({super.key, this.sessions = const []});

  final List<MeasurementSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // ─── 헤더 ───
          const SizedBox(height: 60),
          Icon(
            Icons.map_rounded,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Map Preview (Web)',
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Google Maps is not available on web.\nShowing saved locations below.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // ─── 세션 리스트 ───
          if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'No location data yet',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sessions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _MarkerTile(
                    session: session,
                    onTap: () => MarkerInfoSheet.show(context, session),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MarkerTile extends StatelessWidget {
  const _MarkerTile({required this.session, required this.onTap});

  final MeasurementSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = DbLevel.fromDb(session.avgDb);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // 레벨 색상 인디케이터
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: level.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.locationName ?? 'Unknown',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${session.avgDb.toStringAsFixed(1)} dB · ${level.labelEn}',
                    style: AppTextStyles.caption.copyWith(
                      color: level.color,
                    ),
                  ),
                ],
              ),
            ),
            // 좌표
            Text(
              '${session.latitude?.toStringAsFixed(3)}, ${session.longitude?.toStringAsFixed(3)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
