import 'package:admin_control/models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

enum PaymentStatus { pending, paid, failed }

class OrderModel {
  final String id;
  final String orderId;
  final List<CartItemModel> products;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final String address;
  final String paymentMethod;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.orderId,
    required this.products,
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
    required this.userId,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  OrderModel copyWith({
    String? id,
    String? orderId,
    List<CartItemModel>? products,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? totalAmount,
    String? address,
    String? paymentMethod,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      products: products ?? this.products,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'orderId': orderId,
      'userId': userId,
      'products': products.map((e) => e.toOrderMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawProducts = map['products'] ?? map['items'];

    final parsedProducts = (rawProducts is List)
        ? rawProducts
            .whereType<Map>()
            .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <CartItemModel>[];

    return OrderModel(
      id: docId,
      orderId: map['orderId']?.toString() ?? docId,
      userId: map['userId']?.toString() ?? '',
      products: parsedProducts,
      subtotal: _toDouble(map['subtotal']),
      deliveryFee: _toDouble(map['deliveryFee']),
      discount: _toDouble(map['discount']),
      totalAmount: _toDouble(map['totalAmount']),
      address: map['address']?.toString() ?? '',
      paymentMethod: map['paymentMethod']?.toString() ?? '',
      status: _parseStatus(map['status']),
      paymentStatus: _parsePaymentStatus(map['paymentStatus']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
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

  int get totalItems => products.fold(0, (sum, e) => sum + e.quantity);
}
