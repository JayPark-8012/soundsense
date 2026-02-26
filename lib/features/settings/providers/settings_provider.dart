import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── SharedPreferences 키 ───
const _k85dbAlert = 'is85dbAlertOn';
const _kLocale = 'selectedLocale';

// ─── 85dB 경고 알림 토글 ───

/// 85dB 초과 경고 알림 (기본 true)
final is85dbAlertProvider =
    NotifierProvider<_BoolSettingNotifier, bool>(() {
  return _BoolSettingNotifier(key: _k85dbAlert, defaultValue: true);
});

// ─── 언어 설정 ───

/// 선택된 언어 (기본 "en")
final selectedLocaleProvider =
    NotifierProvider<_LocaleNotifier, String>(() {
  return _LocaleNotifier();
});

// ─── Notifier 구현 ───

/// bool 설정값 Notifier — SharedPreferences 연동
class _BoolSettingNotifier extends Notifier<bool> {
  _BoolSettingNotifier({required this.key, required this.defaultValue});

  final String key;
  final bool defaultValue;

  @override
  bool build() {
    _load();
    return defaultValue;
  }

  /// SharedPreferences에서 값 로드
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(key);
      if (value != null) {
        state = value;
      }
    } catch (e) {
      debugPrint('⚠️ 설정 로드 실패 ($key): $e');
    }
  }

  /// 토글 — 값 변경 + SharedPreferences 저장
  Future<void> toggle() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, state);
    } catch (e) {
      debugPrint('⚠️ 설정 저장 실패 ($key): $e');
    }
  }
}

/// 언어 설정 Notifier — SharedPreferences 연동
class _LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return 'en';
  }

  /// SharedPreferences에서 값 로드
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_kLocale);
      if (value != null && value.isNotEmpty) {
        state = value;
      }
    } catch (e) {
      debugPrint('⚠️ 언어 설정 로드 실패: $e');
    }
  }

  /// 언어 변경
  Future<void> setLocale(String locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocale, locale);
    } catch (e) {
      debugPrint('⚠️ 언어 설정 저장 실패: $e');
    }
  }
}
