import 'package:admin_control/models/cart_item_model.dart';

/// ===============================
/// 🧾 Checkout Arguments (PRODUCTION READY)
/// ===============================
class CheckoutArgs {
  final List<CartItemModel> items;
  final double totalAmount;
  final String currency;
  final String address;
  final String? notes;

  const CheckoutArgs({
    required this.items,
    required this.totalAmount,
    required this.address,
    this.currency = "INR",
    this.notes,
  });

  /// ===============================
  /// ✅ SAFE VALIDATION (use before API call)
  /// ===============================
  String? validate() {
    if (items.isEmpty) return "Cart cannot be empty";
    if (totalAmount <= 0) return "Invalid total amount";
    if (address.trim().length < 10) return "Invalid address";
    return null;
  }

  /// ===============================
  /// 🔁 CopyWith
  /// ===============================
  CheckoutArgs copyWith({
    List<CartItemModel>? items,
    double? totalAmount,
    String? currency,
    String? address,
    String? notes,
  }) {
    return CheckoutArgs(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }

  /// ===============================
  /// 🔄 TO JSON (API SAFE)
  /// ===============================
  Map<String, dynamic> toJson() {
    return {
      "items": items.map((e) => e.toJson()).toList(),
      "totalAmount": double.parse(totalAmount.toStringAsFixed(2)),
      "currency": currency,
      "address": address.trim(),
      "notes": notes ?? "",
    };
  }

  /// ===============================
  /// 🔄 FROM JSON (IMPORTANT FOR BACKEND)
  /// ===============================
  factory CheckoutArgs.fromJson(Map<String, dynamic> json) {
    return CheckoutArgs(
      items: (json["items"] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
      totalAmount: (json["totalAmount"] as num).toDouble(),
      currency: json["currency"] ?? "INR",
      address: json["address"] ?? "",
      notes: json["notes"],
    );
  }

  /// ===============================
  /// 🧠 Debug helper
  /// ===============================
  @override
  String toString() {
    return "CheckoutArgs(total: $totalAmount, items: ${items.length}, address: $address)";
  }
}