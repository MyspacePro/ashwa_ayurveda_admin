import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  final List<String> addressList;
  final List<String> wishlist;

  /// 🔥 ROLE SYSTEM (SCALABLE)
  final String role; // user / admin / super_admin

  /// 🔥 STATUS FLAGS
  final bool isActive;
  final bool isBlocked;

  /// 🔥 TIMESTAMPS
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.addressList = const [],
    this.wishlist = const [],
    this.role = "user",
    this.isActive = true,
    this.isBlocked = false,
    this.createdAt,
    this.updatedAt,
  });

  // =========================
  // 🔄 TO FIRESTORE MAP
  // =========================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'addressList': addressList,
      'wishlist': wishlist,
      'role': role,
      'isActive': isActive,
      'isBlocked': isBlocked,

      /// 🔥 SERVER TIMESTAMPS (BEST PRACTICE)
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // =========================
  // 🔄 FROM FIRESTORE
  // =========================

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? _parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    List<String> _parseList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return UserModel(
      id: docId,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      profileImage: map['profileImage']?.toString(),

      addressList: _parseList(map['addressList']),
      wishlist: _parseList(map['wishlist']),

      role: map['role']?.toString() ?? "user",
      isActive: map['isActive'] ?? true,
      isBlocked: map['isBlocked'] ?? false,

      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  // =========================
  // 🔁 COPY WITH
  // =========================

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    List<String>? addressList,
    List<String>? wishlist,
    String? role,
    bool? isActive,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      addressList: addressList ?? this.addressList,
      wishlist: wishlist ?? this.wishlist,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================
  // 🧠 HELPERS
  // =========================

  bool get isAdmin => role == "admin" || role == "super_admin";

  bool get isUser => role == "user";

  bool get canLogin => isActive && !isBlocked;

  // =========================
  // ⚖️ EQUALITY (IMPORTANT)
  // =========================

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}