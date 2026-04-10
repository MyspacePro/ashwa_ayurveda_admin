import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final double maxDiscount;
  final double minOrderAmount;
  final Timestamp expiryDate;
  final bool isActive;
  final Timestamp createdAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscount,
    required this.minOrderAmount,
    required this.expiryDate,
    required this.isActive,
    required this.createdAt,
  });

  factory CouponModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CouponModel(
      id: doc.id,
      code: data['code'] ?? '',
      discountType: data['discountType'] ?? '',
      discountValue: (data['discountValue'] ?? 0).toDouble(),
      maxDiscount: (data['maxDiscount'] ?? 0).toDouble(),
      minOrderAmount: (data['minOrderAmount'] ?? 0).toDouble(),
      expiryDate: data['expiryDate'] ?? Timestamp.now(),
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'maxDiscount': maxDiscount,
      'minOrderAmount': minOrderAmount,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}