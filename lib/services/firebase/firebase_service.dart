import 'package:admin_control/models/category_model.dart';
import 'package:admin_control/models/order_model.dart';
import 'package:admin_control/models/product_model.dart';
import 'package:admin_control/models/subcategory_model.dart';
import 'package:admin_control/models/delivery_model.dart';
import 'package:admin_control/models/staff_model.dart';
import 'package:admin_control/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// =========================
  /// 🔥 COLLECTIONS
  /// =========================
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  CollectionReference<Map<String, dynamic>> get users => collection('users');
  CollectionReference<Map<String, dynamic>> get products => collection('products');
  CollectionReference<Map<String, dynamic>> get categories => collection('categories');
  CollectionReference<Map<String, dynamic>> get subcategories => collection('subcategories');
  CollectionReference<Map<String, dynamic>> get orders => collection('orders');
  CollectionReference<Map<String, dynamic>> get staff => collection('staff');

  /// =========================
  /// 🔥 ERROR HANDLING
  /// =========================
  Exception _error(dynamic e) {
    debugPrint('🔥 Firestore Error: $e');
    return Exception(e.toString());
  }

  /// =========================
  /// 🔥 COMMON HELPERS
  /// =========================
  Map<String, dynamic> _withTimestamps(Map<String, dynamic> data,
      {bool isCreate = false}) {
    return {
      ...data,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  List<T> _mapList<T>(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    T Function(Map<String, dynamic>, String id) fromMap,
  ) {
    return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  }

  /// =========================
  /// 🔥 GENERIC CRUD (FUTURE PROOF)
  /// =========================
  Future<String> createDoc({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final doc = collection(path).doc();
      await doc.set(_withTimestamps(data, isCreate: true));
      return doc.id;
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> updateDoc({
    required String path,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await collection(path).doc(id).update(_withTimestamps(data));
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> deleteDoc({
    required String path,
    required String id,
  }) async {
    try {
      await collection(path).doc(id).delete();
    } catch (e) {
      throw _error(e);
    }
  }

  /// =========================
  /// 👤 USERS
  /// =========================
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
    return updateDoc(path: 'users', id: userId, data: data);
  }

  Future<void> deleteUser(String userId) async {
    return deleteDoc(path: 'users', id: userId);
  }

  /// =========================
  /// 📦 PRODUCTS
  /// =========================
  Stream<List<ProductModel>> streamProducts() {
    return products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => _mapList(snap, ProductModel.fromMap));
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = products.doc();
      await docRef.set(
        product.copyWith(id: docRef.id).toMap(isCreate: true),
      );
      return docRef.id;
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    return updateDoc(
      path: 'products',
      id: product.id,
      data: product.toMap(),
    );
  }

  Future<void> updateProductStock({
    required String productId,
    required int newStock,
  }) async {
    return updateDoc(
      path: 'products',
      id: productId,
      data: {'stock': newStock},
    );
  }

  Future<void> deleteProduct(String id) async {
    return deleteDoc(path: 'products', id: id);
  }

  /// =========================
  /// 🗂️ CATEGORIES
  /// =========================
  Stream<List<CategoryModel>> streamCategories() {
    return categories
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _mapList(snapshot, CategoryModel.fromMap));
  }

  Future<void> addCategory(Map<String, dynamic> data) async {
    await createDoc(path: 'categories', data: data);
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await updateDoc(path: 'categories', id: id, data: data);
  }

  Future<void> deleteCategory(String id) async {
    await deleteDoc(path: 'categories', id: id);
  }

  Stream<List<SubCategory>> streamSubCategories({String? categoryId}) {
    Query<Map<String, dynamic>> query =
        subcategories.orderBy('name');

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.snapshots().map((snap) => _mapList(snap, SubCategory.fromMap));
  }

  /// =========================
  /// 📦 ORDERS
  /// =========================
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
        txn.set(docRef, _withTimestamps({
          ...data,
          'orderId': docRef.id,
          'status': 'pending',
        }, isCreate: true));

        final userId = data['userId']?.toString() ?? '';
        if (userId.isNotEmpty) {
          txn.update(users.doc(userId), {
            'totalOrders': FieldValue.increment(1),
            'totalSpent': FieldValue.increment(
              (data['totalAmount'] as num).toDouble(),
            ),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      return docRef.id;
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
        if (!snapshot.exists) throw Exception('Order not found');

        final current =
            OrderModel.fromMap(snapshot.data()!, snapshot.id).status;

        if (!_isValidStatusTransition(current, newStatus)) {
          throw Exception(
              'Invalid transition: ${current.name} → ${newStatus.name}');
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
      OrderStatus.delivered: [],
      OrderStatus.cancelled: [],
    };

    return flow[current]?.contains(next) ?? false;
  }

  /// =========================
  /// 🚚 DELIVERY
  /// =========================
  Stream<List<DeliveryModel>> streamDeliveries() {
    return orders
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                DeliveryModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateDelivery({
    required String orderId,
    required DeliveryStatus status,
    required String deliveryPartner,
    required String trackingId,
  }) async {
    try {
      final model = DeliveryModel(
        orderId: orderId,
        deliveryStatus: status,
        deliveryPartner: deliveryPartner,
        trackingId: trackingId,
      );

      await orders.doc(orderId).update(model.toMap());

      await orders.doc(orderId).collection('delivery_logs').add({
        ...model.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _error(e);
    }
  }

  /// =========================
  /// 👨‍💼 STAFF
  /// =========================
  Stream<List<StaffModel>> streamStaff() {
    return staff
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => StaffModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> upsertStaff(StaffModel model) async {
    try {
      final doc = model.id.isEmpty ? staff.doc() : staff.doc(model.id);

      await doc.set(
        model.copyWith(id: doc.id).toMap(isCreate: model.id.isEmpty),
      );
    } catch (e) {
      throw _error(e);
    }
  }
}