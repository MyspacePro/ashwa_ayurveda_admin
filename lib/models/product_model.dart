import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> images;

  final String categoryId;
  final String subCategoryId;

  final double rating;
  final int totalReviews;

  final int stock;
  final bool isFeatured;
  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final double? originalPrice;
  final int? discountPercent;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
    required this.categoryId,
    this.subCategoryId = '',
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
  // 🔥 SAFE VALUE GETTERS (UPDATED AS PER YOUR NEED)
  // =========================

  double get originalPriceValue =>
      (originalPrice ?? 0.0).toDouble();

  int get discountPercentValue =>
      (discountPercent ?? 0).toInt();

  // =========================
  // COPY WITH
  // =========================
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    List<String>? images,
    String? categoryId,
    String? subCategoryId,
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
      subCategoryId: subCategoryId ?? this.subCategoryId,
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
  // FROM FIRESTORE
  // =========================
  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    int toInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime? toDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    List<String> toStringList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      price: toDouble(map['price']),
      description: map['description'] ?? '',
      images: toStringList(map['images']),
      categoryId: map['categoryId'] ?? '',
      subCategoryId: map['subCategoryId'] ?? '',
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
  // TO FIRESTORE
  // =========================
  Map<String, dynamic> toMap({bool isCreate = false}) {
    final data = {
      'name': name.trim(),
      'price': price,
      'description': description.trim(),
      'images': images,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'rating': rating,
      'totalReviews': totalReviews,
      'stock': stock,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isCreate) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    if (originalPrice != null) {
      data['originalPrice'] = originalPriceValue;
    }

    if (discountPercent != null) {
      data['discountPercent'] = discountPercentValue;
    }

    return data;
  }

  // =========================
  // BUSINESS LOGIC
  // =========================

  bool get inStock => stock > 0;

  bool get lowStock => stock > 0 && stock <= 5;

  String get primaryImage =>
      images.isNotEmpty ? images.first : '';

  double get discountPrice {
    if (discountPercentValue > 0) {
      return price - (price * discountPercentValue / 100);
    }
    return price;
  }

  bool get hasDiscount {
    return discountPercentValue > 0 ||
        originalPriceValue > price;
  }

  int get discount {
    if (discountPercentValue > 0) return discountPercentValue;

    if (originalPriceValue > price) {
      return (((originalPriceValue - price) /
                  originalPriceValue) *
              100)
          .round();
    }

    return 0;
  }

  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: discountPrice % 1 == 0 ? 0 : 2,
    );
    return formatter.format(discountPrice);
  }

  double get safeRating =>
      rating.clamp(0.0, 5.0).toDouble();

  String get stockStatus {
    if (stock <= 0) return 'Out of stock';
    if (lowStock) return 'Low stock';
    return 'In stock';
  }
}