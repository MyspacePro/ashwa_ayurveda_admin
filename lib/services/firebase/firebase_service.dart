import 'package:admin_control/models/category_model.dart' as category_model;
import 'package:admin_control/models/order_model.dart';
import 'package:admin_control/models/product_model.dart';
import 'package:admin_control/models/subcategory_model.dart';
import 'package:admin_control/models/delivery_model.dart';
import 'package:admin_control/models/staff_model.dart';
import 'package:admin_control/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get products => _db.collection('products');
  CollectionReference<Map<String, dynamic>> get categories => _db.collection('categories');
  CollectionReference<Map<String, dynamic>> get subcategories => _db.collection('subcategories');
  CollectionReference<Map<String, dynamic>> get orders => _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get staff => _db.collection('staff');

  Exception _error(dynamic e) {
    debugPrint('🔥 Firestore Error: $e');
    return Exception(e.toString());
  }

  List<T> _mapList<T>(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    T Function(Map<String, dynamic>, String id) fromMap,
  ) {
    return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> createUser(UserModel user) async {
    try {
      await users.doc(user.id).set(user.toMap(isCreate: true));
    } catch (e) {
      throw _error(e);
    }
  }

  Stream<List<UserModel>> streamUsers({int limit = 200}) {
    return users
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => _mapList(snap, UserModel.fromMap));
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await users.doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await users.doc(userId).delete();
    } catch (e) {
      throw _error(e);
    }
  }

  Stream<List<ProductModel>> streamProducts() {
    return products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => _mapList(snap, ProductModel.fromMap));
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = products.doc();
      await docRef.set({
        ...product.copyWith(id: docRef.id).toMap(isCreate: true),
      });
      return docRef.id;
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await products.doc(product.id).update(product.toMap());
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> updateProductStock({
    required String productId,
    required int newStock,
  }) async {
    try {
      await products.doc(productId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await products.doc(id).delete();
    } catch (e) {
      throw _error(e);
    }
  }

  Stream<List<category_model.Category>> streamCategories() {
    return categories
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.docs
                  .map(
                    (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                        category_model.Category.fromMap(doc.data(), doc.id),
                  )
                  .toList(),
        );
  }

  Stream<List<SubCategory>> streamSubCategories({String? categoryId}) {
    Query<Map<String, dynamic>> query = subcategories.orderBy('name');
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    return query.snapshots().map((snap) => _mapList(snap, SubCategory.fromMap));
  }

  Future<void> addCategory(Map<String, dynamic> data) async {
    try {
      final docRef = categories.doc();
      await docRef.set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': data['isActive'] ?? true,
      });
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await categories.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await categories.doc(id).delete();
    } catch (e) {
      throw _error(e);
    }
  }

  Stream<List<OrderModel>> streamOrders() {
    return orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => _mapList(snap, OrderModel.fromMap));
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return orders
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => _mapList(snap, OrderModel.fromMap));
  }

  Future<String> placeOrder(Map<String, dynamic> data) async {
    try {
      final docRef = orders.doc();
      await _db.runTransaction((txn) async {
        txn.set(docRef, {
          ...data,
          'orderId': docRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

        final userId = data['userId']?.toString() ?? '';
        if (userId.isNotEmpty) {
          final userRef = users.doc(userId);
          txn.update(userRef, {
            'totalOrders': FieldValue.increment(1),
            'totalSpent': FieldValue.increment((data['totalAmount'] as num).toDouble()),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      return docRef.id;
    } catch (e) {
      throw _error(e);
    }
  }


  Stream<List<DeliveryModel>> streamDeliveries() {
    return orders.orderBy('updatedAt', descending: true).snapshots().map(
      (snap) => snap.docs
          .map((doc) => DeliveryModel.fromOrderMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> updateDelivery({
    required String orderId,
    required DeliveryStatus status,
    required String deliveryPartner,
    required String trackingId,
  }) async {
    final model = DeliveryModel(
      orderId: orderId,
      deliveryStatus: status,
      deliveryPartner: deliveryPartner,
      trackingId: trackingId,
    );

    try {
      await orders.doc(orderId).update(model.toMap());
      await orders.doc(orderId).collection('delivery_logs').add({
        ...model.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _error(e);
    }
  }

  Stream<List<StaffModel>> streamStaff() {
    return staff.orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => StaffModel.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  Future<void> upsertStaff(StaffModel model) async {
    try {
      final doc = model.id.isEmpty ? staff.doc() : staff.doc(model.id);
      await doc.set(model.copyWith(id: doc.id).toMap(isCreate: model.id.isEmpty));
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    try {
      final orderRef = orders.doc(orderId);
      await _db.runTransaction((txn) async {
        final snapshot = await txn.get(orderRef);
        if (!snapshot.exists) throw Exception('Order not found: $orderId');

        final current = OrderModel.fromMap(snapshot.data()!, snapshot.id).status;
        if (!_isValidStatusTransition(current, newStatus)) {
          throw Exception('Invalid status transition: ${current.name} -> ${newStatus.name}');
        }

        txn.update(orderRef, {
          'status': newStatus.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw _error(e);
    }
  }

  bool _isValidStatusTransition(OrderStatus current, OrderStatus next) {
    if (current == next) return true;
    const flow = {
      OrderStatus.pending: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.confirmed: [OrderStatus.shipped, OrderStatus.cancelled],
      OrderStatus.shipped: [OrderStatus.delivered, OrderStatus.cancelled],
      OrderStatus.delivered: <OrderStatus>[],
      OrderStatus.cancelled: <OrderStatus>[],
    };
    return flow[current]?.contains(next) ?? false;
  }
}
