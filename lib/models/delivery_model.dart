import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryStatus {
  pending,
  shipped,
  outForDelivery,
  delivered,
  failed; // ✅ FIXED (comma + proper placement)

  /// 🔹 Convert enum → Firestore string
  String get value {
    switch (this) {
      case DeliveryStatus.pending:
        return 'PENDING';
      case DeliveryStatus.shipped:
        return 'SHIPPED';
      case DeliveryStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case DeliveryStatus.delivered:
        return 'DELIVERED';
      case DeliveryStatus.failed:
        return 'FAILED'; // ✅ ADDED
    }
  }

  /// 🔹 Human readable (UI)
  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.shipped:
        return 'Shipped';
      case DeliveryStatus.outForDelivery:
        return 'Out for delivery';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Failed'; // ✅ FIXED (capital)
    }
  }

  /// 🔹 Safe parsing
  static DeliveryStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'SHIPPED':
        return DeliveryStatus.shipped;
      case 'OUT_FOR_DELIVERY':
        return DeliveryStatus.outForDelivery;
      case 'DELIVERED':
        return DeliveryStatus.delivered;
      case 'FAILED':
        return DeliveryStatus.failed; // ✅ ADDED
      case 'PENDING':
      default:
        return DeliveryStatus.pending; // ✅ FIXED (single default)
    }
  }
}

class DeliveryModel {
  final String orderId;
  final DeliveryStatus deliveryStatus;
  final String deliveryPartner;
  final String trackingId;
  final DateTime? updatedAt;

  const DeliveryModel({
    required this.orderId,
    required this.deliveryStatus,
    required this.deliveryPartner,
    required this.trackingId,
    this.updatedAt,
  });

  // =========================
  // 🔥 FIRESTORE FACTORY
  // =========================
  factory DeliveryModel.fromMap(
    Map<String, dynamic>? map,
    String orderId,
  ) {
    if (map == null) {
      return DeliveryModel(
        orderId: orderId,
        deliveryStatus: DeliveryStatus.pending,
        deliveryPartner: '',
        trackingId: '',
        updatedAt: null,
      );
    }

    return DeliveryModel(
      orderId: orderId,
      deliveryStatus:
          DeliveryStatus.fromString(map['deliveryStatus']),
      deliveryPartner: map['deliveryPartner']?.toString() ?? '',
      trackingId: map['trackingId']?.toString() ?? '',
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  // =========================
  // 🔁 COPY WITH
  // =========================
  DeliveryModel copyWith({
    DeliveryStatus? deliveryStatus,
    String? deliveryPartner,
    String? trackingId,
    DateTime? updatedAt,
  }) {
    return DeliveryModel(
      orderId: orderId,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryPartner: deliveryPartner ?? this.deliveryPartner,
      trackingId: trackingId ?? this.trackingId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================
  // 🔄 TO MAP (FIRESTORE)
  // =========================
  Map<String, dynamic> toMap() {
    return {
      'deliveryStatus': deliveryStatus.value,
      'deliveryPartner': deliveryPartner,
      'trackingId': trackingId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // =========================
  // 🧠 HELPERS
  // =========================
  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool get isDelivered => deliveryStatus == DeliveryStatus.delivered;

  bool get isFailed => deliveryStatus == DeliveryStatus.failed; // ✅ NEW

  bool get isInTransit =>
      deliveryStatus == DeliveryStatus.shipped ||
      deliveryStatus == DeliveryStatus.outForDelivery;
}