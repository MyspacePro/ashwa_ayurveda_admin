import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;

  /// 🖼 category image
  final String image;

  /// 🔥 for nested categories (sub-category support)
  final String? parentId;

  /// 🔥 status control
  final bool isActive;

  /// 🔥 timestamp
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.image,
    this.parentId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // =========================
  // 🔄 FROM FIRESTORE
  // =========================
  factory Category.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return Category(
      id: docId,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      parentId: map['parentId'],
      isActive: map['isActive'] ?? true,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  // =========================
  // 🔄 TO FIRESTORE
  // =========================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'parentId': parentId,
      'isActive': isActive,

      /// 🔥 best practice timestamps
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // =========================
  // 🧠 HELPERS
  // =========================

  bool get isRootCategory => parentId == null;

  bool get hasParent => parentId != null;
}