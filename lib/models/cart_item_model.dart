class CartItemModel {
  final String productId;

  // 🔥 SNAPSHOT FIELDS (IMPORTANT FOR ADMIN)
  final String name;
  final String image;
  final double priceAtAdd;

  final int quantity;

  // OPTIONAL
  final String? variant;
  final int? maxQty;

  const CartItemModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.priceAtAdd,
    required this.quantity,
    this.variant,
    this.maxQty,
  });

  // =========================
  // 💰 TOTAL
  // =========================

  double get total => priceAtAdd * quantity;

  // =========================
  // 🔁 COPY WITH
  // =========================

  CartItemModel copyWith({
    String? productId,
    String? name,
    String? image,
    double? priceAtAdd,
    int? quantity,
    String? variant,
    int? maxQty,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      priceAtAdd: priceAtAdd ?? this.priceAtAdd,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
      maxQty: maxQty ?? this.maxQty,
    );
  }

  // =========================
  // 🔄 TO JSON (FIRESTORE)
  // =========================

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'image': image,
      'priceAtAdd': priceAtAdd,
      'quantity': quantity,
      'variant': variant,
      'maxQty': maxQty,
    };
  }

  // =========================
  // 🔄 FROM JSON (SAFE)
  // =========================

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId']?.toString() ??
          json['id']?.toString() ??
          "",

      name: json['name']?.toString() ?? "",

      image: json['image']?.toString() ?? "",

      priceAtAdd: double.tryParse(
              json['priceAtAdd']?.toString() ??
                  json['price']?.toString() ??
                  "0") ??
          0,

      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? "1") ??
              1,

      variant: json['variant']?.toString(),

      maxQty: json['maxQty'] is int
          ? json['maxQty']
          : int.tryParse(json['maxQty']?.toString() ?? ''),
    );
  }
}