import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;

  /// 🔥 MULTI IMAGE SUPPORT (FIXED)
  final List<String> images;

  /// 🔥 FIRESTORE CORRECT FIELD
  final String categoryId;

  final double rating;
  final int totalReviews;
  final int stock;

  final bool isFeatured;
  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// 🆕 OPTIONAL
  final double? originalPrice;
  final int? discountPercent;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
    required this.categoryId,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.stock = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.originalPrice,
    this.discountPercent,
  });

  // =========================
  // 🔁 COPY WITH
  // =========================
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    List<String>? images,
    String? categoryId,
    double? rating,
    int? totalReviews,
    int? stock,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? originalPrice,
    int? discountPercent,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }

  // =========================
  // 🔥 FROM FIRESTORE
  // =========================
  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    double toDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int toInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    DateTime? toDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    List<String> toStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ProductModel(
      id: docId,
      name: map['name'] ?? "",
      price: toDouble(map['price']),
      description: map['description'] ?? "",

      /// 🔥 FIXED: images array
      images: toStringList(map['images']),

      /// 🔥 FIXED: categoryId
      categoryId: map['categoryId'] ?? "",

      rating: toDouble(map['rating']),
      totalReviews: toInt(map['totalReviews']),
      stock: toInt(map['stock']),
      isFeatured: map['isFeatured'] ?? false,
      isActive: map['isActive'] ?? true,

      createdAt: toDate(map['createdAt']),
      updatedAt: toDate(map['updatedAt']),

      originalPrice: map['originalPrice'] != null
          ? toDouble(map['originalPrice'])
          : null,

      discountPercent: map['discountPercent'] != null
          ? toInt(map['discountPercent'])
          : null,
    );
  }

  // =========================
  // 🔥 TO FIRESTORE
  // =========================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,

      /// 🔥 FIXED
      'images': images,

      /// 🔥 FIXED
      'categoryId': categoryId,

      'rating': rating,
      'totalReviews': totalReviews,
      'stock': stock,
      'isFeatured': isFeatured,
      'isActive': isActive,

      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      'updatedAt': FieldValue.serverTimestamp(),

      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
    };
  }

  // =========================
  // 🧠 HELPERS
  // =========================

  bool get inStock => stock > 0;

  bool get lowStock => stock > 0 && stock <= 5;

  String get primaryImage =>
      images.isNotEmpty ? images.first : "";

  String get formattedPrice => "₹${price.toStringAsFixed(2)}";

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

  double get discountValue {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return originalPrice! - price;
  }

  int get discount {
    if (discountPercent != null) return discountPercent!;
    if (!hasDiscount) return 0;

    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  double get safeRating => rating.clamp(0, 5);

  String get stockStatus {
    if (stock <= 0) return "Out of Stock";
    if (stock <= 5) return "Only $stock left";
    return "In Stock";
  }
}