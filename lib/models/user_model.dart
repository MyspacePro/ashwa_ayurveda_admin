import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final List<String> addressList;
  final List<String> wishlist;
  final String role;
  final bool isActive;
  final bool isBlocked;
  final int totalOrders;
  final double totalSpent;
  final double walletBalance;
  final String kycStatus;
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
    this.role = 'user',
    this.isActive = true,
    this.isBlocked = false,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.walletBalance = 0,
    this.kycStatus = 'PENDING',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'addressList': addressList,
      'wishlist': wishlist,
      'role': role,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'walletBalance': walletBalance,
      'kycStatus': kycStatus,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    List<String> parseList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return const [];
    }

    return UserModel(
      id: docId,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      profileImage: map['profileImage']?.toString(),
      addressList: parseList(map['addressList']),
      wishlist: parseList(map['wishlist']),
      role: map['role']?.toString() ?? 'user',
      isActive: map['isActive'] ?? true,
      isBlocked: map['isBlocked'] ?? false,
      totalOrders: (map['totalOrders'] ?? 0) as int,
      totalSpent: (map['totalSpent'] is num)
          ? (map['totalSpent'] as num).toDouble()
          : double.tryParse(map['totalSpent']?.toString() ?? '0') ?? 0,
      walletBalance: (map['walletBalance'] is num)
          ? (map['walletBalance'] as num).toDouble()
          : double.tryParse(map['walletBalance']?.toString() ?? '0') ?? 0,
      kycStatus: map['kycStatus']?.toString() ?? 'PENDING',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

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
    int? totalOrders,
    double? totalSpent,
    double? walletBalance,
    String? kycStatus,
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
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      walletBalance: walletBalance ?? this.walletBalance,
      kycStatus: kycStatus ?? this.kycStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get canLogin => isActive && !isBlocked;
}
