class CartItemModel {
  final String productId;

  /// 🔥 ADD: categoryId (fixes your error + analytics + grouping)
  final String? categoryId;

  final int quantity;
  final double price;

  // UI only (not required in backend)
  final String name;
  final String image;

  const CartItemModel({
    required this.productId,
    this.categoryId,
    required this.quantity,
    required this.price,
    this.name = '',
    this.image = '',
  });

  /// 🔥 total price
  double get total => price * quantity;

  /// 🔥 copyWith
  CartItemModel copyWith({
    String? productId,
    String? categoryId,
    int? quantity,
    double? price,
    String? name,
    String? image,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }

  /// 🔥 to Firestore / Order payload
  Map<String, dynamic> toJson() => toOrderMap();

  Map<String, dynamic> toOrderMap() {
    return {
      'productId': productId,
      'categoryId': categoryId,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  /// 🔥 from Firestore / API
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '0') ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '0') ?? 0;
    }

    return CartItemModel(
      productId: json['productId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      quantity: parseInt(json['quantity']),
      price: parseDouble(json['price'] ?? json['priceAtAdd']),
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
}