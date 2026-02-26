import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:soundsense/core/permissions/location_permission.dart';
import 'package:soundsense/core/permissions/microphone_permission.dart';
import 'package:soundsense/features/measurement/providers/measurement_provider.dart';
import 'package:soundsense/shared/constants/app_constants.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

// ─── 서울 시청 Mock 좌표 ───
const double kWebMockLatitude = 37.5665;
const double kWebMockLongitude = 126.9780;

// ══════════════════════════════════════════════════════════════════
// 1. WebMeasurementNotifier — Timer 기반 dB 시뮬레이션
//    extends MeasurementNotifier → overrideWith 타입 호환
// ══════════════════════════════════════════════════════════════════

class WebMeasurementNotifier extends MeasurementNotifier {
  Timer? _webTimer;
  final _rng = math.Random();

  // 시뮬레이션 파라미터
  double _phase = 0;
  double _walkOffset = 0;

  @override
  Future<void> start() async {
    if (state is MeasurementActive) return;

    final resumeFrom =
        state is MeasurementPaused ? state as MeasurementPaused : null;

    _webTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final db = (_simulateDb() + calibrationOffset).clamp(0.0, 130.0);

      final current = state;
      if (current is MeasurementActive) {
        final next = current.copyWithSample(db);
        state = next;
        if (next.isDangerAlert) HapticFeedback.heavyImpact();
      } else if (resumeFrom != null && current is! MeasurementActive) {
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
        state = MeasurementActive(
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
      }
    });
  }

  @override
  void pause() {
    _webTimer?.cancel();
    _webTimer = null;
    super.pause(); // Active → Paused 상태 전환
  }

  @override
  void reset() {
    _webTimer?.cancel();
    _webTimer = null;
    _phase = 0;
    _walkOffset = 0;
    super.reset(); // → MeasurementIdle
  }

  /// 시뮬레이션: 기본 45dB + sine 오실레이션 + random walk + 스파이크
  double _simulateDb() {
    _phase += 0.15;
    _walkOffset += (_rng.nextDouble() - 0.5) * 2.0;
    _walkOffset = _walkOffset.clamp(-10.0, 10.0);

    double db = 45.0 + 15.0 * math.sin(_phase) + _walkOffset;

    // 5% 확률 스파이크 (80~95 dB)
    if (_rng.nextDouble() < 0.05) {
      db = 80.0 + _rng.nextDouble() * 15.0;
    }

    return db.clamp(20.0, 110.0);
  }

  @override
  void dispose() {
    _webTimer?.cancel();
    super.dispose();
  }
}

// ══════════════════════════════════════════════════════════════════
// 2. WebMicPermissionNotifier — 즉시 granted
// ══════════════════════════════════════════════════════════════════

class WebMicPermissionNotifier extends MicPermissionNotifier {
  WebMicPermissionNotifier() {
    state = MicPermissionState.granted;
  }

  @override
  Future<void> check() async {
    state = MicPermissionState.granted;
  }

  @override
  Future<MicPermissionState> request() async {
    state = MicPermissionState.granted;
    return state;
  }
}

// ══════════════════════════════════════════════════════════════════
// 3. WebLocationPermissionNotifier — 즉시 granted
// ══════════════════════════════════════════════════════════════════

class WebLocationPermissionNotifier extends LocationPermissionNotifier {
  WebLocationPermissionNotifier() {
    state = LocationPermissionState.granted;
  }

  @override
  Future<void> check() async {
    state = LocationPermissionState.granted;
  }

  @override
  Future<LocationPermissionState> request() async {
    state = LocationPermissionState.granted;
    return state;
  }
}
