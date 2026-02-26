import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:soundsense/shared/constants/app_constants.dart';
import 'package:soundsense/shared/constants/db_levels.dart';
import 'package:soundsense/shared/providers/calibration_provider.dart';

// ─── 응답 속도 모드 ───

enum ResponseMode {
  fast, // 200ms 간격
  slow, // 500ms 간격 + 이동평균 강화
}

// ─── 상태 정의 ───

/// 측정 상태 (sealed class)
sealed class MeasurementState {
  const MeasurementState();
}

/// 대기 상태 — 측정 전 또는 초기화 후
class MeasurementIdle extends MeasurementState {
  const MeasurementIdle();
}

/// 측정 중 상태 — 실시간 dB 데이터 포함
class MeasurementActive extends MeasurementState {
  const MeasurementActive({
    required this.currentDb,
    required this.minDb,
    required this.maxDb,
    required this.avgDb,
    required this.peakDb,
    required this.level,
    required this.startedAt,
    required this.sampleCount,
    required this.isDangerAlert,
  });

  final double currentDb;
  final double minDb;
  final double maxDb;
  final double avgDb;
  final double peakDb;
  final DbLevel level;
  final DateTime startedAt;
  final int sampleCount;
  final bool isDangerAlert; // 85dB 초과 여부

  /// 새 샘플로 상태 갱신
  MeasurementActive copyWithSample(double newDb) {
    final newMin = math.min(minDb, newDb);
    final newMax = math.max(maxDb, newDb);
    final newCount = sampleCount + 1;
    // 누적 이동 평균 계산
    final newAvg = avgDb + (newDb - avgDb) / newCount;
    final newPeak = math.max(peakDb, newDb);

    return MeasurementActive(
      currentDb: newDb,
      minDb: newMin,
      maxDb: newMax,
      avgDb: newAvg,
      peakDb: newPeak,
      level: DbLevel.fromDb(newDb),
      startedAt: startedAt,
      sampleCount: newCount,
      isDangerAlert: newDb >= AppConstants.dangerThresholdDb,
    );
  }
}

/// 일시정지 상태 — 마지막 측정값 보존
class MeasurementPaused extends MeasurementState {
  const MeasurementPaused({
    required this.lastDb,
    required this.minDb,
    required this.maxDb,
    required this.avgDb,
    required this.level,
    required this.startedAt,
    required this.sampleCount,
  });

  final double lastDb;
  final double minDb;
  final double maxDb;
  final double avgDb;
  final DbLevel level;
  final DateTime startedAt;
  final int sampleCount;
}

/// 에러 상태
class MeasurementError extends MeasurementState {
  const MeasurementError({required this.message});
  final String message;
}

// ─── Provider ───

final measurementProvider =
    StateNotifierProvider<MeasurementNotifier, MeasurementState>(
  (ref) {
    final notifier = MeasurementNotifier();
    // 캘리브레이션 오프셋 동기화
    ref.listen<double>(calibrationOffsetProvider, (_, next) {
      notifier.calibrationOffset = next;
    }, fireImmediately: true);
    return notifier;
  },
);

// ─── Notifier ───

class MeasurementNotifier extends StateNotifier<MeasurementState> {
  MeasurementNotifier() : super(const MeasurementIdle());

  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _subscription;

  /// 캘리브레이션 오프셋 (dB) — Provider에서 주입
  double calibrationOffset = 0.0;

  /// 응답 속도 모드
  ResponseMode _responseMode = ResponseMode.fast;
  ResponseMode get responseMode => _responseMode;

  // Slow 모드용 이동평균 버퍼
  final List<double> _slowBuffer = [];
  static const _slowBufferSize = 5;
  Timer? _slowTimer;

  /// 응답 속도 모드 전환
  void setResponseMode(ResponseMode mode) {
    _responseMode = mode;
    _slowBuffer.clear();
    _slowTimer?.cancel();
    _slowTimer = null;
  }

  /// 측정 시작
  Future<void> start() async {
    // 이미 측정 중이면 무시
    if (state is MeasurementActive) return;

    try {
      // 일시정지 상태에서 재개하는 경우
      final resumeState = state is MeasurementPaused
          ? state as MeasurementPaused
          : null;

      _subscription = _noiseMeter.noise.listen(
        (NoiseReading reading) {
          _onData(reading, resumeState);
        },
        onError: (Object error) {
          state = MeasurementError(message: error.toString());
          _subscription?.cancel();
          _subscription = null;
        },
      );
    } catch (e) {
      state = MeasurementError(message: e.toString());
    }
  }

  /// 측정 정지 (일시정지 — 데이터 보존)
  void pause() {
    _subscription?.cancel();
    _subscription = null;
    _slowTimer?.cancel();
    _slowTimer = null;
    _slowBuffer.clear();

    final current = state;
    if (current is MeasurementActive) {
      state = MeasurementPaused(
        lastDb: current.currentDb,
        minDb: current.minDb,
        maxDb: current.maxDb,
        avgDb: current.avgDb,
        level: current.level,
        startedAt: current.startedAt,
        sampleCount: current.sampleCount,
      );
    }
  }

  /// 초기화 — idle 상태로 복귀
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _slowTimer?.cancel();
    _slowTimer = null;
    _slowBuffer.clear();
    state = const MeasurementIdle();
  }

  /// 마이크 스트림 데이터 수신 콜백
  void _onData(NoiseReading reading, MeasurementPaused? resumeFrom) {
    // dB 값 + 캘리브레이션 오프셋 적용 후 클램핑
    final rawDb = (reading.meanDecibel + calibrationOffset).clamp(0.0, 130.0);

    if (_responseMode == ResponseMode.slow) {
      // Slow 모드: 버퍼에 쌓고 이동평균 적용
      _slowBuffer.add(rawDb);
      if (_slowBuffer.length > _slowBufferSize) {
        _slowBuffer.removeAt(0);
      }
      final db = _slowBuffer.reduce((a, b) => a + b) / _slowBuffer.length;
      _applyDb(db, resumeFrom);
    } else {
      // Fast 모드: 즉시 적용
      _applyDb(rawDb, resumeFrom);
    }
  }

  /// dB 값을 상태에 반영
  void _applyDb(double db, MeasurementPaused? resumeFrom) {
    final current = state;

    if (current is MeasurementActive) {
      // 기존 측정 중 → 샘플 추가
      final next = current.copyWithSample(db);
      state = next;
      _checkDangerAlert(next);
    } else if (resumeFrom != null && current is! MeasurementActive) {
      // 일시정지에서 재개 → 이전 데이터 이어서
      state = MeasurementActive(
        currentDb: db,
        minDb: math.min(resumeFrom.minDb, db),
        maxDb: math.max(resumeFrom.maxDb, db),
        avgDb: resumeFrom.avgDb +
            (db - resumeFrom.avgDb) / (resumeFrom.sampleCount + 1),
        peakDb: db,
        level: DbLevel.fromDb(db),
        startedAt: resumeFrom.startedAt,
        sampleCount: resumeFrom.sampleCount + 1,
        isDangerAlert: db >= AppConstants.dangerThresholdDb,
      );
    } else {
      // 최초 시작 → 새 세션
      final active = MeasurementActive(
        currentDb: db,
        minDb: db,
        maxDb: db,
        avgDb: db,
        peakDb: db,
        level: DbLevel.fromDb(db),
        startedAt: DateTime.now(),
        sampleCount: 1,
        isDangerAlert: db >= AppConstants.dangerThresholdDb,
      );
      state = active;
      _checkDangerAlert(active);
    }
  }

  /// 85dB 초과 시 햅틱 진동
  void _checkDangerAlert(MeasurementActive active) {
    if (active.isDangerAlert) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _slowTimer?.cancel();
    super.dispose();
  }
}
