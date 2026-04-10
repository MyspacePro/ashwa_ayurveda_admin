import 'package:admin_control/services/firebase/review_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _service;

  List<ReviewModel> _reviews = [];
  bool _loading = false;

  ReviewProvider(this._service);

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _loading;

  /// Listen Reviews
  void listenReviews(String productId) {
    _loading = true;
    notifyListeners();

    _service.getReviews(productId).listen((data) {
      _reviews = data;
      _loading = false;
      notifyListeners();
    });
  }

  /// Add Review
  Future<void> addReview({
    required String userId,
    required String productId,
    required int rating,
    required String review,
  }) async {
    final newReview = ReviewModel(
      id: '',
      userId: userId,
      productId: productId,
      rating: rating,
      review: review,
      createdAt: Timestamp.now(),
    );

    await _service.addReview(newReview);
  }

  /// Delete Review
  Future<void> deleteReview(String reviewId) async {
    await _service.deleteReview(reviewId);
  }
}