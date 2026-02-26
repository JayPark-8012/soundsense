import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/constants/db_levels.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';

/// 지도 마커 탭 시 표시되는 바텀시트
/// 세션 핵심 정보 요약 + 상세 보기 이동
class MarkerInfoSheet extends StatelessWidget {
  const MarkerInfoSheet({super.key, required this.session});

  final MeasurementSession session;

  /// 바텀시트 표시 헬퍼
  static Future<void> show(BuildContext context, MeasurementSession session) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MarkerInfoSheet(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = DbLevel.fromDb(session.avgDb);
    final location = (session.locationName != null &&
            session.locationName!.trim().isNotEmpty)
        ? session.locationName!
        : context.l10n.unknownLocation;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── 레벨 색상 상단 바 ───
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: level.color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ─── 드래그 핸들 ───
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ─── 메인 정보 카드 ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: level.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: level.color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 장소명
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 평균 dB (크게) + 레벨 텍스트
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            session.avgDb.toStringAsFixed(1),
                            style: AppTextStyles.cardTitle.copyWith(
                              color: level.color,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'dB',
                            style: AppTextStyles.body.copyWith(
                              color: level.color.withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                              style: AppTextStyles.caption.copyWith(
                                color: level.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── 날짜/시간 + 측정 시간 ───
                Row(
                  children: [
                    // 날짜/시간
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateTime(session.startedAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    // 측정 시간
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(session.durationSec),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ─── 상세 보기 버튼 (로컬 세션만) ───
                // durationSec > 0 → 로컬 Isar 세션 (Firestore-only는 0)
                if (session.durationSec > 0)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/history/${session.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.viewDetails,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜/시간 포맷 — "2025.01.15  14:30"
  String _formatDateTime(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y.$m.$d  $h:$min';
  }

  /// 측정 시간 포맷 — "45분", "1시간 20분", "30초"
  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final minutes = totalSeconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainMinutes = minutes % 60;
    if (hours > 0) {
      return remainMinutes > 0 ? '${hours}h ${remainMinutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
}
