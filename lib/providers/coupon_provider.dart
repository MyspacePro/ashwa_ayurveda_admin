import 'dart:async';
import 'package:flutter/material.dart';

import '../models/coupon_model.dart';
import '../services/firebase/coupon_service.dart';

class CouponProvider with ChangeNotifier {
  final CouponService _service;

  CouponProvider(this._service);

  // =========================
  // 📦 STATE
  // =========================
  List<CouponModel> _coupons = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<CouponModel>>? _subscription;
  bool _isInitialized = false;

  // =========================
  // 📦 GETTERS
  // =========================
  List<CouponModel> get coupons => List.unmodifiable(_coupons);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCoupons => _coupons.length;
  int get activeCoupons => _coupons.where((c) => c.isActive).length;

  List<CouponModel> get expiredCoupons =>
      _coupons.where((c) => c.isExpired).toList();

  // =========================
  // 🚀 INIT (SAFE)
  // =========================
  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
    _startListener();
  }

  void _startListener() {
    _subscription?.cancel();

    _setLoading(true);
    _clearError();

    _subscription = _service.getCoupons().listen(
      (data) {
        _coupons = data;
        _setLoading(false);
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  // =========================
  // ❌ REMOVED DUPLICATE FIRESTORE LISTENER
  // =========================
  // ❌ listenCoupons() removed (was conflicting with service stream)
  // 👉 use only _service.getCoupons()

  // =========================
  // ➕ ADD COUPON
  // =========================
  Future<void> addCoupon(CouponModel coupon) async {
    try {
      _clearError();
      await _service.addCoupon(coupon);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // 🔄 TOGGLE STATUS (OPTIMISTIC)
  // =========================
  Future<void> toggleStatus(CouponModel coupon) async {
    final index = _coupons.indexWhere((c) => c.id == coupon.id);
    if (index == -1) return;

    final backup = _coupons[index];

    try {
      _clearError();

      // optimistic update
      _coupons[index] =
          coupon.copyWith(isActive: !coupon.isActive);
      notifyListeners();

      await _service.updateCoupon(
        coupon.id,
        {'isActive': !coupon.isActive},
      );
    } catch (e) {
      // rollback
      _coupons[index] = backup;
      notifyListeners();

      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // ❌ DELETE (OPTIMISTIC)
  // =========================
  Future<void> deleteCoupon(String id) async {
    final index = _coupons.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final backup = _coupons[index];

    _coupons.removeAt(index);
    notifyListeners();

    try {
      await _service.deleteCoupon(id);
    } catch (e) {
      _coupons.insert(index, backup);
      notifyListeners();

      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // 🔄 REFRESH
  // =========================
  Future<void> refresh() async {
    _isInitialized = false;
    _startListener();
  }

  // =========================
  // 🔧 HELPERS
  // =========================
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // =========================
  // 🧹 DISPOSE
  // =========================
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}