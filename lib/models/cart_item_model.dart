class CartItemModel {
  final String productId;
  final int quantity;
  final double price;

  // Optional UI helpers (not persisted in order payload)
  final String name;
  final String image;

  const CartItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
    this.name = '',
    this.image = '',
  });

  double get total => price * quantity;

  CartItemModel copyWith({
    String? productId,
    int? quantity,
    double? price,
    String? name,
    String? image,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toJson() => toOrderMap();

  Map<String, dynamic> toOrderMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '0') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '0') ?? 0;
    }

    return CartItemModel(
      productId: json['productId']?.toString() ?? '',
      quantity: parseInt(json['quantity']),
      price: parseDouble(json['price'] ?? json['priceAtAdd']),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}
