import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryStatus { pending, shipped, outForDelivery, delivered }

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

  factory DeliveryModel.fromOrderMap(Map<String, dynamic> map, String orderId) {
    final raw = map['deliveryStatus']?.toString().toUpperCase() ?? 'PENDING';
    final status = switch (raw) {
      'SHIPPED' => DeliveryStatus.shipped,
      'OUT_FOR_DELIVERY' => DeliveryStatus.outForDelivery,
      'DELIVERED' => DeliveryStatus.delivered,
      _ => DeliveryStatus.pending,
    };

    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return DeliveryModel(
      orderId: orderId,
      deliveryStatus: status,
      deliveryPartner: map['deliveryPartner']?.toString() ?? '',
      trackingId: map['trackingId']?.toString() ?? '',
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final status = switch (deliveryStatus) {
      DeliveryStatus.pending => 'PENDING',
      DeliveryStatus.shipped => 'SHIPPED',
      DeliveryStatus.outForDelivery => 'OUT_FOR_DELIVERY',
      DeliveryStatus.delivered => 'DELIVERED',
    };

    return {
      'deliveryStatus': status,
      'deliveryPartner': deliveryPartner,
      'trackingId': trackingId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
