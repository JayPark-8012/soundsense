import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/database/session_repository.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/features/history/providers/history_provider.dart';
import 'package:soundsense/features/map/providers/map_provider.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/shared/constants/db_levels.dart';
import 'package:soundsense/shared/providers/premium_provider.dart';
import 'package:soundsense/shared/widgets/noise_card_generator.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';
import 'package:soundsense/shared/widgets/premium_guard.dart';

/// 세션 상세 Provider — ID로 세션 조회
final _sessionDetailProvider =
    FutureProvider.family<MeasurementSession?, int>((ref, id) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessionById(id);
});

/// 세션 상세 화면 — 화면 4
/// 앱바(장소/날짜) + 날짜시간 + AVG/MAX/MIN 카드 + 분포바 + 메모 + 위치 + 버튼
class SessionDetailScreen extends ConsumerStatefulWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.sessionId);
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.sessionDetail)),
        body: Center(child: Text(context.l10n.invalidSessionId)),
      );
    }

    final sessionAsync = ref.watch(_sessionDetailProvider(id));

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.sessionDetail)),
            body: Center(
              child: Text(
                context.l10n.sessionNotFound,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return _buildDetail(context, ref, session);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(context.l10n.sessionDetail)),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.sessionDetail)),
        body: Center(
          child: Text(
            context.l10n.failedToLoadSession,
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

    // 본문 콘텐츠 (잠금/비잠금 공용)
    final bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoHeader(dateText, timeText, durationText, level),
        const SizedBox(height: 20),
        _buildDbCards(session, level),
        const SizedBox(height: 20),
        _buildLevelEvaluation(level),
        const SizedBox(height: 20),
        _buildSafeExposureTime(session.avgDb),
        const SizedBox(height: 20),
        _buildDistributionDonut(session),
        const SizedBox(height: 20),
        _buildDistributionBar(session),
        if (session.memo != null && session.memo!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildMemoSection(session.memo!),
        ],
        if (session.locationName != null ||
            session.latitude != null) ...[
          const SizedBox(height: 20),
          _buildLocationSection(context, session),
        ],
        const SizedBox(height: 24),
        PremiumGuard(
          featureName: context.l10n.timelineChart,
          lockedChild: _buildLockedTimelineChart(),
          child: _buildTimelineChartPro(session),
        ),
        const SizedBox(height: 24),
        PremiumGuard(
          featureName: context.l10n.exportCsv,
          lockedChild: _buildLockedCsvExport(),
          child: _buildCsvExportPro(context, session),
        ),
        const SizedBox(height: 24),
        _buildActionButtons(context, ref, session),
      ],
    );

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => _onNoiseCard(context, ref, session),
                icon: const Icon(Icons.style_outlined),
                tooltip: context.l10n.noiseCard,
              ),
              IconButton(
                onPressed: () => _onShare(session),
                icon: const Icon(Icons.share_outlined),
                tooltip: context.l10n.share,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: bodyContent,
          ),
        ),
        // ─── 로딩 오버레이 (Noise Card 생성 중) ───
        if (_isLoading)
          const ColoredBox(
            color: Color(0x88000000),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
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
            label: context.l10n.avgLabel,
            value: session.avgDb,
            color: level.color,
            isMain: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDbCard(
            label: context.l10n.maxLabel,
            value: session.maxDb,
            color: AppColors.levelDanger,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDbCard(
            label: context.l10n.minLabel,
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
            context.l10n.noiseDistribution,
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
                context.l10n.memo,
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
      DbLevel.silent => (context.l10n.evalSilent, '🔵'),
      DbLevel.quiet => (context.l10n.evalQuiet, '🟢'),
      DbLevel.moderate => (context.l10n.evalModerate, '🟡'),
      DbLevel.loud => (context.l10n.evalLoud, '🟠'),
      DbLevel.danger => (context.l10n.evalDanger, '🔴'),
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
      safeText = context.l10n.safeForExtendedExposure;
    } else {
      final hours = 8.0 / math.pow(2, (avgDb - 85) / 3);
      if (hours >= 1) {
        safeText = context.l10n.safeHours(hours.toStringAsFixed(1));
      } else {
        final minutes = (hours * 60).round();
        safeText = context.l10n.safeMinutes(minutes.toString());
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
                  context.l10n.safeExposureTime,
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
            context.l10n.levelDistribution,
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
                    session.locationName ?? context.l10n.locationRecorded,
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
                    context.l10n.sharedBadge,
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
                        context.l10n.timelineChart,
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
                    context.l10n.availableInPro,
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
                      context.l10n.unlockPro,
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

  /// PRO — 시간대별 라인 차트 (fl_chart LineChart)
  Widget _buildTimelineChartPro(MeasurementSession session) {
    final samples = session.dbSamples;

    // 샘플 없는 이전 세션 → 안내 메시지
    if (samples.isEmpty) {
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
              context.l10n.timelineChart,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                context.l10n.noTimelineData,
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

    // 차트 데이터 포인트 생성
    final spots = <FlSpot>[];
    for (int i = 0; i < samples.length; i++) {
      spots.add(FlSpot(i.toDouble(), samples[i]));
    }

    // Y축 범위 계산
    final minY = (session.minDb - 5).clamp(0.0, 130.0);
    final maxY = (session.maxDb + 5).clamp(0.0, 130.0);
    final level = DbLevel.fromDb(session.avgDb);

    return Container(
      height: 240,
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
              Text(
                context.l10n.timelineChart,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${samples.length}s',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider.withValues(alpha: 0.5),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: (maxY - minY) / 4,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: math.max(1, (samples.length / 5).roundToDouble()),
                      getTitlesWidget: (value, meta) {
                        final sec = value.toInt();
                        if (sec >= samples.length) return const SizedBox.shrink();
                        final m = sec ~/ 60;
                        final s = sec % 60;
                        final label = m > 0 ? '${m}m${s}s' : '${s}s';
                        return Text(
                          label,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 9,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: level.color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: level.color.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surface,
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((spot) => LineTooltipItem(
                              '${spot.y.toStringAsFixed(1)} dB',
                              TextStyle(
                                color: level.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
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
              context.l10n.exportCsv,
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
                context.l10n.pro,
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

  /// PRO — CSV 내보내기
  Widget _buildCsvExportPro(BuildContext context, MeasurementSession session) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _onExportCsv(context, session),
        icon: const Icon(Icons.file_download_outlined, size: 18),
        label: Text(context.l10n.exportCsv),
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

  /// CSV 파일 생성 + 시스템 공유시트
  void _onExportCsv(BuildContext context, MeasurementSession session) async {
    final shareText = context.l10n.noiseShareText;
    final failedText = context.l10n.failedToExportCsv;
    try {
      final buffer = StringBuffer();
      buffer.writeln('time_seconds,db_value,level');

      if (session.dbSamples.isNotEmpty) {
        for (int i = 0; i < session.dbSamples.length; i++) {
          final db = session.dbSamples[i];
          final level = DbLevel.fromDb(db).labelEn;
          buffer.writeln('$i,${db.toStringAsFixed(1)},$level');
        }
      } else {
        // 이전 세션 (샘플 없음) → 요약 데이터
        buffer.writeln('0,${session.avgDb.toStringAsFixed(1)},${DbLevel.fromDb(session.avgDb).labelEn}');
      }

      final dir = await getTemporaryDirectory();
      final dt = session.startedAt;
      final fileName = 'soundsense_'
          '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}_'
          '${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
      );
    } catch (e) {
      debugPrint('CSV export error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failedText),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
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
            label: Text(context.l10n.share),
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
              context.l10n.deleteSession,
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

  /// Noise Card 생성 + 미리보기
  Future<void> _onNoiseCard(
    BuildContext context,
    WidgetRef ref,
    MeasurementSession session,
  ) async {
    final failedText = context.l10n.failedToGenerateCard;
    if (mounted) setState(() => _isLoading = true);
    try {
      final isPremium = ref.read(isPremiumProvider);
      final bytes = await NoiseCardGenerator.generate(
        session,
        isPremium: isPremium,
      );

      if (!mounted) return;

      // 다이얼로그 닫힐 때까지 대기 → finally에서 로딩 해제 보장
      await _showNoiseCardPreview(this.context, bytes);
    } catch (e) {
      debugPrint('NoiseCard error: $e');
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(failedText),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Noise Card 미리보기 다이얼로그
  Future<void> _showNoiseCardPreview(BuildContext context, Uint8List bytes) {
    final savedText = context.l10n.savedToPhotos;
    final failedSaveText = context.l10n.failedToSave;
    final savingText = context.l10n.saving;
    final sharingText = context.l10n.sharing;
    bool isSaving = false;
    bool isSharing = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 카드 미리보기
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(bytes, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 16),

                // 💾 Save to Photos
                if (!kIsWeb)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setDialogState(() => isSaving = true);
                              try {
                                await Gal.putImageBytes(bytes);
                                if (ctx.mounted) Navigator.of(ctx).pop();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(savedText),
                                      backgroundColor: AppColors.success,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint('Save to Photos error: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(failedSaveText),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (ctx.mounted) {
                                  setDialogState(() => isSaving = false);
                                }
                              }
                            },
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : const Icon(Icons.save_alt_rounded, size: 18),
                      label: Text(isSaving ? savingText : context.l10n.saveToPhotos),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.5),
                        disabledForegroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (!kIsWeb) const SizedBox(height: 8),

                // 📤 Share
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isSharing
                        ? null
                        : () async {
                            final shareText = context.l10n.measuredWith;
                            setDialogState(() => isSharing = true);
                            try {
                              final dir = await getTemporaryDirectory();
                              final file = File(
                                '${dir.path}/noise_card_${DateTime.now().millisecondsSinceEpoch}.png',
                              );
                              await file.writeAsBytes(bytes);
                              await Share.shareXFiles(
                                [XFile(file.path)],
                                text: shareText,
                              );
                            } catch (e) {
                              debugPrint('Share error: $e');
                            } finally {
                              if (ctx.mounted) {
                                setDialogState(() => isSharing = false);
                              }
                            }
                          },
                    icon: isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : const Icon(Icons.share_outlined, size: 18),
                    label: Text(isSharing ? sharingText : context.l10n.share),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      disabledForegroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 닫기
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    context.l10n.close,
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 시스템 공유시트
  void _onShare(MeasurementSession session) {
    final level = DbLevel.fromDb(session.avgDb);
    final dt = session.startedAt;
    final dateText =
        '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

    final text = StringBuffer()
      ..writeln(context.l10n.shareNoiseReport)
      ..writeln(context.l10n.shareDate(dateText))
      ..writeln(context.l10n.shareLevel(level.labelEn))
      ..writeln(context.l10n.shareAvg(session.avgDb.toStringAsFixed(1)))
      ..writeln(context.l10n.shareMax(session.maxDb.toStringAsFixed(1)))
      ..writeln(context.l10n.shareMin(session.minDb.toStringAsFixed(1)));

    if (session.locationName != null) {
      text.writeln(context.l10n.shareLocationLabel(session.locationName!));
    }
    if (session.memo != null && session.memo!.isNotEmpty) {
      text.writeln(context.l10n.shareMemoLabel(session.memo!));
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
          context.l10n.deleteConfirm,
          style: AppTextStyles.cardTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          context.l10n.deleteConfirmDesc,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final repo = ref.read(sessionRepositoryProvider);
              await repo.deleteSession(session.id);
              // 히스토리 + 지도 Provider 갱신
              ref.invalidate(sessionListProvider);
              ref.invalidate(weeklyChartProvider);
              ref.invalidate(mapSessionsProvider);
              ref.invalidate(mapMarkersProvider);
              if (context.mounted) {
                context.go('/history');
              }
            },
            child: Text(
              context.l10n.deleteSession,
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
