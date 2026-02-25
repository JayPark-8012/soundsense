import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundsense/shared/providers/premium_provider.dart';
import 'package:soundsense/shared/widgets/premium_bottom_sheet.dart';

/// PRO 기능을 감싸는 래퍼 위젯
///
/// - isPremium == true → [child] 그대로 표시
/// - isPremium == false → [lockedChild] 표시 + 탭 시 PremiumBottomSheet
/// - 세션당 최대 1회 팝업 (중복 방지)
class PremiumGuard extends ConsumerStatefulWidget {
  const PremiumGuard({
    super.key,
    required this.child,
    required this.lockedChild,
    required this.featureName,
  });

  /// 실제 PRO 기능 위젯
  final Widget child;

  /// 잠금 시 표시할 위젯
  final Widget lockedChild;

  /// PRO 바텀시트에 표시할 기능명 (e.g. "Timeline Chart")
  final String featureName;

  @override
  ConsumerState<PremiumGuard> createState() => _PremiumGuardState();
}

class _PremiumGuardState extends ConsumerState<PremiumGuard> {
  /// 이 위젯 인스턴스에서 이미 바텀시트를 보여줬는지 (세션당 1회)
  bool _didShowSheet = false;

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) return widget.child;

    return GestureDetector(
      onTap: _showUpgradeSheet,
      behavior: HitTestBehavior.opaque,
      child: widget.lockedChild,
    );
  }

  void _showUpgradeSheet() {
    if (_didShowSheet) return;
    _didShowSheet = true;

    PremiumBottomSheet.show(context, featureName: widget.featureName);
  }
}
