import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// 실시간 dB 파형 시각화 위젯
/// 오디오 이퀄라이저 스타일 — 가로로 흐르는 막대 파형
class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({
    super.key,
    required this.currentDb,
    required this.level,
    required this.isActive,
  });

  /// 현재 dB 값
  final double currentDb;

  /// 현재 소음 레벨
  final DbLevel level;

  /// 측정 활성 상태 (true: 측정 중, false: 중지/일시정지)
  final bool isActive;

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer> {
  /// 막대 개수
  static const _barCount = 36;

  /// dB 최대값 (높이 정규화 기준)
  static const _maxDb = 130.0;

  /// dB 최소 표시값 (이 이하는 최소 높이로 표시)
  static const _minDb = 10.0;

  /// dB 샘플 히스토리 (왼→오: 과거→현재)
  final List<double> _samples = [];

  /// 이전 활성 상태 (활성→비활성 전환 감지용)
  bool _wasActive = false;

  @override
  void initState() {
    super.initState();
    _wasActive = widget.isActive;
    if (widget.isActive) {
      _pushSample(widget.currentDb);
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 비활성→활성 전환: 샘플 초기화 후 새 값 추가
    if (widget.isActive && !_wasActive) {
      _samples.clear();
    }
    _wasActive = widget.isActive;

    // 활성 상태일 때만 새 샘플 추가
    if (widget.isActive) {
      _pushSample(widget.currentDb);
    }
  }

  /// 새 dB 값을 샘플 리스트에 추가 (최대 _barCount개 유지)
  void _pushSample(double db) {
    _samples.add(db.clamp(0, _maxDb));
    if (_samples.length > _barCount) {
      _samples.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: CustomPaint(
        painter: _WaveformPainter(
          samples: List.unmodifiable(_samples),
          barCount: _barCount,
          maxDb: _maxDb,
          minDb: _minDb,
          color: widget.level.color,
          isActive: widget.isActive,
        ),
      ),
    );
  }
}

/// 파형 CustomPainter — 막대 그래프 렌더링
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.samples,
    required this.barCount,
    required this.maxDb,
    required this.minDb,
    required this.color,
    required this.isActive,
  });

  final List<double> samples;
  final int barCount;
  final double maxDb;
  final double minDb;
  final Color color;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) {
      _paintIdle(canvas, size);
      return;
    }

    final totalWidth = size.width;
    final barWidth = totalWidth / barCount * 0.6;
    final gap = totalWidth / barCount * 0.4;
    final slotWidth = barWidth + gap;
    final maxHeight = size.height;
    final minBarHeight = 3.0;
    final centerY = size.height / 2;

    // 오른쪽 정렬: 마지막 샘플이 오른쪽 끝에 위치
    final startOffset = totalWidth - samples.length * slotWidth;

    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < samples.length; i++) {
      final db = samples[i];
      // dB를 0~1 비율로 정규화
      final normalized = ((db - minDb) / (maxDb - minDb)).clamp(0.0, 1.0);
      // 높이 계산 (최소 높이 보장)
      final barHeight =
          math.max(minBarHeight, normalized * maxHeight * 0.9);
      final halfHeight = barHeight / 2;

      // 위치 계산
      final x = startOffset + i * slotWidth;

      // 비활성 상태: 투명도 낮춤
      final opacity = isActive ? _opacityForIndex(i) : 0.4;
      paint.color = color.withValues(alpha: opacity);

      // 둥근 막대 렌더링 (중앙 기준 위아래 대칭)
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(x, centerY - halfHeight, x + barWidth, centerY + halfHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  /// 샘플 없을 때 — 최소 높이의 idle 막대 표시
  void _paintIdle(Canvas canvas, Size size) {
    final totalWidth = size.width;
    final barWidth = totalWidth / barCount * 0.6;
    final gap = totalWidth / barCount * 0.4;
    final slotWidth = barWidth + gap;
    final centerY = size.height / 2;
    final idleHeight = 3.0;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.surfaceLight;

    for (var i = 0; i < barCount; i++) {
      final x = i * slotWidth;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          x,
          centerY - idleHeight / 2,
          x + barWidth,
          centerY + idleHeight / 2,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  /// 인덱스별 투명도 — 최신(오른쪽)이 가장 밝고 오래된(왼쪽)이 어두움
  double _opacityForIndex(int index) {
    if (samples.isEmpty) return 0.3;
    // 0.3 ~ 1.0 범위로 페이드
    final ratio = index / (samples.length - 1).clamp(1, samples.length);
    return 0.3 + ratio * 0.7;
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.color != color ||
        oldDelegate.isActive != isActive;
  }
}
