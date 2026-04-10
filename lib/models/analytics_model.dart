import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsModel {
  final int totalUsers;
  final int totalOrders;
  final double totalRevenue;
  final int todayOrders;
  final double todayRevenue;
  final Timestamp? lastUpdated;

  AnalyticsModel({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalRevenue,
    required this.todayOrders,
    required this.todayRevenue,
    this.lastUpdated,
  });

  /// 🔹 Empty / Default State (important for safety)
  factory AnalyticsModel.empty() {
    return AnalyticsModel(
      totalUsers: 0,
      totalOrders: 0,
      totalRevenue: 0,
      todayOrders: 0,
      todayRevenue: 0,
      lastUpdated: null,
    );
  }

  /// 🔹 From Firestore
  factory AnalyticsModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) return AnalyticsModel.empty();

    return AnalyticsModel(
      totalUsers: (data['totalUsers'] ?? 0) as int,
      totalOrders: (data['totalOrders'] ?? 0) as int,
      totalRevenue: (data['totalRevenue'] ?? 0).toDouble(),
      todayOrders: (data['todayOrders'] ?? 0) as int,
      todayRevenue: (data['todayRevenue'] ?? 0).toDouble(),
      lastUpdated: data['lastUpdated'] as Timestamp?,
    );
  }

  /// 🔹 To Firestore (for saving/updating)
  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'todayOrders': todayOrders,
      'todayRevenue': todayRevenue,
      'lastUpdated': lastUpdated ?? FieldValue.serverTimestamp(),
    };
  }

  /// 🔹 CopyWith (for state updates)
  AnalyticsModel copyWith({
    int? totalUsers,
    int? totalOrders,
    double? totalRevenue,
    int? todayOrders,
    double? todayRevenue,
    Timestamp? lastUpdated,
  }) {
    return AnalyticsModel(
      totalUsers: totalUsers ?? this.totalUsers,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      todayOrders: todayOrders ?? this.todayOrders,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 🔹 Debug / Log
  @override
  String toString() {
    return '''
AnalyticsModel(
  totalUsers: $totalUsers,
  totalOrders: $totalOrders,
  totalRevenue: $totalRevenue,
  todayOrders: $todayOrders,
  todayRevenue: $todayRevenue,
  lastUpdated: $lastUpdated
)
''';
  }
}