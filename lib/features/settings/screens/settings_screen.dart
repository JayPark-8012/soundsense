import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundsense/core/database/session_repository.dart';
import 'package:soundsense/core/theme/app_colors.dart';
import 'package:soundsense/core/theme/app_text_styles.dart';
import 'package:soundsense/features/onboarding/screens/onboarding_screen.dart'
    show kOnboardingDoneKey;
import 'package:soundsense/features/settings/providers/settings_provider.dart';
import 'package:soundsense/features/settings/screens/disclaimer_screen.dart';
import 'package:soundsense/features/settings/screens/noise_guide_screen.dart';
import 'package:soundsense/features/settings/screens/privacy_policy_screen.dart';
import 'package:soundsense/features/settings/services/csv_export_service.dart';
import 'package:soundsense/features/settings/services/pdf_report_service.dart';
import 'package:soundsense/shared/providers/calibration_provider.dart';
import 'package:soundsense/shared/providers/premium_provider.dart';
import 'package:soundsense/shared/services/ad_service.dart';
import 'package:soundsense/shared/widgets/premium_bottom_sheet.dart';
import 'package:soundsense/shared/extensions/l10n_extension.dart';
import 'package:soundsense/shared/widgets/premium_guard.dart';

/// 설정 화면 — 탭 4
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final is85dbAlert = ref.watch(is85dbAlertProvider);
    final selectedLocale = ref.watch(selectedLocaleProvider);
    final calibrationOffset = ref.watch(calibrationOffsetProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── PRO 카드 ───
            _buildProCard(context, ref),
            const SizedBox(height: 24),

            // ─── 캘리브레이션 섹션 ───
            _buildSectionHeader(context.l10n.calibration),
            const SizedBox(height: 8),
            _buildCalibrationSection(context, ref, calibrationOffset),
            const SizedBox(height: 24),

            // ─── 알림 섹션 ───
            _buildSectionHeader(context.l10n.noiseAlert),
            const SizedBox(height: 8),
            _buildToggleTile(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
              title: context.l10n.noiseAlert,
              subtitle: context.l10n.noiseAlertDesc,
              value: is85dbAlert,
              onChanged: (_) =>
                  ref.read(is85dbAlertProvider.notifier).toggle(),
            ),
            const SizedBox(height: 24),

            // ─── 언어 섹션 ───
            _buildSectionHeader(context.l10n.language),
            const SizedBox(height: 8),
            _buildLanguageSelector(
              selectedLocale: selectedLocale,
              onChanged: (locale) =>
                  ref.read(selectedLocaleProvider.notifier).setLocale(locale),
            ),
            const SizedBox(height: 24),

            // ─── PRO 기능 섹션 ───
            _buildSectionHeader(context.l10n.proFeatures),
            const SizedBox(height: 8),
            _buildInfoTile(
              icon: Icons.picture_as_pdf_rounded,
              title: context.l10n.monthlyPdf,
              onTap: () => _onGeneratePdfReport(context, ref),
            ),
            PremiumGuard(
              featureName: context.l10n.csvExport,
              lockedChild: _buildLockedProTile(
                context: context,
                icon: Icons.file_download_outlined,
                title: context.l10n.csvExport,
              ),
              child: _buildInfoTile(
                icon: Icons.file_download_outlined,
                title: context.l10n.csvExport,
                onTap: () => _onExportCsv(context, ref),
              ),
            ),
            const SizedBox(height: 24),

            // ─── 정보 섹션 ───
            _buildSectionHeader(context.l10n.information),
            const SizedBox(height: 8),
            _buildInfoTile(
              icon: Icons.volume_up_rounded,
              title: context.l10n.noiseGuide,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NoiseGuideScreen()),
              ),
            ),
            _buildInfoTile(
              icon: Icons.gavel_rounded,
              title: context.l10n.disclaimer,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DisclaimerScreen()),
              ),
            ),
            _buildInfoTile(
              icon: Icons.privacy_tip_outlined,
              title: context.l10n.privacyPolicy,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            _buildVersionTile(context.l10n.version),

            // ─── Debug 섹션 (kDebugMode only) ───
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Debug'),
              const SizedBox(height: 8),
              _buildToggleTile(
                icon: Icons.workspace_premium_rounded,
                iconColor: AppColors.proGold,
                title: 'PRO Mode',
                subtitle: 'Toggle premium features for testing',
                value: ref.watch(debugPremiumProvider),
                onChanged: (newValue) {
                  ref.read(debugPremiumProvider.notifier).toggle();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newValue ? 'PRO 모드 활성화' : 'PRO 모드 비활성화',
                      ),
                      backgroundColor:
                          newValue ? AppColors.proGold : AppColors.surface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              _buildInfoTile(
                icon: Icons.refresh_rounded,
                title: context.l10n.resetOnboarding,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(kOnboardingDoneKey, false);
                  if (context.mounted) {
                    context.go('/onboarding');
                  }
                },
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── CSV 내보내기 ───

  Future<void> _onExportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final sessions = await ref.read(sessionRepositoryProvider).getSessions();
      if (sessions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.noMeasurementsToExport),
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return;
      }
      await CsvExportService.exportAllSessions(sessions);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToExportCsv),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // ─── 월간 PDF 리포트 ───

  Future<void> _onGeneratePdfReport(BuildContext context, WidgetRef ref) async {
    final isPremium = ref.read(isPremiumProvider);

    if (isPremium) {
      await _generatePdf(context, ref);
    } else {
      // 무료 유저 → 리워드 광고 시청 후 PDF 생성
      final adService = ref.read(adServiceProvider);
      final shown = await adService.showRewardedAd(
        onRewarded: () => _generatePdf(context, ref),
      );
      if (!shown && context.mounted) {
        // 광고 미로드 시 바로 생성 (광고 로드 실패 시 사용자 차단 방지)
        await _generatePdf(context, ref);
      }
    }
  }

  Future<void> _generatePdf(BuildContext context, WidgetRef ref) async {
    try {
      final sessions = await ref.read(sessionRepositoryProvider).getSessions();
      final hasData = await PdfReportService.generateMonthlyReport(sessions);
      if (!hasData && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.noMeasurementsThisMonth),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToGeneratePdf),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // ─── PRO 카드 ───

  Widget _buildProCard(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.proGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.proGold.withValues(alpha: isPremium ? 0.15 : 0.08),
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '\u{1F451}',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.soundsensePro,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.proGold,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.l10n.proActiveLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPremium ? context.l10n.proActiveDesc : context.l10n.proDesc,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (!isPremium) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n.proFromPrice,
              style: AppTextStyles.body.copyWith(
                color: AppColors.proGoldLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  PremiumBottomSheet.show(context, featureName: context.l10n.soundsensePro);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.proGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.l10n.getLifetimePro,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 캘리브레이션 섹션 ───

  Widget _buildCalibrationSection(
      BuildContext context, WidgetRef ref, double offset) {
    final Color trackColor;
    if (offset < 0) {
      trackColor = AppColors.accent;
    } else if (offset > 0) {
      trackColor = AppColors.levelLoud;
    } else {
      trackColor = AppColors.levelQuiet;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 22, color: trackColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.calibration,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.calibrationSubtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${offset >= 0 ? '+' : ''}${offset.toStringAsFixed(1)} dB',
                style: AppTextStyles.body.copyWith(
                  color: trackColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: trackColor,
              inactiveTrackColor: trackColor.withValues(alpha: 0.2),
              thumbColor: trackColor,
              overlayColor: trackColor.withValues(alpha: 0.12),
              trackHeight: 4,
            ),
            child: Slider(
              value: offset,
              min: -10.0,
              max: 10.0,
              divisions: 200,
              onChanged: (value) {
                ref
                    .read(calibrationOffsetProvider.notifier)
                    .setOffset(double.parse(value.toStringAsFixed(1)));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-10 dB',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              if (offset != 0.0)
                GestureDetector(
                  onTap: () => ref
                      .read(calibrationOffsetProvider.notifier)
                      .setOffset(0.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.l10n.resetDefault,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              Text(
                '+10 dB',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.calibrationWarning,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 섹션 헤더 ───

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─── 토글 타일 ───

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }

  // ─── 언어 선택기 ───

  Widget _buildLanguageSelector({
    required String selectedLocale,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildLanguageOption(
            label: 'English',
            locale: 'en',
            isSelected: selectedLocale == 'en',
            onTap: () => onChanged('en'),
          ),
          _buildLanguageOption(
            label: '\uD55C\uAD6D\uC5B4',
            locale: 'ko',
            isSelected: selectedLocale == 'ko',
            onTap: () => onChanged('ko'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String locale,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── 정보 타일 ───

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── PRO 잠금 타일 (lockedChild) ───

  Widget _buildLockedProTile({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    return Opacity(
      opacity: 0.85,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textTertiary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: AppColors.proGold.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.proGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                context.l10n.pro,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.proGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 앱 버전 타일 ───

  Widget _buildVersionTile(String versionLabel) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '...';

        return Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Text(
                versionLabel,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                version,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
