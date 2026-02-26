import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/constants/db_levels.dart';
import 'package:soundsense/shared/utils/haptic_utils.dart';

/// 세션 카드 위젯
/// 레벨 색상 좌측 바 + 날짜/장소 + 평균 dB + 최대 dB + 측정 시간
class SessionCard extends StatefulWidget {
  const SessionCard({super.key, required this.session});

  final MeasurementSession session;

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final level = DbLevel.fromDb(session.avgDb);
    final duration = session.durationSec;
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    final timeText = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';

    // 날짜 포맷
    final dt = session.startedAt;
    final dateText =
        '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    final hourText =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: GestureDetector(
      onTap: () {
        HapticUtils.light();
        context.go('/history/${session.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ─── 좌측 레벨 색상 바 ───
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: level.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // ─── 카드 내용 ───
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // 왼쪽: 날짜, 장소, 측정 시간
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 날짜 + 시간
                            Row(
                              children: [
                                Text(
                                  dateText,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hourText,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // 장소명
                            Row(
                              children: [
                                Icon(
                                  session.locationName != null ||
                                          session.latitude != null
                                      ? Icons.location_on_outlined
                                      : Icons.location_off_outlined,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    session.locationName ?? 'Unknown location',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // 측정 시간 + 최대 dB
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 13,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeText,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'MAX ',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${session.maxDb.toStringAsFixed(1)} dB',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 오른쪽: 평균 dB 크게
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            session.avgDb.toStringAsFixed(1),
                            style: AppTextStyles.cardTitle.copyWith(
                              color: level.color,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'dB avg',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 4),
                      // 화살표
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
      ),
    );
  }
}
