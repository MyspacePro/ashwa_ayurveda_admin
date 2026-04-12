import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String review;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.review,
    this.createdAt,
  });

  // =========================
  // 🔁 COPY WITH
  // =========================
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? rating,
    String? review,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // =========================
  // 🔄 FROM FIRESTORE
  // =========================
  factory ReviewModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

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

    return ReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      rating: toInt(data['rating']).clamp(0, 5),
      review: data['review'] ?? '',
      createdAt: toDate(data['createdAt']),
    );
  }

  // =========================
  // 🔼 TO FIRESTORE
  // =========================
  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'userId': userId,
      'productId': productId,
      'rating': rating.clamp(0, 5),
      'review': review,
      if (isCreate)
        'createdAt': FieldValue.serverTimestamp()
      else
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
    };
  }

  // =========================
  // 🧠 HELPERS
  // =========================

  /// ⭐ Safe rating (0–5)
  double get safeRating => rating.clamp(0, 5).toDouble();

  /// 📝 Short preview (UI)
  String get shortReview =>
      review.length > 80 ? "${review.substring(0, 80)}..." : review;

  /// 📅 Formatted date (simple)
  String get formattedDate {
    if (createdAt == null) return '';
    return "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}";
  }

  /// ⭐ Is high rating
  bool get isPositive => rating >= 4;

  /// ⚠️ Low rating
  bool get isNegative => rating <= 2;
}