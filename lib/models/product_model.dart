import 'package:cloud_firestore/cloud_firestore.dart';

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

  ProductModel({
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
      originalPrice:
          map['originalPrice'] != null ? toDouble(map['originalPrice']) : null,
      discountPercent:
          map['discountPercent'] != null ? toInt(map['discountPercent']) : null,
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'name': name,
      'price': price,
      'description': description,
      'images': images,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'rating': rating,
      'totalReviews': totalReviews,
      'stock': stock,
      'isFeatured': isFeatured,
      'isActive': isActive,
      if (isCreate)
        'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
    };
  }

  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 5;
  String get primaryImage => images.isNotEmpty ? images.first : '';
}
