import 'package:admin_control/models/cart_item_model.dart';

/// ===============================
/// 💳 Payment Arguments (PRODUCTION READY)
/// ===============================
class PaymentArgs {
  final List<CartItemModel> items;
  final double amount;
  final String address;
  final String currency;

  /// Payment method selected on checkout screen
  final String paymentMethod;

  const PaymentArgs({
    required this.items,
    required this.amount,
    required this.address,
    this.currency = "INR",
    required this.paymentMethod,
  });

  /// ===============================
  /// ✅ VALIDATION (use before payment API)
  /// ===============================
  String? validate() {
    if (items.isEmpty) return "Cart cannot be empty";
    if (amount <= 0) return "Invalid amount";
    if (address.trim().length < 10) return "Invalid address";
    if (paymentMethod.trim().isEmpty) return "Select payment method";
    return null;
  }

  /// ===============================
  /// 🔁 COPY WITH
  /// ===============================
  PaymentArgs copyWith({
    List<CartItemModel>? items,
    double? amount,
    String? address,
    String? currency,
    String? paymentMethod,
  }) {
    return PaymentArgs(
      items: items ?? this.items,
      amount: amount ?? this.amount,
      address: address ?? this.address,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  /// ===============================
  /// 🔄 TO JSON (API SAFE)
  /// ===============================
  Map<String, dynamic> toJson() {
    return {
      "items": items.map((e) => e.toJson()).toList(),
      "amount": double.parse(amount.toStringAsFixed(2)),
      "address": address.trim(),
      "currency": currency,
      "paymentMethod": paymentMethod,
    };
  }

  /// ===============================
  /// 🔄 FROM JSON (BACKEND SUPPORT)
  /// ===============================
  factory PaymentArgs.fromJson(Map<String, dynamic> json) {
    return PaymentArgs(
      items: (json["items"] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
      amount: (json["amount"] as num).toDouble(),
      address: json["address"] ?? "",
      currency: json["currency"] ?? "INR",
      paymentMethod: json["paymentMethod"] ?? "unknown",
    );
  }

  /// ===============================
  /// 🧠 DEBUG HELPER
  /// ===============================
  @override
  String toString() {
    return "PaymentArgs(amount: $amount, items: ${items.length}, method: $paymentMethod)";
  }
}