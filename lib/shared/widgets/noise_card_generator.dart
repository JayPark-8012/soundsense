import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// Noise Card 이미지 생성기 — 1080×1080 SNS 정사각형 카드
/// Canvas + PictureRecorder로 오프스크린 렌더링
class NoiseCardGenerator {
  NoiseCardGenerator._();

  static const double _size = 1080;
  static const double _pad = 60;

  /// 카드 이미지를 PNG Uint8List로 생성
  static Future<Uint8List> generate(
    MeasurementSession session, {
    required bool isPremium,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, _size, _size),
    );

    final level = DbLevel.fromDb(session.avgDb);
    final dt = session.startedAt;

    // ─── 배경 그라데이션 (레벨 색상 → 다크) ───
    _drawBackground(canvas, level.color);

    // ─── 브랜드 (상단 좌측) ───
    _drawText(
      canvas,
      'SoundSense',
      x: _pad,
      y: 70,
      fontSize: 30,
      color: Colors.white.withValues(alpha: 0.6),
      fontWeight: FontWeight.w700,
    );

    // ─── 평균 dB (크게, 중앙) ───
    _drawText(
      canvas,
      session.avgDb.toStringAsFixed(1),
      y: 300,
      fontSize: 200,
      color: Colors.white,
      fontWeight: FontWeight.w800,
      center: true,
    );

    // ─── 단위 ───
    _drawText(
      canvas,
      'dB',
      y: 500,
      fontSize: 48,
      color: Colors.white.withValues(alpha: 0.6),
      fontWeight: FontWeight.w500,
      center: true,
    );

    // ─── 레벨 인디케이터 (● + 텍스트) ───
    _drawLevelIndicator(canvas, level, y: 590);

    // ─── 정보 섹션 (동적 Y) ───
    double infoY = 700;

    // 장소 (있을 때만)
    if (session.locationName != null) {
      _drawText(
        canvas,
        '\u{1F4CD} ${session.locationName}',
        y: infoY,
        fontSize: 26,
        color: Colors.white.withValues(alpha: 0.7),
        center: true,
      );
      infoY += 50;
    }

    // 날짜/시간
    final dateStr =
        '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}'
        '  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    _drawText(
      canvas,
      dateStr,
      y: infoY,
      fontSize: 26,
      color: Colors.white.withValues(alpha: 0.7),
      center: true,
    );
    infoY += 50;

    // 측정 시간
    final minutes = session.durationSec ~/ 60;
    final seconds = session.durationSec % 60;
    final durStr = minutes > 0
        ? 'Duration: ${minutes}m ${seconds}s'
        : 'Duration: ${seconds}s';
    _drawText(
      canvas,
      durStr,
      y: infoY,
      fontSize: 26,
      color: Colors.white.withValues(alpha: 0.7),
      center: true,
    );

    // ─── 구분선 ───
    canvas.drawLine(
      const Offset(_pad, 880),
      const Offset(_size - _pad, 880),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = 1,
    );

    // ─── 면책 문구 ───
    _drawText(
      canvas,
      'For reference only.',
      y: 910,
      fontSize: 18,
      color: Colors.white.withValues(alpha: 0.35),
      center: true,
    );
    _drawText(
      canvas,
      'Smartphone microphones may have \u00B15-10dB variance',
      y: 942,
      fontSize: 16,
      color: Colors.white.withValues(alpha: 0.35),
      center: true,
    );

    // ─── 워터마크 (무료만) ───
    if (!isPremium) {
      _drawText(
        canvas,
        'soundsense.app',
        x: _size - _pad,
        y: 1030,
        fontSize: 18,
        color: Colors.white.withValues(alpha: 0.2),
        fontWeight: FontWeight.w500,
        alignRight: true,
      );
    }

    // ─── 이미지 변환 ───
    final picture = recorder.endRecording();
    final image = await picture.toImage(_size.toInt(), _size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData!.buffer.asUint8List();
  }

  // ─── 배경 그라데이션 ───

  static void _drawBackground(Canvas canvas, Color levelColor) {
    // 다크 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _size, _size),
      Paint()..color = AppColors.background,
    );

    // 레벨 색상 그라데이션 (상단에서 페이드)
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      const Offset(0, _size * 0.7),
      [
        levelColor.withValues(alpha: 0.35),
        levelColor.withValues(alpha: 0.05),
        Colors.transparent,
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _size, _size),
      Paint()..shader = gradient,
    );
  }

  // ─── 레벨 인디케이터 (● + 텍스트) ───

  static void _drawLevelIndicator(
    Canvas canvas,
    DbLevel level, {
    required double y,
  }) {
    final description = _getLevelDescription(level);

    // 텍스트 측정
    final tp = TextPainter(
      text: TextSpan(
        text: description,
        style: TextStyle(
          fontSize: 36,
          color: level.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // 원 + 텍스트 전체 폭 계산
    const circleRadius = 12.0;
    const gap = 14.0;
    final totalWidth = circleRadius * 2 + gap + tp.width;
    final startX = (_size - totalWidth) / 2;

    // 색상 원
    canvas.drawCircle(
      Offset(startX + circleRadius, y + tp.height / 2),
      circleRadius,
      Paint()..color = level.color,
    );

    // 레벨 텍스트
    tp.paint(canvas, Offset(startX + circleRadius * 2 + gap, y));
  }

  // ─── 텍스트 그리기 헬퍼 ───

  static void _drawText(
    Canvas canvas,
    String text, {
    double? x,
    required double y,
    double fontSize = 14,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w400,
    bool center = false,
    bool alignRight = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: _size - _pad * 2);

    double dx;
    if (center) {
      dx = (_size - tp.width) / 2;
    } else if (alignRight) {
      dx = (x ?? _size - _pad) - tp.width;
    } else {
      dx = x ?? _pad;
    }

    tp.paint(canvas, Offset(dx, y));
  }

  // ─── 레벨 설명 텍스트 ───

  static String _getLevelDescription(DbLevel level) {
    return switch (level) {
      DbLevel.silent => 'Very Quiet',
      DbLevel.quiet => 'Quiet Environment',
      DbLevel.moderate => 'Moderate Noise',
      DbLevel.loud => 'Loud Environment',
      DbLevel.danger => 'Dangerous Level',
    };
  }
}
