import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/features/onboarding/screens/onboarding_page_1.dart';
import 'package:soundsense/features/onboarding/screens/onboarding_page_2.dart';
import 'package:soundsense/features/onboarding/screens/onboarding_page_3.dart';
import 'package:soundsense/features/onboarding/screens/onboarding_page_4.dart';

/// SharedPreferences 키
const kOnboardingDoneKey = 'isOnboardingDone';

/// 온보딩 화면 — 4단계 PageView 슬라이드
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _goToPage(_currentPage + 1);
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingDoneKey, true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            // ─── PageView ───
            PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const ClampingScrollPhysics(),
              children: [
                OnboardingPage1(onNext: _nextPage),
                OnboardingPage2(onNext: _nextPage),
                OnboardingPage3(onNext: _nextPage),
                OnboardingPage4(onComplete: _completeOnboarding),
              ],
            ),

            // ─── Skip 버튼 (마지막 페이지에서 숨김) ───
            if (_currentPage < 3)
              Positioned(
                top: 8,
                right: 16,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // ─── 페이지 인디케이터 ───
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.accent
                          : AppColors.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
