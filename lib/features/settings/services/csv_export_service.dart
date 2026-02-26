import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soundsense/core/database/measurement_session.dart';
import 'package:soundsense/shared/constants/db_levels.dart';

/// 전체 세션 CSV 내보내기 서비스
class CsvExportService {
  /// 전체 세션을 하나의 CSV 파일로 생성 후 공유 시트 표시
  /// 세션이 비어있으면 null 반환 (호출자가 SnackBar 처리)
  static Future<bool> exportAllSessions(
    List<MeasurementSession> sessions,
  ) async {
    if (sessions.isEmpty) return false;

    try {
      final buffer = StringBuffer();

      // 헤더
      buffer.writeln('date,location,avg_db,max_db,min_db,level,duration');

      // 데이터 행
      final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
      for (final s in sessions) {
        final date = dateFmt.format(s.startedAt);
        final location = _escapeCsv(s.locationName ?? '');
        final avgDb = s.avgDb.toStringAsFixed(1);
        final maxDb = s.maxDb.toStringAsFixed(1);
        final minDb = s.minDb.toStringAsFixed(1);
        final level = DbLevel.fromDb(s.avgDb).labelEn;
        final duration = _formatDuration(s.durationSec);

        buffer.writeln('$date,$location,$avgDb,$maxDb,$minDb,$level,$duration');
      }

      // 파일 저장
      final dir = await getTemporaryDirectory();
      final today = DateFormat('yyyyMMdd').format(DateTime.now());
      final fileName = 'soundsense_all_$today.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      // 공유 시트
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'SoundSense measurement data',
      );

      return true;
    } catch (e) {
      debugPrint('CSV export error: $e');
      rethrow;
    }
  }

  /// CSV 값 이스케이프 — 쉼표나 큰따옴표 포함 시 감싸기
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// 초 → "Xm Ys" 포맷
  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}
