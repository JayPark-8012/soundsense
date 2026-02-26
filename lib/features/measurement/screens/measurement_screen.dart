import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/core/permissions/microphone_permission.dart';
import 'package:soundsense/features/measurement/providers/measurement_provider.dart';
import 'package:soundsense/features/measurement/widgets/db_gauge_widget.dart';
import 'package:soundsense/features/measurement/widgets/db_number_display.dart';
import 'package:soundsense/features/measurement/widgets/level_badge.dart';
import 'package:soundsense/features/measurement/widgets/waveform_visualizer.dart';
import 'package:soundsense/features/measurement/screens/save_session_sheet.dart';
import 'package:soundsense/shared/constants/app_constants.dart';
import 'package:soundsense/shared/constants/db_levels.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';
import 'package:soundsense/shared/utils/haptic_utils.dart';

/// 측정 화면 — 전면 재구성
/// 고정 상단 + 스크롤 중단 + 고정 하단 버튼
class MeasurementScreen extends ConsumerStatefulWidget {
  const MeasurementScreen({super.key});

  @override
  ConsumerState<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends ConsumerState<MeasurementScreen> {
  // 마이크로 인터랙션 상태
  bool _isButtonPressed = false;
  bool _wasDangerLevel = false;
  double _badgeScale = 1.0;
  double _previousDb = 0.0;
  bool _isDbHighlighted = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 마이크 권한 상태 확인
    Future.microtask(() {
      ref.read(micPermissionProvider.notifier).check();
    });

    // 측정 상태 변화 시 WakeLock 토글 + danger 감지
    ref.listenManual(measurementProvider, (previous, next) {
      if (next is MeasurementActive) {
        WakelockPlus.enable();

        // danger 레벨 처음 진입 시 배지 pulse + 햅틱
        final isDanger = next.level == DbLevel.danger;
        if (isDanger && !_wasDangerLevel) {
          HapticUtils.warning();
          setState(() => _badgeScale = 1.15);
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) setState(() => _badgeScale = 1.0);
          });
        }
        _wasDangerLevel = isDanger;

        // dB 큰 변화 (5dB+) 시 숫자 색상 강조
        final dbDiff = (next.currentDb - _previousDb).abs();
        if (dbDiff >= 5 && _previousDb > 0) {
          setState(() => _isDbHighlighted = true);
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _isDbHighlighted = false);
          });
        }
        _previousDb = next.currentDb;
      } else if (previous is MeasurementActive) {
        WakelockPlus.disable();
        _wasDangerLevel = false;
        _previousDb = 0.0;
      }
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measureState = ref.watch(measurementProvider);
    final micPermission = ref.watch(micPermissionProvider);
    final levelColor = _getLevelColor(measureState);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.l10n.appName),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              levelColor.withValues(alpha: 0.08),
              AppColors.background,
            ],
          ),
        ),
        child: _buildBody(measureState, micPermission),
      ),
    );
  }

  /// 세션 저장 바텀시트 표시 — 측정 일시정지 후 시트 열기
  void _showSaveSheet(MeasurementState state) {
    final notifier = ref.read(measurementProvider.notifier);

    // dbSamples를 pause/reset 전에 복사
    final dbSamples = List<double>.from(notifier.dbSamples);

    if (state is MeasurementActive) {
      notifier.pause();
    }

    final double avgDb;
    final double maxDb;
    final double minDb;
    final DateTime startedAt;
    final int sampleCount;

    if (state is MeasurementActive) {
      avgDb = state.avgDb;
      maxDb = state.maxDb;
      minDb = state.minDb;
      startedAt = state.startedAt;
      sampleCount = state.sampleCount;
    } else if (state is MeasurementPaused) {
      avgDb = state.avgDb;
      maxDb = state.maxDb;
      minDb = state.minDb;
      startedAt = state.startedAt;
      sampleCount = state.sampleCount;
    } else {
      return;
    }

    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveSessionSheet(
        avgDb: avgDb,
        maxDb: maxDb,
        minDb: minDb,
        startedAt: startedAt,
        sampleCount: sampleCount,
        dbSamples: dbSamples,
      ),
    ).then((saved) {
      notifier.reset();
    });
  }

  /// 마이크 권한 상태에 따라 본문 분기
  Widget _buildBody(
      MeasurementState measureState, MicPermissionState micPerm) {
    if (micPerm == MicPermissionState.unknown) {
      return _buildCenteredContent(
        child: const CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (micPerm == MicPermissionState.denied ||
        micPerm == MicPermissionState.permanentlyDenied) {
      return _buildPermissionDeniedUI(micPerm);
    }

    return _buildMeasurementUI(measureState);
  }

  /// 상단 패딩(상태바 + 앱바) 포함 중앙 정렬 래퍼
  Widget _buildCenteredContent({required Widget child}) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        Expanded(child: Center(child: child)),
      ],
    );
  }

  // ─── 마이크 권한 거부 안내 UI ───

  Widget _buildPermissionDeniedUI(MicPermissionState micPerm) {
    final isPermanent = micPerm == MicPermissionState.permanentlyDenied;

    return _buildCenteredContent(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_off_rounded,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.micAccessRequired,
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isPermanent
                  ? context.l10n.micPermDeniedPermanent
                  : context.l10n.micPermNeeded,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (isPermanent) {
                    await ref
                        .read(micPermissionProvider.notifier)
                        .openSettings();
                  } else {
                    await ref
                        .read(micPermissionProvider.notifier)
                        .request();
                  }
                },
                icon: Icon(
                  isPermanent ? Icons.settings_rounded : Icons.mic_rounded,
                ),
                label: Text(
                  isPermanent ? context.l10n.openSettings : context.l10n.allowMicrophone,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 측정 UI (Column: 고정 상단 + 스크롤 중단 + 고정 하단) ───

  Widget _buildMeasurementUI(MeasurementState measureState) {
    final isActive = measureState is MeasurementActive;
    final showDangerBanner = isActive &&
        measureState.currentDb >= AppConstants.dangerThresholdDb;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    final levelColor = _getLevelColor(measureState);

    return Column(
      children: [
        // SafeArea 상단 여백 (상태바 + 앱바 높이)
        SizedBox(height: topPadding),

        // 85dB 초과 경고 배너
        _buildDangerBanner(showDangerBanner),

        // ─── 고정 상단 영역 ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // 레벨 배지 (측정 중에만 표시 + danger pulse)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isActive ? 1.0 : 0.0,
                child: isActive
                    ? AnimatedScale(
                        scale: _badgeScale,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: LevelBadge(level: measureState.level),
                      )
                    : const SizedBox(height: 24),
              ),
              const SizedBox(height: 8),

              // dB 숫자 (큰 변화 시 색상 강조)
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _isDbHighlighted
                      ? AppColors.textPrimary
                      : Colors.transparent, // 실제 색상은 DbNumberDisplay가 관리
                ),
                child: DbNumberDisplay(
                  db: _getCurrentDb(measureState),
                  color: _isDbHighlighted
                      ? AppColors.textPrimary
                      : (isActive ? levelColor : AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 4),

              // 안전 노출 시간 텍스트
              _buildSafeExposureText(measureState),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ─── 스크롤 영역 ───
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // 반원 게이지
                DbGaugeWidget(
                  currentDb: _getCurrentDb(measureState),
                  peakDb: _getPeakDb(measureState),
                ),
                const SizedBox(height: 16),

                // MIN / AVG / MAX 카드
                _buildMinMaxRow(measureState),
                const SizedBox(height: 16),

                // Fast / Slow 토글
                _buildResponseModeToggle(),
                const SizedBox(height: 16),

                // 실시간 파형
                WaveformVisualizer(
                  currentDb: _getCurrentDb(measureState),
                  level: _getCurrentLevel(measureState),
                  isActive: isActive,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ─── 하단 고정 버튼 ───
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SafeArea(
            top: false,
            child: _buildBottomButtons(measureState),
          ),
        ),
      ],
    );
  }

  // ─── 안전 노출 시간 텍스트 ───

  Widget _buildSafeExposureText(MeasurementState state) {
    if (state is! MeasurementActive) {
      return const SizedBox(height: 20);
    }

    final db = state.currentDb;
    final text = _getSafeExposureText(db, context);
    final isSafe = db < AppConstants.dangerThresholdDb;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(isSafe),
        style: AppTextStyles.caption.copyWith(
          color: isSafe
              ? AppColors.levelQuiet.withValues(alpha: 0.8)
              : AppColors.levelDanger.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// WHO 기준 안전 노출 시간 계산
  String _getSafeExposureText(double db, BuildContext context) {
    if (db < 85) return context.l10n.safeForExtended;

    // WHO: 85dB=8h, 매 3dB 증가마다 시간 반감
    final hours = 8.0 / math.pow(2, (db - 85) / 3);
    if (hours >= 1) {
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      if (m > 0) {
        return '\u26A0\uFE0F ${context.l10n.safeExposure('${h}h ${m}m')}';
      }
      return '\u26A0\uFE0F ${context.l10n.safeExposure('${h}h')}';
    }
    final minutes = (hours * 60).round();
    if (minutes > 0) {
      return '\u26A0\uFE0F ${context.l10n.safeExposure('${minutes}m')}';
    }
    return '\u26A0\uFE0F ${context.l10n.immediateHearingRisk}';
  }

  // ─── Fast/Slow 토글 ───

  Widget _buildResponseModeToggle() {
    final notifier = ref.read(measurementProvider.notifier);
    final mode = notifier.responseMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeButton(
          label: context.l10n.responseFast,
          isSelected: mode == ResponseMode.fast,
          onTap: () {
            notifier.setResponseMode(ResponseMode.fast);
            setState(() {});
          },
        ),
        const SizedBox(width: 8),
        _buildModeButton(
          label: context.l10n.responseSlow,
          isSelected: mode == ResponseMode.slow,
          onTap: () {
            notifier.setResponseMode(ResponseMode.slow);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─── 하단 버튼 (Start/Stop + Info) ───

  Widget _buildBottomButtons(MeasurementState state) {
    final isActive = state is MeasurementActive;
    final levelColor = isActive ? _getFabLevelColor(state.level) : null;

    return Row(
      children: [
        // 메인 버튼 (flex) — 스케일 + 햅틱
        Expanded(
          child: Listener(
            onPointerDown: (_) => setState(() => _isButtonPressed = true),
            onPointerUp: (_) => setState(() => _isButtonPressed = false),
            onPointerCancel: (_) =>
                setState(() => _isButtonPressed = false),
            child: AnimatedScale(
              scale: _isButtonPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.medium();
                    if (isActive) {
                      _showSaveSheet(state);
                    } else {
                      ref.read(measurementProvider.notifier).start();
                    }
                  },
                  icon: Icon(
                    isActive ? Icons.stop_rounded : Icons.mic,
                    size: 22,
                  ),
                  label: Text(
                    isActive ? context.l10n.stopAndSave : context.l10n.startMeasuring,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isActive ? levelColor : AppColors.accent,
                    foregroundColor: isActive
                        ? AppColors.textPrimary
                        : AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                    shadowColor:
                        (isActive ? levelColor : AppColors.accent)
                            ?.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Info 버튼
        SizedBox(
          width: 56,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.push('/settings/noise-guide'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            child: const Icon(Icons.info_outline, size: 22),
          ),
        ),
      ],
    );
  }

  /// 측정 중 버튼 색상 — DbLevel → Color
  Color _getFabLevelColor(DbLevel level) {
    return switch (level) {
      DbLevel.silent || DbLevel.quiet => AppColors.levelQuiet,
      DbLevel.moderate => AppColors.levelModerate,
      DbLevel.loud => AppColors.levelLoud,
      DbLevel.danger => AppColors.levelDanger,
    };
  }

  /// 85dB 초과 경고 배너
  Widget _buildDangerBanner(bool visible) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, -1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: visible ? 1.0 : 0.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.levelDanger,
            boxShadow: [
              BoxShadow(
                color: AppColors.levelDanger.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\u26A0\uFE0F', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Hearing damage risk',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// MIN/AVG/MAX 카드
  Widget _buildMinMaxRow(MeasurementState state) {
    final hasData = state is MeasurementActive || state is MeasurementPaused;
    final minDb = _getMinDb(state);
    final maxDb = _getMaxDb(state);
    final avgDb = _getAvgDb(state);

    return Row(
      children: [
        _buildStatCard(
          label: context.l10n.minLabel,
          value: hasData ? minDb.toStringAsFixed(1) : '--',
          icon: Icons.arrow_downward_rounded,
          color: AppColors.levelSilent,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          label: context.l10n.avgLabel,
          value: hasData ? avgDb.toStringAsFixed(1) : '--',
          icon: Icons.horizontal_rule_rounded,
          color: AppColors.levelModerate,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          label: context.l10n.maxLabel,
          value: hasData ? maxDb.toStringAsFixed(1) : '--',
          icon: Icons.arrow_upward_rounded,
          color: AppColors.levelDanger,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 상태별 값 추출 헬퍼 ───

  double _getCurrentDb(MeasurementState state) {
    return switch (state) {
      MeasurementActive(:final currentDb) => currentDb,
      MeasurementPaused(:final lastDb) => lastDb,
      _ => 0.0,
    };
  }

  double _getPeakDb(MeasurementState state) {
    return switch (state) {
      MeasurementActive(:final peakDb) => peakDb,
      _ => 0.0,
    };
  }

  DbLevel _getCurrentLevel(MeasurementState state) {
    return switch (state) {
      MeasurementActive(:final level) => level,
      MeasurementPaused(:final level) => level,
      _ => DbLevel.silent,
    };
  }

  Color _getLevelColor(MeasurementState state) {
    return _getCurrentLevel(state).color;
  }

  double _getMinDb(MeasurementState state) {
    return switch (state) {
      MeasurementActive(:final minDb) => minDb,
      MeasurementPaused(:final minDb) => minDb,
      _ => 0.0,
    };
  }

  double _getMaxDb(MeasurementState state) {
    return switch (state) {
      MeasurementActive(:final maxDb) => maxDb,
      MeasurementPaused(:final maxDb) => maxDb,
      _ => 0.0,
    };
  }

  double _getAvgDb(MeasurementState state) {
    return switch (state) {
      MeasurementActive(:final avgDb) => avgDb,
      MeasurementPaused(:final avgDb) => avgDb,
      _ => 0.0,
    };
  }
}
