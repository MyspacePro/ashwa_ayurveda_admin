import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return Category(
      id: docId,
      name: map['name']?.toString() ?? '',
      icon: map['icon']?.toString() ?? map['imageUrl']?.toString() ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'name': name,
      'icon': icon,
      'isActive': isActive,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
