import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundsense/core/database/measurement_session.dart';

/// Isar 인스턴스 Provider
/// main.dart에서 overrideWithValue 로 초기화된 인스턴스 주입
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider는 main.dart에서 overrideWithValue로 초기화해야 합니다.',
  );
});

/// Isar 인스턴스 초기화 — main.dart에서 앱 시작 전 호출
/// 스키마 불일치(Collection id is invalid) 시 DB 삭제 후 재생성
Future<Isar> initIsar() async {
  // 웹: IndexedDB 사용 (directory 무시됨)
  if (kIsWeb) {
    return Isar.open(
      [MeasurementSessionSchema],
      directory: '',
    );
  }

  // 모바일: path_provider로 실제 경로 사용
  final dir = await getApplicationDocumentsDirectory();

  try {
    return await Isar.open(
      [MeasurementSessionSchema],
      directory: dir.path,
    );
  } on IsarError catch (e) {
    // 스키마 변경으로 기존 DB가 호환되지 않는 경우
    // → 기존 인스턴스 close(deleteFromDisk) 후 새로 열기
    debugPrint('⚠️ Isar 스키마 불일치 — DB 재생성: $e');

    // 실패한 open 시도에서 남은 인스턴스 정리
    final stale = Isar.getInstance();
    if (stale != null) {
      await stale.close(deleteFromDisk: true);
    } else {
      // getInstance가 null이면 파일 직접 삭제
      final dbFile = File('${dir.path}/default.isar');
      final lockFile = File('${dir.path}/default.isar.lock');
      if (dbFile.existsSync()) dbFile.deleteSync();
      if (lockFile.existsSync()) lockFile.deleteSync();
    }

    return Isar.open(
      [MeasurementSessionSchema],
      directory: dir.path,
    );
  }
}
