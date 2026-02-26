import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:isar/isar.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:soundsense/app.dart';
import 'package:soundsense/core/database/isar_provider.dart';
import 'package:soundsense/core/database/session_repository.dart';
import 'package:soundsense/core/firebase/anonymous_auth.dart';
import 'package:soundsense/core/permissions/location_permission.dart';
import 'package:soundsense/core/permissions/microphone_permission.dart';
import 'package:soundsense/core/platform/mock_data_seeder.dart';
import 'package:soundsense/core/platform/platform_providers.dart';
import 'package:soundsense/core/platform/web_session_repository.dart';
import 'package:soundsense/features/measurement/providers/measurement_provider.dart';
import 'package:soundsense/features/onboarding/screens/onboarding_screen.dart';

/// 온보딩 완료 여부 Provider — main에서 override
final isOnboardingDoneProvider = Provider<bool>((ref) => true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await _mainWeb();
  } else {
    await _mainMobile();
  }
}

/// 웹: Isar/Firebase 스킵, 인메모리 저장소 + mock providers
Future<void> _mainWeb() async {
  final webRepo = WebSessionRepository();

  // 샘플 데이터 삽입
  await MockDataSeeder.seed(webRepo);

  runApp(
    ProviderScope(
      overrides: [
        deviceIdProvider.overrideWithValue('web-preview-device'),
        sessionRepositoryProvider.overrideWithValue(webRepo),
        measurementProvider.overrideWith((_) => WebMeasurementNotifier()),
        micPermissionProvider.overrideWith((_) => WebMicPermissionNotifier()),
        locationPermissionProvider
            .overrideWith((_) => WebLocationPermissionNotifier()),
        // 웹은 온보딩 스킵
        isOnboardingDoneProvider.overrideWithValue(true),
      ],
      child: const SoundSenseApp(),
    ),
  );
}

/// 모바일: 기존 로직 (Firebase + Isar + RevenueCat + AdMob)
Future<void> _mainMobile() async {
  debugPrint('🚀 [BOOT] 1/6 — Firebase 초기화 시작');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🚀 [BOOT] 1/6 — Firebase 초기화 완료 ✓');
  } catch (e) {
    debugPrint('🚀 [BOOT] 1/6 — Firebase 초기화 실패: $e');
  }

  debugPrint('🚀 [BOOT] 2/6 — Isar DB 초기화 시작');
  late final Isar isar;
  try {
    isar = await initIsar();
    debugPrint('🚀 [BOOT] 2/6 — Isar DB 초기화 완료 ✓');
  } catch (e) {
    debugPrint('🚀 [BOOT] 2/6 — Isar DB 초기화 실패: $e');
    rethrow;
  }

  debugPrint('🚀 [BOOT] 3/6 — 익명 인증 시작');
  String? deviceId;
  try {
    deviceId = await ensureAnonymousAuth();
    debugPrint('🚀 [BOOT] 3/6 — 익명 인증 완료 ✓ (id: $deviceId)');
  } catch (e) {
    debugPrint('🚀 [BOOT] 3/6 — 익명 인증 실패: $e');
  }

  debugPrint('🚀 [BOOT] 4/6 — RevenueCat 초기화 시작');
  try {
    await Purchases.setLogLevel(LogLevel.debug);
    final rcConfig = PurchasesConfiguration(
      Platform.isIOS
          ? 'test_yVVMbktkSopKkRUjiGPqvwGkDou'
          : 'test_yVVMbktkSopKkRUjiGPqvwGkDou',
    );
    await Purchases.configure(rcConfig);
    debugPrint('🚀 [BOOT] 4/6 — RevenueCat 초기화 완료 ✓');
  } catch (e) {
    debugPrint('🚀 [BOOT] 4/6 — RevenueCat 초기화 실패: $e');
  }

  debugPrint('🚀 [BOOT] 5/6 — AdMob 초기화 시작');
  try {
    await MobileAds.instance.initialize();
    debugPrint('🚀 [BOOT] 5/6 — AdMob 초기화 완료 ✓');
  } catch (e) {
    debugPrint('🚀 [BOOT] 5/6 — AdMob 초기화 실패: $e');
  }

  debugPrint('🚀 [BOOT] 6/6 — runApp 시작');
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(kOnboardingDoneKey) ?? false;

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        if (deviceId != null) deviceIdProvider.overrideWithValue(deviceId),
        isOnboardingDoneProvider.overrideWithValue(onboardingDone),
      ],
      child: const SoundSenseApp(),
    ),
  );
  debugPrint('🚀 [BOOT] 6/6 — runApp 호출 완료 ✓');
}
