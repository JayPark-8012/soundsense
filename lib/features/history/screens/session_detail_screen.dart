import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/constants/db_levels.dart';
import 'package:soundsense/shared/widgets/premium_guard.dart';

/// 세션 상세 Provider — ID로 세션 조회
final _sessionDetailProvider =
    FutureProvider.family<MeasurementSession?, int>((ref, id) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessionById(id);
});

/// 세션 상세 화면 — 화면 4
/// 앱바(장소/날짜) + 날짜시간 + AVG/MAX/MIN 카드 + 분포바 + 메모 + 위치 + 버튼
class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(sessionId);
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session Detail')),
        body: const Center(child: Text('Invalid session ID')),
      );
    }

    final sessionAsync = ref.watch(_sessionDetailProvider(id));

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Session Detail')),
            body: Center(
              child: Text(
                'Session not found',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return _buildDetail(context, ref, session);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Session Detail')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Session Detail')),
        body: Center(
          child: Text(
            'Failed to load session',
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  /// 상세 화면 본체
  Widget _buildDetail(
    BuildContext context,
    WidgetRef ref,
    MeasurementSession session,
  ) {
    final level = DbLevel.fromDb(session.avgDb);
    final dt = session.startedAt;
    final dateText =
        '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    final timeText =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final minutes = session.durationSec ~/ 60;
    final seconds = session.durationSec % 60;
    final durationText =
        minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';

    // 앱바 제목: 장소명 우선, 없으면 날짜
    final appBarTitle = session.locationName ?? dateText;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _onShare(session),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 날짜/시간 + 측정 시간 ───
            _buildInfoHeader(dateText, timeText, durationText, level),

            const SizedBox(height: 20),

            // ─── AVG / MAX / MIN 카드 3개 ───
            _buildDbCards(session, level),

            const SizedBox(height: 20),

            // ─── 레벨 평가 텍스트 ───
            _buildLevelEvaluation(level),

            const SizedBox(height: 20),

            // ─── 청력 안전 시간 ───
            _buildSafeExposureTime(session.avgDb),

            const SizedBox(height: 20),

            // ─── 소음 분포 도넛 차트 ───
            _buildDistributionDonut(session),

            const SizedBox(height: 20),

            // ─── 소음 분포 바 (Distribution Bar) ───
            _buildDistributionBar(session),

            // ─── 메모 (있을 때만) ───
            if (session.memo != null && session.memo!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildMemoSection(session.memo!),
            ],

            // ─── 위치 (있을 때만) ───
            if (session.locationName != null ||
                session.latitude != null) ...[
              const SizedBox(height: 20),
              _buildLocationSection(context, session),
            ],

            const SizedBox(height: 24),

            // ─── 시간대별 라인 차트 (PRO) ───
            PremiumGuard(
              featureName: 'Timeline Chart',
              lockedChild: _buildLockedTimelineChart(),
              child: _buildTimelineChartPro(session),
            ),

            const SizedBox(height: 24),

            // ─── CSV 내보내기 (PRO) ───
            PremiumGuard(
              featureName: 'CSV Export',
              lockedChild: _buildLockedCsvExport(),
              child: _buildCsvExportPro(session),
            ),

            const SizedBox(height: 24),

            // ─── Share / Delete 버튼 ───
            _buildActionButtons(context, ref, session),
          ],
        ),
      ),
    );
  }

  /// 날짜/시간 + 측정 시간 헤더
  Widget _buildInfoHeader(
    String dateText,
    String timeText,
    String durationText,
    DbLevel level,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // 날짜 + 시간
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // 측정 시간
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: level.color,
                ),
                const SizedBox(width: 4),
                Text(
                  durationText,
                  style: AppTextStyles.body.copyWith(
                    color: level.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AVG / MAX / MIN dB 카드 3개
  Widget _buildDbCards(MeasurementSession session, DbLevel level) {
    return Row(
      children: [
        Expanded(
          child: _buildDbCard(
            label: 'AVG',
            value: session.avgDb,
            color: level.color,
            isMain: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDbCard(
            label: 'MAX',
            value: session.maxDb,
            color: AppColors.levelDanger,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDbCard(
            label: 'MIN',
            value: session.minDb,
            color: AppColors.levelSilent,
          ),
        ),
      ],
    );
  }

  Widget _buildDbCard({
    required String label,
    required double value,
    required Color color,
    bool isMain = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMain ? color.withValues(alpha: 0.4) : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: isMain ? 28 : 22,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'dB',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 소음 분포 바 — 전체 범위에서 avg 위치 시각화
  Widget _buildDistributionBar(MeasurementSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Noise Distribution',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // 분포 바
          _DistributionBar(
            avgDb: session.avgDb,
            minDb: session.minDb,
            maxDb: session.maxDb,
          ),
          const SizedBox(height: 12),
          // 레벨 범위 범례
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 dB',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              Text(
                '130 dB',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 메모 섹션
  Widget _buildMemoSection(String memo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Memo',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            memo,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 레벨 평가 텍스트 — DbLevel별 코멘트
  Widget _buildLevelEvaluation(DbLevel level) {
    final (text, emoji) = switch (level) {
      DbLevel.silent => ('Very peaceful environment', '🔵'),
      DbLevel.quiet => ('Comfortable noise level', '🟢'),
      DbLevel.moderate => ('Normal everyday noise', '🟡'),
      DbLevel.loud => ('Prolonged exposure may cause fatigue', '🟠'),
      DbLevel.danger => ('⚠️ Risk of hearing damage with prolonged exposure', '🔴'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: level.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 청력 안전 시간 — WHO 기준 (85dB → 8시간, 3dB마다 반감)
  Widget _buildSafeExposureTime(double avgDb) {
    final String safeText;
    if (avgDb < 85) {
      safeText = 'Safe for extended exposure';
    } else {
      final hours = 8.0 / math.pow(2, (avgDb - 85) / 3);
      if (hours >= 1) {
        safeText = '${hours.toStringAsFixed(1)} hours';
      } else {
        final minutes = (hours * 60).round();
        safeText = '$minutes min';
      }
    }

    final isSafe = avgDb < 85;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            isSafe ? Icons.shield_rounded : Icons.hearing_rounded,
            size: 20,
            color: isSafe ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe Exposure Time (WHO)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  safeText,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: isSafe ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 소음 분포 도넛 차트 — avgDb/maxDb/minDb 기반 추정 분포
  Widget _buildDistributionDonut(MeasurementSession session) {
    // 각 레벨 구간에 대한 추정 비율 계산
    final distribution = _estimateDistribution(
      session.avgDb, session.minDb, session.maxDb,
    );

    // 0% 구간은 제외
    final sections = <PieChartSectionData>[];
    final legends = <(DbLevel, double)>[];
    for (final entry in distribution.entries) {
      if (entry.value > 0) {
        sections.add(PieChartSectionData(
          value: entry.value,
          color: entry.key.color,
          radius: 24,
          showTitle: false,
        ));
        legends.add((entry.key, entry.value));
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level Distribution',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 도넛 차트
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 32,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // 범례
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legends.map((e) {
                    final (level, pct) = e;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: level.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              level.labelEn,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '${pct.round()}%',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// avgDb/minDb/maxDb 기반으로 각 레벨 구간 비율 추정
  /// 삼각 분포: avgDb를 중심으로 minDb~maxDb 범위
  Map<DbLevel, double> _estimateDistribution(
    double avgDb, double minDb, double maxDb,
  ) {
    final range = maxDb - minDb;
    if (range < 1) {
      // 거의 일정한 소음 → avg 레벨 100%
      return {
        for (final l in DbLevel.values)
          l: l == DbLevel.fromDb(avgDb) ? 100.0 : 0.0,
      };
    }

    // 삼각 분포 PDF 기반 적분으로 각 구간 비율 계산
    final boundaries = [0.0, 30.0, 50.0, 70.0, 85.0, 130.0];
    final result = <DbLevel, double>{};
    double totalWeight = 0;

    for (int i = 0; i < DbLevel.values.length; i++) {
      final lo = math.max(boundaries[i], minDb);
      final hi = math.min(boundaries[i + 1], maxDb);
      if (lo >= hi) {
        result[DbLevel.values[i]] = 0;
        continue;
      }
      // 삼각 분포 가중치: 구간 폭 * (1 - 구간 중심과 avg의 거리 / 전체 범위)
      final mid = (lo + hi) / 2;
      final dist = (mid - avgDb).abs();
      final weight = (hi - lo) * math.max(0.1, 1.0 - dist / range);
      result[DbLevel.values[i]] = weight;
      totalWeight += weight;
    }

    // 백분율 변환
    if (totalWeight > 0) {
      for (final key in result.keys.toList()) {
        result[key] = (result[key]! / totalWeight) * 100;
      }
    }

    return result;
  }

  /// 위치 섹션 — 장소명 탭 시 지도로 이동
  Widget _buildLocationSection(BuildContext context, MeasurementSession session) {
    final hasCoords = session.latitude != null && session.longitude != null;

    return InkWell(
      onTap: hasCoords
          ? () => context.go('/map?sessionId=${session.id}')
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.locationName ?? 'Location recorded',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasCoords)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${session.latitude!.toStringAsFixed(4)}, '
                        '${session.longitude!.toStringAsFixed(4)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (session.isSharedToMap)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Shared',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            if (hasCoords)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  /// PRO 잠금 — 시간대별 라인 차트 (lockedChild)
  Widget _buildLockedTimelineChart() {
    return Opacity(
      opacity: 0.4,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.proGold.withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          children: [
            // ─── 흐린 가짜 차트 라인 ───
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: CustomPaint(
                  painter: _MockChartPainter(),
                ),
              ),
            ),
            // ─── 잠금 오버레이 ───
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '\u{1F4CA}',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Timeline Chart',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 28,
                    color: AppColors.proGold.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available in PRO',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.proGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.proGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Unlock with PRO',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.proGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PRO — 시간대별 라인 차트 (child, 미구현 플레이스홀더)
  Widget _buildTimelineChartPro(MeasurementSession session) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline Chart',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              'Timeline data will appear here',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  /// PRO 잠금 — CSV 내보내기 (lockedChild)
  Widget _buildLockedCsvExport() {
    return Opacity(
      opacity: 0.85,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.proGold.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: AppColors.proGold.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Export CSV',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.proGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'PRO',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.proGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PRO — CSV 내보내기 (child, 미구현 플레이스홀더)
  Widget _buildCsvExportPro(MeasurementSession session) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: CSV 내보내기 구현
        },
        icon: const Icon(Icons.file_download_outlined, size: 18),
        label: const Text('Export CSV'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Share / Delete 버튼
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    MeasurementSession session,
  ) {
    return Row(
      children: [
        // Share 버튼
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _onShare(session),
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.divider),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Delete 버튼
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _onDelete(context, ref, session),
            icon: Icon(Icons.delete_outline_rounded,
                size: 18, color: AppColors.error),
            label: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 시스템 공유시트
  void _onShare(MeasurementSession session) {
    final level = DbLevel.fromDb(session.avgDb);
    final dt = session.startedAt;
    final dateText =
        '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

    final text = StringBuffer()
      ..writeln('SoundSense - Noise Report')
      ..writeln('Date: $dateText')
      ..writeln('Level: ${level.labelEn}')
      ..writeln('AVG: ${session.avgDb.toStringAsFixed(1)} dB')
      ..writeln('MAX: ${session.maxDb.toStringAsFixed(1)} dB')
      ..writeln('MIN: ${session.minDb.toStringAsFixed(1)} dB');

    if (session.locationName != null) {
      text.writeln('Location: ${session.locationName}');
    }
    if (session.memo != null && session.memo!.isNotEmpty) {
      text.writeln('Memo: ${session.memo}');
    }

    Share.share(text.toString());
  }

  /// 삭제 확인 다이얼로그 → 삭제 후 히스토리로 이동
  void _onDelete(
    BuildContext context,
    WidgetRef ref,
    MeasurementSession session,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Session',
          style: AppTextStyles.cardTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This session will be permanently deleted. '
          'This action cannot be undone.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final repo = ref.read(sessionRepositoryProvider);
              await repo.deleteSession(session.id);
              if (context.mounted) {
                context.go('/history');
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 소음 분포 바 — CustomPainter 기반
/// 전체 0~130 범위에서 min~max 구간 + avg 위치 표시
class _DistributionBar extends StatelessWidget {
  const _DistributionBar({
    required this.avgDb,
    required this.minDb,
    required this.maxDb,
  });

  final double avgDb;
  final double minDb;
  final double maxDb;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: CustomPaint(
        size: const Size(double.infinity, 48),
        painter: _DistributionBarPainter(
          avgDb: avgDb,
          minDb: minDb,
          maxDb: maxDb,
        ),
      ),
    );
  }
}

class _DistributionBarPainter extends CustomPainter {
  _DistributionBarPainter({
    required this.avgDb,
    required this.minDb,
    required this.maxDb,
  });

  final double avgDb;
  final double minDb;
  final double maxDb;

  static const double _maxRange = 130.0;

  // 5단계 레벨 구간 (0~30, 30~50, 50~70, 70~85, 85~130)
  static const _segments = [
    (end: 30.0, color: AppColors.levelSilent),
    (end: 50.0, color: AppColors.levelQuiet),
    (end: 70.0, color: AppColors.levelModerate),
    (end: 85.0, color: AppColors.levelLoud),
    (end: 130.0, color: AppColors.levelDanger),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = 12.0;
    final barY = (size.height - barHeight) / 2 + 4;
    final barRadius = Radius.circular(barHeight / 2);

    // ─── 배경 (전체 범위, 어두운 색) ───
    final bgPaint = Paint()..color = AppColors.surfaceLight;
    canvas.drawRRect(
      RRect.fromLTRBR(0, barY, size.width, barY + barHeight, barRadius),
      bgPaint,
    );

    // ─── 5단계 색상 구간 그리기 (낮은 opacity) ───
    double prevEnd = 0;
    for (final seg in _segments) {
      final startX = (prevEnd / _maxRange) * size.width;
      final endX = (seg.end / _maxRange) * size.width;
      final paint = Paint()..color = seg.color.withValues(alpha: 0.15);
      canvas.drawRect(
        Rect.fromLTRB(startX, barY, endX, barY + barHeight),
        paint,
      );
      prevEnd = seg.end;
    }

    // ─── min~max 범위 하이라이트 ───
    final minX = (minDb.clamp(0, _maxRange) / _maxRange) * size.width;
    final maxX = (maxDb.clamp(0, _maxRange) / _maxRange) * size.width;
    final rangePaint = Paint()
      ..color = DbLevel.fromDb(avgDb).color.withValues(alpha: 0.4);
    canvas.drawRRect(
      RRect.fromLTRBR(
        minX,
        barY,
        maxX,
        barY + barHeight,
        barRadius,
      ),
      rangePaint,
    );

    // ─── avg 위치 마커 (세로 선 + 원형 인디케이터) ───
    final avgX = (avgDb.clamp(0, _maxRange) / _maxRange) * size.width;
    final avgColor = DbLevel.fromDb(avgDb).color;

    // 세로 선
    final linePaint = Paint()
      ..color = avgColor
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(avgX, barY - 4),
      Offset(avgX, barY + barHeight + 4),
      linePaint,
    );

    // 원형 인디케이터
    final dotPaint = Paint()..color = avgColor;
    canvas.drawCircle(Offset(avgX, barY - 8), 5, dotPaint);

    // 외곽선
    final dotBorderPaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(avgX, barY - 8), 5, dotBorderPaint);

    // ─── avg 라벨 ───
    final textSpan = TextSpan(
      text: avgDb.toStringAsFixed(1),
      style: TextStyle(
        color: avgColor,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    // 라벨 위치: 마커 위, 화면 밖으로 안 나가게 클램프
    final labelX =
        (avgX - textPainter.width / 2).clamp(0, size.width - textPainter.width);
    textPainter.paint(canvas, Offset(labelX.toDouble(), barY + barHeight + 6));
  }

  @override
  bool shouldRepaint(covariant _DistributionBarPainter oldDelegate) {
    return oldDelegate.avgDb != avgDb ||
        oldDelegate.minDb != minDb ||
        oldDelegate.maxDb != maxDb;
  }
}

/// 잠금 타임라인 차트 배경 — 가짜 라인 차트 패턴
class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.proGold.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [0.4, 0.6, 0.35, 0.7, 0.5, 0.65, 0.3, 0.55, 0.7, 0.45];
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // 수평 그리드 라인
    final gridPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
