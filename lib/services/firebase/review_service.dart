import 'package:admin_control/models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add Review
  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('reviews').add(review.toMap());
  }

  /// Get Reviews by Product
  Stream<List<ReviewModel>> getReviews(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReviewModel.fromDoc(doc)).toList());
  }

  /// Delete Review (Admin/User)
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }
}