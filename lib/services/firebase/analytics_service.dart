import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/analytics_model.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Collection reference
  final String _collection = "analytics";
  final String _doc = "dashboard";

  /// ================================
  /// 📥 FETCH DASHBOARD ANALYTICS
  /// ================================
  Future<AnalyticsModel> fetchDashboardAnalytics() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_doc).get();

      if (!doc.exists) {
        return AnalyticsModel.empty();
      }

      return AnalyticsModel.fromMap(doc.data());
    } catch (e) {
      print("❌ Error fetching analytics: $e");
      return AnalyticsModel.empty();
    }
  }

  /// ================================
  /// 🔄 REAL-TIME LISTENER (BEST)
  /// ================================
  Stream<AnalyticsModel> listenDashboardAnalytics() {
    return _firestore
        .collection(_collection)
        .doc(_doc)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return AnalyticsModel.empty();
      return AnalyticsModel.fromMap(snapshot.data());
    });
  }

  /// ================================
  /// ➕ UPDATE ANALYTICS (ORDER)
  /// ================================
  Future<void> updateOnOrder({
    required double amount,
    required bool isToday,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        "totalOrders": FieldValue.increment(1),
        "totalRevenue": FieldValue.increment(amount),
        "lastUpdated": FieldValue.serverTimestamp(),
      };

      if (isToday) {
        updateData["todayOrders"] = FieldValue.increment(1);
        updateData["todayRevenue"] = FieldValue.increment(amount);
      }

      await _firestore
          .collection(_collection)
          .doc(_doc)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      print("❌ Error updating order analytics: $e");
    }
  }

  /// ================================
  /// ➕ UPDATE ANALYTICS (USER)
  /// ================================
  Future<void> updateOnUserCreate() async {
    try {
      await _firestore.collection(_collection).doc(_doc).set({
        "totalUsers": FieldValue.increment(1),
        "lastUpdated": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Error updating user analytics: $e");
    }
  }

  /// ================================
  /// 🔥 UPDATE TOP PRODUCTS
  /// ================================
  Future<void> updateTopProducts({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final batch = _firestore.batch();

      for (var item in items) {
        final docRef = _firestore
            .collection(_collection)
            .doc("products")
            .collection("topProducts")
            .doc(item['productId']);

        batch.set(docRef, {
          "productId": item['productId'],
          "name": item['name'],
          "totalSold": FieldValue.increment(item['quantity']),
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print("❌ Error updating top products: $e");
    }
  }

  /// ================================
  /// 📊 FETCH TOP PRODUCTS
  /// ================================
  Future<List<Map<String, dynamic>>> fetchTopProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc("products")
          .collection("topProducts")
          .orderBy("totalSold", descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("❌ Error fetching top products: $e");
      return [];
    }
  }

  /// ================================
  /// 🔄 RESET DAILY STATS (MANUAL)
  /// ================================
  Future<void> resetDailyStats() async {
    try {
      await _firestore.collection(_collection).doc(_doc).update({
        "todayOrders": 0,
        "todayRevenue": 0,
        "lastUpdated": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Error resetting daily stats: $e");
    }
  }
}