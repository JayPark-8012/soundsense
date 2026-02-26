import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:soundsense/core/theme/app_colors.dart';

/// 반원형 dB 게이지 위젯
/// 0~120 dB 범위, 레벨 색상 아크 + 바늘 + 피크 홀드 바늘 + 글로우 효과
class DbGaugeWidget extends StatefulWidget {
  const DbGaugeWidget({
    super.key,
    required this.currentDb,
    this.peakDb = 0,
    this.maxDb = 120.0,
  });

  final double currentDb;
  final double peakDb;
  final double maxDb;

  @override
  State<DbGaugeWidget> createState() => _DbGaugeWidgetState();
}

class _DbGaugeWidgetState extends State<DbGaugeWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _dbAnimation;
  double _previousDb = 0;

  // 피크 홀드 애니메이션
  late final AnimationController _peakController;
  double _displayPeak = 0;
  double _peakDecayFrom = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dbAnimation = AlwaysStoppedAnimation(widget.currentDb);

    _peakController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _peakController.addListener(() {
      // 피크에서 현재값으로 서서히 decay
      _displayPeak = _peakDecayFrom +
          (widget.currentDb - _peakDecayFrom) * _peakController.value;
    });
  }

  @override
  void didUpdateWidget(DbGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // dB 바늘 애니메이션
    if (oldWidget.currentDb != widget.currentDb) {
      _previousDb = oldWidget.currentDb;
      _dbAnimation = Tween<double>(
        begin: _previousDb,
        end: widget.currentDb,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ));
      _controller.forward(from: 0);
    }

    // 피크 홀드: 새 피크 감지 시 리셋 후 decay 시작
    if (widget.peakDb > _displayPeak) {
      _displayPeak = widget.peakDb;
      _peakDecayFrom = widget.peakDb;
      _peakController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _peakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _peakController]),
      builder: (context, child) {
        return CustomPaint(
          size: const Size(280, 160),
          painter: _GaugePainter(
            currentDb: _dbAnimation.value,
            peakDb: _displayPeak,
            maxDb: widget.maxDb,
            levelColor: AppColors.levelColor(_dbAnimation.value),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.currentDb,
    required this.peakDb,
    required this.maxDb,
    required this.levelColor,
  });

  final double currentDb;
  final double peakDb;
  final double maxDb;
  final Color levelColor;

  // 게이지 각도 범위: 180도 (좌 → 우 반원)
  static const _startAngle = math.pi; // 180° (왼쪽)
  static const _sweepAngle = math.pi; // 180° 전체
  static const _trackWidth = 12.0;
  static const _arcWidth = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = size.width / 2 - 20;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final db = currentDb.clamp(0.0, maxDb);
    final ratio = db / maxDb;

    // ─── 1. 글로우 효과 (현재 레벨 색상) ───
    final glowPaint = Paint()
      ..color = levelColor.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawArc(rect, _startAngle, _sweepAngle * ratio, false, glowPaint);

    // ─── 2. 배경 트랙 ───
    final trackPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = _trackWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, _sweepAngle, false, trackPaint);

    // ─── 3. 채워지는 아크 (레벨 색상) ───
    if (ratio > 0) {
      final arcPaint = Paint()
        ..shader = SweepGradient(
          startAngle: _startAngle,
          endAngle: _startAngle + _sweepAngle,
          colors: [
            AppColors.levelSilent,
            AppColors.levelQuiet,
            AppColors.levelModerate,
            AppColors.levelLoud,
            AppColors.levelDanger,
          ],
          stops: const [0.0, 0.25, 0.5, 0.7, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _arcWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
          rect, _startAngle, _sweepAngle * ratio, false, arcPaint);
    }

    // ─── 4. 눈금 마크 (0, 30, 60, 90, 120) ───
    final tickPaint = Paint()
      ..color = AppColors.textTertiary
      ..strokeWidth = 1.5;

    for (var i = 0; i <= 4; i++) {
      final tickRatio = i / 4;
      final angle = _startAngle + _sweepAngle * tickRatio;
      final outerPoint = Offset(
        center.dx + (radius + 8) * math.cos(angle),
        center.dy + (radius + 8) * math.sin(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 16) * math.cos(angle),
        center.dy + (radius - 16) * math.sin(angle),
      );
      canvas.drawLine(innerPoint, outerPoint, tickPaint);

      // 눈금 숫자
      final tickDb = (maxDb * tickRatio).round().toString();
      final textPainter = TextPainter(
        text: TextSpan(
          text: tickDb,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelOffset = Offset(
        center.dx +
            (radius + 20) * math.cos(angle) -
            textPainter.width / 2,
        center.dy +
            (radius + 20) * math.sin(angle) -
            textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }

    // ─── 5. 피크 홀드 바늘 (얇은 빨간 선) ───
    final peakClamped = peakDb.clamp(0.0, maxDb);
    if (peakClamped > 0) {
      final peakRatio = peakClamped / maxDb;
      final peakAngle = _startAngle + _sweepAngle * peakRatio;
      final peakLength = radius - 24;
      final peakTip = Offset(
        center.dx + peakLength * math.cos(peakAngle),
        center.dy + peakLength * math.sin(peakAngle),
      );
      final peakPaint = Paint()
        ..color = AppColors.levelDanger.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, peakTip, peakPaint);
    }

    // ─── 6. 메인 바늘 ───
    final needleAngle = _startAngle + _sweepAngle * ratio;
    final needleLength = radius - 24;

    // 바늘 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final shadowTip = Offset(
      center.dx + needleLength * math.cos(needleAngle) + 1,
      center.dy + needleLength * math.sin(needleAngle) + 1,
    );
    canvas.drawLine(center, shadowTip, shadowPaint);

    // 바늘 본체
    final needlePaint = Paint()
      ..color = levelColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    canvas.drawLine(center, needleTip, needlePaint);

    // 중심 원
    canvas.drawCircle(
      center,
      6,
      Paint()..color = levelColor,
    );
    canvas.drawCircle(
      center,
      3,
      Paint()..color = AppColors.background,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.currentDb != currentDb ||
      oldDelegate.peakDb != peakDb ||
      oldDelegate.levelColor != levelColor;
}
