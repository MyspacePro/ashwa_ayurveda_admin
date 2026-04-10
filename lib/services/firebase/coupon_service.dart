import 'package:admin_control/models/coupon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add Coupon
  Future<void> addCoupon(CouponModel coupon) async {
    await _firestore.collection('coupons').add(coupon.toMap());
  }

  /// Get All Coupons
  Stream<List<CouponModel>> getCoupons() {
    return _firestore
        .collection('coupons')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CouponModel.fromDoc(doc)).toList());
  }

  /// Update Coupon
  Future<void> updateCoupon(String id, Map<String, dynamic> data) async {
    await _firestore.collection('coupons').doc(id).update(data);
  }

  /// Delete Coupon
  Future<void> deleteCoupon(String id) async {
    await _firestore.collection('coupons').doc(id).delete();
  }
}