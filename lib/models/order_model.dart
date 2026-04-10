import 'package:admin_control/models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// =========================
/// 📦 ORDER STATUS
/// =========================
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
}

/// =========================
/// 💳 PAYMENT STATUS
/// =========================
enum PaymentStatus {
  pending,
  paid,
  failed,
}

/// =========================
/// 🔥 ORDER MODEL (PRODUCTION READY)
/// =========================
class OrderModel {
  final String id;
  final String orderId;

  final List<CartItemModel> items;

  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;

  final String address;
  final String paymentMethod;

  final OrderStatus status;
  final PaymentStatus paymentStatus;

  final String? userId;
  final String? phone;
  final String? paymentId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.userId,
    this.phone,
    this.paymentId,
    this.createdAt,
    this.updatedAt,
  });

  // =========================
  // COPY WITH
  // =========================
  OrderModel copyWith({
    String? id,
    String? orderId,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? totalAmount,
    String? address,
    String? paymentMethod,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? userId,
    String? phone,
    String? paymentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================
  // TO MAP (FIRESTORE SAFE)
  // =========================
  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'orderId': orderId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'userId': userId,
      'phone': phone,
      'paymentId': paymentId,

      /// ✅ FIX: timestamps handling
      'createdAt': isUpdate ? createdAt : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // =========================
  // FROM MAP (FIXED SAFE VERSION)
  // =========================
  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawItems = map['items'];

    List<CartItemModel> itemsList = [];

    if (rawItems is List) {
      itemsList = rawItems
          .whereType<Map>()
          .map((e) => CartItemModel.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    }

    return OrderModel(
      id: docId,
      orderId: map['orderId']?.toString() ?? '',

      items: itemsList,

      subtotal: _toDouble(map['subtotal']),
      deliveryFee: _toDouble(map['deliveryFee']),
      discount: _toDouble(map['discount']),
      totalAmount: _toDouble(map['totalAmount']),

      address: map['address']?.toString() ?? '',
      paymentMethod: map['paymentMethod']?.toString() ?? '',

      status: _parseStatus(map['status']),
      paymentStatus: _parsePaymentStatus(map['paymentStatus']),

      userId: map['userId']?.toString(),
      phone: map['phone']?.toString(),
      paymentId: map['paymentId']?.toString(),

      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  // =========================
  // HELPERS
  // =========================
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static OrderStatus _parseStatus(dynamic value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  static PaymentStatus _parsePaymentStatus(dynamic value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }

  // =========================
  // UI HELPERS
  // =========================
  int get totalItems => items.fold(0, (sum, e) => sum + e.quantity);

  String get formattedTotal => "₹${totalAmount.toStringAsFixed(2)}";

  String get statusText => status.name.toUpperCase();

  String get paymentText => paymentStatus.name.toUpperCase();

  bool get isDelivered => status == OrderStatus.delivered;
  bool get isPending => status == OrderStatus.pending;
  bool get isPaid => paymentStatus == PaymentStatus.paid;
}