import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:soundsense/features/settings/screens/noise_guide_screen.dart';
import 'package:soundsense/shared/constants/app_constants.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// 측정 화면 — 기획서 화면 1
/// 실시간 dB 측정 + 게이지 + 레벨 뱃지 + 시작/정지 버튼
class MeasurementScreen extends ConsumerStatefulWidget {
  const MeasurementScreen({super.key});

  @override
  ConsumerState<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends ConsumerState<MeasurementScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 마이크 권한 상태 확인
    Future.microtask(() {
      ref.read(micPermissionProvider.notifier).check();
    });

    // 측정 상태 변화 시 WakeLock 토글
    ref.listenManual(measurementProvider, (previous, next) {
      if (next is MeasurementActive) {
        WakelockPlus.enable();
      } else if (previous is MeasurementActive) {
        // Active → 다른 상태 (Paused/Idle/Error) 전환 시 해제
        WakelockPlus.disable();
      }
    });
  }

  @override
  void dispose() {
    // 화면 이탈 시 반드시 WakeLock 해제
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measureState = ref.watch(measurementProvider);
    final micPermission = ref.watch(micPermissionProvider);

    // 현재 레벨 색상 (배경 연동용)
    final levelColor = _getLevelColor(measureState);

    return Scaffold(
      // ─── 앱바: SoundSense + 저장 버튼 ───
      appBar: AppBar(
        title: const Text('SoundSense'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const [],
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
        child: SafeArea(
          child: _buildBody(measureState, micPermission),
        ),
      ),
    );
  }

  /// 세션 저장 바텀시트 표시 — 측정 일시정지 후 시트 열기
  void _showSaveSheet(MeasurementState state) {
    // 측정 중이면 먼저 일시정지
    final notifier = ref.read(measurementProvider.notifier);
    if (state is MeasurementActive) {
      notifier.pause();
    }

    // 현재 상태에서 데이터 추출
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
      ),
    ).then((saved) {
      // 저장 완료 또는 저장 안 함 → 측정 초기화
      notifier.reset();
    });
  }

  /// 마이크 권한 상태에 따라 본문 분기
  Widget _buildBody(MeasurementState measureState, MicPermissionState micPerm) {
    // 권한 미확인 상태 — 로딩
    if (micPerm == MicPermissionState.unknown) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // 권한 거부 / 영구 거부 → 안내 UI
    if (micPerm == MicPermissionState.denied ||
        micPerm == MicPermissionState.permanentlyDenied) {
      return _buildPermissionDeniedUI(micPerm);
    }

    // 권한 허용 → 측정 UI
    return _buildMeasurementUI(measureState);
  }

  // ─── 마이크 권한 거부 안내 UI ───

  Widget _buildPermissionDeniedUI(MicPermissionState micPerm) {
    final isPermanent = micPerm == MicPermissionState.permanentlyDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 마이크 아이콘
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
            // 제목
            Text(
              'Microphone Access Required',
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 설명
            Text(
              isPermanent
                  ? 'Microphone access was permanently denied.\nPlease enable it in your device settings.'
                  : 'SoundSense needs microphone access\nto measure noise levels.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (isPermanent) {
                    // 설정 앱 열기
                    await ref.read(micPermissionProvider.notifier).openSettings();
                  } else {
                    // 권한 재요청
                    await ref.read(micPermissionProvider.notifier).request();
                  }
                },
                icon: Icon(
                  isPermanent ? Icons.settings_rounded : Icons.mic_rounded,
                ),
                label: Text(
                  isPermanent ? 'Open Settings' : 'Allow Microphone',
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

  // ─── 측정 UI ───

  Widget _buildMeasurementUI(MeasurementState measureState) {
    // 85dB 경고 배너 표시 여부
    final showDangerBanner = measureState is MeasurementActive &&
        measureState.currentDb >= AppConstants.dangerThresholdDb;

    return Column(
      children: [
        // ─── 85dB 초과 경고 배너 ───
        _buildDangerBanner(showDangerBanner),

        // ─── 스크롤 가능 영역 (게이지 + 수치) ───
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ─── 레벨 뱃지 ───
                LevelBadge(
                  level: _getCurrentLevel(measureState),
                ),
                const SizedBox(height: 24),

                // ─── dB 숫자 디스플레이 ───
                DbNumberDisplay(
                  db: _getCurrentDb(measureState),
                  color: _getLevelColor(measureState),
                ),
                const SizedBox(height: 16),

                // ─── 반원 게이지 ───
                DbGaugeWidget(
                  currentDb: _getCurrentDb(measureState),
                ),
                const SizedBox(height: 24),

                // ─── 최소/최대 dB 카드 ───
                _buildMinMaxRow(measureState),
                const SizedBox(height: 16),

                // ─── 실시간 파형 ───
                WaveformVisualizer(
                  currentDb: _getCurrentDb(measureState),
                  level: _getCurrentLevel(measureState),
                  isActive: measureState is MeasurementActive,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ─── 하단 고정 영역 (스크롤 밖) ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── 시작/정지 버튼 ───
              _buildControlButton(measureState),
              const SizedBox(height: 8),

              // ─── 리셋 버튼 (측정 중/일시정지일 때만) ───
              if (measureState is MeasurementActive ||
                  measureState is MeasurementPaused)
                TextButton(
                  onPressed: () {
                    ref.read(measurementProvider.notifier).reset();
                  },
                  child: Text(
                    'Reset',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

              // ─── 하단 컨텍스트 팁 ───
              _buildContextTip(measureState),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  /// 85dB 초과 경고 배너 — 슬라이드 인/아웃 애니메이션
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
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Hearing damage risk · 청력 주의 구간',
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

  /// 최소/최대 dB 표시 카드
  Widget _buildMinMaxRow(MeasurementState state) {
    final hasData = state is MeasurementActive || state is MeasurementPaused;
    final minDb = _getMinDb(state);
    final maxDb = _getMaxDb(state);
    final avgDb = _getAvgDb(state);

    return Row(
      children: [
        _buildStatCard(
          label: 'MIN',
          value: hasData ? minDb.toStringAsFixed(1) : '--',
          icon: Icons.arrow_downward_rounded,
          color: AppColors.levelSilent,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          label: 'AVG',
          value: hasData ? avgDb.toStringAsFixed(1) : '--',
          icon: Icons.horizontal_rule_rounded,
          color: AppColors.levelModerate,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          label: 'MAX',
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

  /// 측정 시작/정지 버튼
  Widget _buildControlButton(MeasurementState state) {
    final isActive = state is MeasurementActive;
    final isIdle = state is MeasurementIdle;
    final isError = state is MeasurementError;

    return SizedBox(
      width: 200,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          if (isActive) {
            // Stop 탭 → 자동으로 저장 바텀시트 등장
            _showSaveSheet(state);
          } else {
            ref.read(measurementProvider.notifier).start();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppColors.error : AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: isActive ? 8 : 4,
          shadowColor: isActive
              ? AppColors.error.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive
                  ? Icons.stop_rounded
                  : Icons.mic_rounded,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isActive
                  ? 'Stop'
                  : (isIdle || isError)
                      ? 'Start'
                      : 'Resume',
              style: AppTextStyles.levelLabel.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하단 컨텍스트 팁 — 레벨별 다른 텍스트
  Widget _buildContextTip(MeasurementState state) {
    final tip = _getTipText(state);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        key: ValueKey(tip),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NoiseGuideScreen()),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: _getLevelColor(state).withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
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

  /// 레벨별 컨텍스트 팁 텍스트
  String _getTipText(MeasurementState state) {
    if (state is MeasurementIdle) {
      return 'Tap Start to begin measuring noise levels around you.';
    }
    if (state is MeasurementError) {
      return 'An error occurred. Please try again.';
    }

    final level = _getCurrentLevel(state);
    return switch (level) {
      DbLevel.silent => 'Very quiet environment. Like a library or empty room.',
      DbLevel.quiet => 'Normal conversation level. Comfortable for most activities.',
      DbLevel.moderate => 'Getting noisy. Similar to a busy restaurant.',
      DbLevel.loud => 'Loud environment! Prolonged exposure may cause discomfort.',
      DbLevel.danger =>
        'Dangerous noise level! Prolonged exposure may damage hearing.',
    };
  }
}
