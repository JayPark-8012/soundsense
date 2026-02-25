import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:soundsense/app.dart';
import 'package:soundsense/core/database/isar_provider.dart';
import 'package:soundsense/core/firebase/anonymous_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (설정 파일 없으면 앱은 그대로 실행)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase 초기화 실패: $e');
  }

  // Isar DB 초기화
  final isar = await initIsar();

  // 익명 인증 — deviceId 확보
  String? deviceId;
  try {
    deviceId = await ensureAnonymousAuth();
  } catch (e) {
    debugPrint('익명 인증 실패: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        if (deviceId != null) deviceIdProvider.overrideWithValue(deviceId),
      ],
      child: const SoundSenseApp(),
    ),
  );
}
