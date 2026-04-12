import 'package:cloud_firestore/cloud_firestore.dart';

enum CouponType {
  percentage,
  fixed;

  String get value {
    switch (this) {
      case CouponType.percentage:
        return 'PERCENTAGE';
      case CouponType.fixed:
        return 'FIXED';
    }
  }

  static CouponType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'FIXED':
        return CouponType.fixed;
      case 'PERCENTAGE':
        return CouponType.percentage;
      default:
        return CouponType.percentage;
    }
  }
}

class CouponModel {
  final String id;
  final String code;

  final CouponType discountType;
  final double discountValue;
  final double maxDiscount;
  final double minOrderAmount;

  final DateTime expiryDate;
  final bool isActive;
  final DateTime createdAt;

  final int usageCount;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscount,
    required this.minOrderAmount,
    required this.expiryDate,
    required this.isActive,
    required this.createdAt,
    this.usageCount = 0,
  });

  // =========================
  // 🔥 FROM FIRESTORE (SAFE)
  // =========================
  factory CouponModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Coupon data is null");
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is DateTime) return value;
      return null;
    }

    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      return (value as num).toDouble();
    }

    return CouponModel(
      id: doc.id,
      code: (data['code'] ?? '').toString().toUpperCase(),
      discountType: CouponType.fromString(data['discountType']),
      discountValue: toDouble(data['discountValue']),
      maxDiscount: toDouble(data['maxDiscount']),
      minOrderAmount: toDouble(data['minOrderAmount']),
      expiryDate: parseDate(data['expiryDate']) ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdAt: parseDate(data['createdAt']) ?? DateTime.now(),
      usageCount: (data['usageCount'] ?? 0) as int,
    );
  }

  // =========================
  // 🔄 COPY WITH
  // =========================
  CouponModel copyWith({
    String? code,
    CouponType? discountType,
    double? discountValue,
    double? maxDiscount,
    double? minOrderAmount,
    DateTime? expiryDate,
    bool? isActive,
    int? usageCount,
  }) {
    return CouponModel(
      id: id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  // =========================
  // 🔄 TO FIRESTORE
  // =========================
  Map<String, dynamic> toMap() {
    return {
      'code': code.toUpperCase(),
      'discountType': discountType.value,
      'discountValue': discountValue,
      'maxDiscount': maxDiscount,
      'minOrderAmount': minOrderAmount,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'usageCount': usageCount,
    };
  }

  // =========================
  // 🎯 BUSINESS LOGIC
  // =========================

  bool isValid(double cartAmount) {
    if (!isActive) return false;
    if (cartAmount < minOrderAmount) return false;
    if (DateTime.now().isAfter(expiryDate)) return false;
    return true;
  }

  double calculateDiscount(double cartAmount) {
    if (!isValid(cartAmount)) return 0;

    double discount;

    if (discountType == CouponType.percentage) {
      discount = (cartAmount * discountValue) / 100;
    } else {
      discount = discountValue;
    }

    if (maxDiscount > 0 && discount > maxDiscount) {
      discount = maxDiscount;
    }

    return discount;
  }

  double finalAmount(double cartAmount) {
    return cartAmount - calculateDiscount(cartAmount);
  }

  // =========================
  // 🧠 HELPERS
  // =========================

  bool get isExpired => DateTime.now().isAfter(expiryDate);
}