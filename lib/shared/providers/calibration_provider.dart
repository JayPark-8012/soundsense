import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kCalibrationOffset = 'calibration_offset';

/// 기기 캘리브레이션 오프셋 (-10.0 ~ +10.0 dB)
final calibrationOffsetProvider =
    NotifierProvider<CalibrationNotifier, double>(() {
  return CalibrationNotifier();
});

class CalibrationNotifier extends Notifier<double> {
  @override
  double build() {
    _load();
    return 0.0;
  }

  /// SharedPreferences에서 값 로드
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getDouble(_kCalibrationOffset);
      if (value != null) {
        state = value.clamp(-10.0, 10.0);
      }
    } catch (e) {
      debugPrint('⚠️ 캘리브레이션 로드 실패: $e');
    }
  }

  /// 오프셋 설정 — 범위 클램핑 + SharedPreferences 저장
  Future<void> setOffset(double value) async {
    state = value.clamp(-10.0, 10.0);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kCalibrationOffset, state);
    } catch (e) {
      debugPrint('⚠️ 캘리브레이션 저장 실패: $e');
    }
  }
}
