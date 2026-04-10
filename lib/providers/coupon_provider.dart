import 'package:admin_control/services/firebase/coupon_service.dart';
import 'package:flutter/material.dart';
import '../models/coupon_model.dart';


class CouponProvider extends ChangeNotifier {
  final CouponService _service;

  List<CouponModel> _coupons = [];
  bool _loading = false;

  CouponProvider(this._service);

  List<CouponModel> get coupons => _coupons;
  bool get isLoading => _loading;

  /// Listen Coupons
  void listenCoupons() {
    _loading = true;
    notifyListeners();

    _service.getCoupons().listen((data) {
      _coupons = data;
      _loading = false;
      notifyListeners();
    });
  }

  /// Add Coupon
  Future<void> addCoupon(CouponModel coupon) async {
    await _service.addCoupon(coupon);
  }

  /// Toggle Active
  Future<void> toggleStatus(CouponModel coupon) async {
    await _service.updateCoupon(coupon.id, {
      'isActive': !coupon.isActive,
    });
  }

  /// Delete Coupon
  Future<void> deleteCoupon(String id) async {
    await _service.deleteCoupon(id);
  }
}