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
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [MeasurementSessionSchema],
    directory: dir.path,
  );
}
