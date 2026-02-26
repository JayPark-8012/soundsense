import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soundsense/core/theme/app_theme.dart';
import 'package:soundsense/features/measurement/screens/measurement_screen.dart';
import 'package:soundsense/features/history/screens/history_screen.dart';
import 'package:soundsense/features/history/screens/session_detail_screen.dart';
import 'package:soundsense/features/map/screens/map_screen.dart';
import 'package:soundsense/features/onboarding/screens/onboarding_screen.dart';
import 'package:soundsense/features/settings/screens/settings_screen.dart';
import 'package:soundsense/features/settings/screens/noise_guide_screen.dart';
import 'package:soundsense/features/settings/providers/settings_provider.dart';
import 'package:soundsense/l10n/app_localizations.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';
import 'package:soundsense/main.dart' show isOnboardingDoneProvider;

final _routerProvider = Provider<GoRouter>((ref) {
  final isOnboardingDone = ref.watch(isOnboardingDoneProvider);

  return GoRouter(
    initialLocation: isOnboardingDone ? '/' : '/onboarding',
    routes: [
      // ─── 온보딩 (풀스크린 — 페이드 전환 400ms) ───
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          // 탭1: 측정
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const MeasurementScreen(),
              ),
            ],
          ),
          // 탭2: 기록
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => _fadeSlide(
                      state,
                      SessionDetailScreen(
                        sessionId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 탭3: 지도
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) {
                  final sessionId = state.uri.queryParameters['sessionId'];
                  return MapScreen(focusSessionId: sessionId);
                },
              ),
            ],
          ),
          // 탭4: 설정
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'noise-guide',
                    pageBuilder: (context, state) =>
                        _fadeSlide(state, const NoiseGuideScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// 일반 push 전환 — 페이드 + 슬라이드 (아래→위), 250ms
CustomTransitionPage _fadeSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, _, page) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: slide, child: page),
      );
    },
  );
}

/// 앱 루트 위젯
class SoundSenseApp extends ConsumerWidget {
  const SoundSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final localeCode = ref.watch(selectedLocaleProvider);
    return MaterialApp.router(
      title: 'SoundSense',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(localeCode),
    );
  }
}

/// 하단 네비게이션 탭을 감싸는 셸
class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.mic_none),
            selectedIcon: const Icon(Icons.mic),
            label: context.l10n.tabMeasure,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            selectedIcon: const Icon(Icons.history_rounded),
            label: context.l10n.tabHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: context.l10n.tabMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
