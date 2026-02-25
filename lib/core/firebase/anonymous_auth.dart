import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDeviceIdKey = 'device_id';

/// 기기 ID Provider — Anonymous Auth UID
/// main.dart에서 override 필수
final deviceIdProvider = Provider<String>((ref) {
  throw UnimplementedError('deviceIdProvider는 main.dart에서 override 해야 합니다');
});

/// 앱 시작 시 한 번만 호출 — 익명 로그인 + UID 캐싱
/// 1) SharedPreferences에 캐시된 UID가 있으면 바로 반환
/// 2) Firebase 현재 유저가 있으면 UID 캐싱 후 반환
/// 3) 없으면 signInAnonymously → UID 캐싱 후 반환
Future<String> ensureAnonymousAuth() async {
  final prefs = await SharedPreferences.getInstance();

  // 캐시 확인
  final cached = prefs.getString(_kDeviceIdKey);
  if (cached != null && cached.isNotEmpty) {
    debugPrint('🔑 캐시된 deviceId 사용: $cached');
    return cached;
  }

  // Firebase 현재 유저 확인
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final uid = currentUser.uid;
    await prefs.setString(_kDeviceIdKey, uid);
    debugPrint('🔑 기존 Firebase 유저 UID 캐싱: $uid');
    return uid;
  }

  // 익명 로그인
  final credential = await FirebaseAuth.instance.signInAnonymously();
  final uid = credential.user!.uid;
  await prefs.setString(_kDeviceIdKey, uid);
  debugPrint('🔑 익명 로그인 완료, deviceId: $uid');
  return uid;
}
