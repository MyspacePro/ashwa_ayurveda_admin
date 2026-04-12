import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';
import '../services/firebase/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _service;

  ReviewProvider(this._service);

  // =========================
  // 📦 STATE
  // =========================

  List<ReviewModel> _reviews = [];

  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<ReviewModel>>? _subscription;

  bool _isInitialized = false;
  String? _currentProductId;

  // =========================
  // 📦 GETTERS
  // =========================

  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalReviews => _reviews.length;

  double get averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  // =========================
  // 🚀 INIT (SAFE)
  // =========================

  void init(String productId) {
    if (_isInitialized && _currentProductId == productId) return;

    _currentProductId = productId;
    _isInitialized = true;

    _startListener(productId);
  }

  void _startListener(String productId) {
    _subscription?.cancel();

    _setLoading(true);
    _clearError();

    _subscription = _service.getReviews(productId).listen(
      (data) {
        _reviews = data;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }


void listenReviews(String productId) {
  _subscription?.cancel();

  _isLoading = true;
  notifyListeners();

  _subscription = _service.getReviews(productId).listen(
    (data) {
      _reviews = data;
      _isLoading = false;
      notifyListeners();
    },
    onError: (e) {
      _isLoading = false;
      notifyListeners();
    },
  );
}

  // =========================
  // ➕ ADD REVIEW
  // =========================

  Future<void> addReview({
    required String userId,
    required String productId,
    required int rating,
    required String review,
  }) async {
    try {
      _clearError();

      final newReview = ReviewModel(
        id: '',
        userId: userId,
        productId: productId,
        rating: rating,
        review: review,
        createdAt: DateTime.now(),
      );

      await _service.addReview(newReview);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // ❌ DELETE (OPTIMISTIC)
  // =========================

  Future<void> deleteReview(String reviewId) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);

    if (index == -1) return;

    final backup = _reviews[index];

    // 🔥 Optimistic remove
    _reviews.removeAt(index);
    notifyListeners();

    try {
      await _service.deleteReview(reviewId);
    } catch (e) {
      // 🔁 rollback
      _reviews.insert(index, backup);
      notifyListeners();

      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // 🔄 REFRESH
  // =========================

  Future<void> refresh() async {
    if (_currentProductId == null) return;

    _isInitialized = false;
    _startListener(_currentProductId!);
  }

  // =========================
  // 🔧 HELPERS
  // =========================

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // =========================
  // 🧹 DISPOSE
  // =========================

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}