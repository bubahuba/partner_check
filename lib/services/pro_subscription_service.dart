import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProSubscriptionService extends ChangeNotifier {
  static const int freeContactLimit = 10;
  static const String productId = 'partner_check_pro';
  static const String _isProKey = 'is_pro_unlocked';

  final InAppPurchase _iap = InAppPurchase.instance;

  bool _isPro = false;
  bool _isStoreAvailable = false;
  bool _isLoading = false;
  ProductDetails? _proProduct;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool get isPro => _isPro;
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isLoading => _isLoading;
  ProductDetails? get proProduct => _proProduct;

  bool canAddContact(int currentCount) =>
      _isPro || currentCount < freeContactLimit;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_isProKey) ?? false;

    _isStoreAvailable = await _iap.isAvailable();
    if (!_isStoreAvailable) {
      notifyListeners();
      return;
    }

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) {},
    );

    await _loadProducts();
    await restorePurchases(silent: true);
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isNotEmpty) {
      _proProduct = response.productDetails.first;
    }
  }

  Future<void> purchasePro() async {
    if (_isPro || _isLoading || !_isStoreAvailable) return;

    if (_proProduct == null) {
      await _loadProducts();
    }
    final product = _proProduct;
    if (product == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases({bool silent = false}) async {
    if (!_isStoreAvailable) return;

    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    await _iap.restorePurchases();

    if (!silent) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _isLoading = true;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == productId) {
            _unlockPro();
          }
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          _isLoading = false;
      }
    }
    notifyListeners();
  }

  Future<void> _unlockPro() async {
    _isPro = true;
    _isLoading = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isProKey, true);
    notifyListeners();
  }

  /// Debug-only toggle to test free vs PRO without the store.
  Future<void> debugTogglePro() async {
    if (!kDebugMode) return;
    _isPro = !_isPro;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isProKey, _isPro);
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
