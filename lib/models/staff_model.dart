import 'package:cloud_firestore/cloud_firestore.dart';

enum StaffRole { admin, manager, delivery }

class StaffModel {
  final String id;
  final String name;
  final String email;
  final StaffRole role;
  final List<String> permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final roleString = map['role']?.toString().toLowerCase() ?? 'manager';
    final role = StaffRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => StaffRole.manager,
    );

    return StaffModel(
      id: docId,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: role,
      permissions: (map['permissions'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }


  StaffModel copyWith({
    String? id,
    String? name,
    String? email,
    StaffRole? role,
    List<String>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'name': name,
      'email': email,
      'role': role.name.toUpperCase(),
      'permissions': permissions,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
