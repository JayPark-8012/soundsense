import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat 기반 구매 서비스
class PurchaseService {
  static const _productId = 'com.snutils.soundsense.pro_lifetime';
  static const _entitlementId = 'pro';

  /// Lifetime PRO 구매 — Product ID 직접 지정 방식
  /// 성공: true, 취소: null, 실패: exception throw
  Future<bool?> purchasePro() async {
    try {
      debugPrint('💳 [PURCHASE] getProducts($_productId) 호출...');
      final products = await Purchases.getProducts([_productId]);
      debugPrint('💳 [PURCHASE] products: ${products.length}개');

      if (products.isEmpty) {
        debugPrint('💳 [PURCHASE] ❌ 상품을 찾을 수 없음');
        throw Exception('Product not found: $_productId');
      }

      debugPrint('💳 [PURCHASE] 구매 시도: ${products.first.identifier}');
      await Purchases.purchase(PurchaseParams.storeProduct(products.first));
      debugPrint('💳 [PURCHASE] 구매 성공!');
      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('💳 [PURCHASE] 사용자 취소 (PlatformException)');
        return null;
      }
      debugPrint('💳 [PURCHASE] 실패: $errorCode — ${e.message}');
      rethrow;
    } catch (e) {
      // Test Store 팝업 외부 탭 등 예상치 못한 취소/에러
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') || msg.contains('dismiss')) {
        debugPrint('💳 [PURCHASE] 사용자 취소 (generic): $e');
        return null;
      }
      debugPrint('💳 [PURCHASE] 예외: $e');
      rethrow;
    }
  }

  /// 구매 복원
  /// 복원 성공(PRO): true, 구매 내역 없음: false, 실패: exception throw
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.containsKey(_entitlementId);
    } on PlatformException catch (e) {
      debugPrint('복원 실패: ${e.message}');
      rethrow;
    }
  }

  /// 현재 PRO 상태 확인
  Future<bool> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(_entitlementId);
    } catch (e) {
      debugPrint('PRO 상태 확인 실패: $e');
      return false;
    }
  }
}

/// PurchaseService Provider
final purchaseServiceProvider = Provider<PurchaseService>(
  (_) => PurchaseService(),
);
