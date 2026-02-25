import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// 리플 애니메이션 마커 위젯
/// CLAUDE.md 지도 마커 스펙 준수:
/// - 원이 중심에서 바깥으로 퍼져나가는 파동 애니메이션
/// - 동시에 3개 원이 시차를 두고 퍼짐
/// - 중심점은 항상 채워진 원으로 고정
/// - 크기/색상/속도 모두 dB 연동
class NoiseMapMarker extends StatefulWidget {
  const NoiseMapMarker({
    super.key,
    required this.avgDb,
    required this.level,
  });

  final double avgDb;
  final DbLevel level;

  @override
  State<NoiseMapMarker> createState() => _NoiseMapMarkerState();
}

class _NoiseMapMarkerState extends State<NoiseMapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration(widget.avgDb),
    )..repeat();
  }

  @override
  void didUpdateWidget(NoiseMapMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avgDb != widget.avgDb) {
      _controller.duration = _animationDuration(widget.avgDb);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 애니메이션 속도 — dB 연동 선형 보간
  /// 40dB 이하 → 3초, 100dB 이상 → 1초
  Duration _animationDuration(double db) {
    final clamped = db.clamp(40.0, 100.0);
    final t = (clamped - 40.0) / 60.0; // 0.0 ~ 1.0
    final seconds = 3.0 - (t * 2.0); // 3.0 → 1.0
    return Duration(milliseconds: (seconds * 1000).round());
  }

  @override
  Widget build(BuildContext context) {
    final maxRadius = _maxRadius(widget.avgDb);
    final size = maxRadius * 2;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size(size, size),
            painter: _RipplePainter(
              progress: _controller.value,
              color: widget.level.color,
              maxRadius: maxRadius,
            ),
          );
        },
      ),
    );
  }

  /// 최대 반지름 — dB 연동 선형 보간
  /// 40dB 이하 → 30, 100dB 이상 → 80
  double _maxRadius(double db) {
    final clamped = db.clamp(40.0, 100.0);
    final t = (clamped - 40.0) / 60.0;
    return 30.0 + (t * 50.0); // 30 → 80
  }
}

/// 리플 CustomPainter
/// 3개 원이 시차(0.0, 0.33, 0.66)를 두고 동시에 퍼짐
class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.progress,
    required this.color,
    required this.maxRadius,
  });

  final double progress;
  final Color color;
  final double maxRadius;

  /// 리플 원 개수
  static const _rippleCount = 3;

  /// 중심 원 반지름
  static const _centerRadius = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ─── 리플 원 3개 (시차 그리기) ───
    for (var i = 0; i < _rippleCount; i++) {
      final offset = i / _rippleCount; // 0.0, 0.33, 0.66
      final rippleProgress = (progress + offset) % 1.0;

      // 반지름: 중심에서 최대까지
      final radius =
          _centerRadius + (maxRadius - _centerRadius) * rippleProgress;

      // 투명도: 퍼질수록 0으로 소멸
      final opacity = (1.0 - rippleProgress).clamp(0.0, 1.0) * 0.5;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, 3.0 * (1.0 - rippleProgress));

      canvas.drawCircle(center, radius, paint);
    }

    // ─── 중심 원 (고정, 불투명) ───
    // 외곽 글로우
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, _centerRadius + 3, glowPaint);

    // 메인 원
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, _centerRadius, centerPaint);

    // 밝은 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - 1.5, center.dy - 1.5),
      _centerRadius * 0.35,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.maxRadius != maxRadius;
  }
}

/// 위젯을 Google Maps BitmapDescriptor로 변환
/// [markerKey] — 위젯을 식별하는 GlobalKey
/// 실제 사용: 정적 스냅샷 (애니메이션 없는 상태)
Future<BitmapDescriptor> widgetToMarkerBitmap({
  required double avgDb,
  required DbLevel level,
  double devicePixelRatio = 2.0,
}) async {
  final maxRadius = _maxRadiusStatic(avgDb);
  final size = maxRadius * 2;

  // PictureRecorder로 정적 마커 그리기
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paintSize = Size(size, size);

  _StaticMarkerPainter(
    color: level.color,
    maxRadius: maxRadius,
  ).paint(canvas, paintSize);

  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (size * devicePixelRatio).ceil(),
    (size * devicePixelRatio).ceil(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  if (byteData == null) {
    return BitmapDescriptor.defaultMarker;
  }

  return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
}

/// 정적 마커 반지름 계산 (widgetToMarkerBitmap용)
double _maxRadiusStatic(double db) {
  final clamped = db.clamp(40.0, 100.0);
  final t = (clamped - 40.0) / 60.0;
  return 30.0 + (t * 50.0);
}

/// 정적 마커 Painter — BitmapDescriptor 변환용
/// 리플 없이 중심원 + 외곽 링 1개만 그림
class _StaticMarkerPainter extends CustomPainter {
  _StaticMarkerPainter({
    required this.color,
    required this.maxRadius,
  });

  final Color color;
  final double maxRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 외곽 링 (최대 반지름의 60%)
    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, maxRadius * 0.6, outerPaint);

    // 중간 링
    final midPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, maxRadius * 0.35, midPaint);

    // 글로우
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 9, glowPaint);

    // 중심 원
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);

    // 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - 1.5, center.dy - 1.5),
      2.0,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StaticMarkerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.maxRadius != maxRadius;
  }
}
