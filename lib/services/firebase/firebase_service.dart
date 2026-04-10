import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_control/models/order_model.dart';
import 'package:admin_control/models/product_model.dart';
import 'package:admin_control/models/user_model.dart';



class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // 🔹 COLLECTION REFERENCES (TYPED)
  // =========================
  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get products =>
      _db.collection('products');

  CollectionReference<Map<String, dynamic>> get categories =>
      _db.collection('categories');

  CollectionReference<Map<String, dynamic>> get carts =>
      _db.collection('cart');

  CollectionReference<Map<String, dynamic>> get orders =>
      _db.collection('orders');

  // =========================
  // ⚠️ ERROR HANDLER
  // =========================
  Exception _error(dynamic e) {
    debugPrint("🔥 Firestore Error: $e");
    return Exception(e.toString());
  }

  // =========================
  // 🔄 COMMON MAPPER
  // =========================
  List<T> _mapList<T>(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    T Function(Map<String, dynamic>, String id) fromMap,
  ) {
    return snapshot.docs
        .map((doc) => fromMap(doc.data(), doc.id))
        .toList();
  }

  // =========================
  // 👤 USER MODULE (REALTIME FIRST)
  // =========================

  Future<void> createUser(UserModel user) async {
    try {
      await users.doc(user.id).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isBlocked': false,
      });
    } catch (e) {
      throw _error(e);
    }
  }

  /// 🔥 REALTIME USERS (MAIN SOURCE)
  Stream<List<UserModel>> streamUsers() {
    return users
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => _mapList(snap, UserModel.fromMap));
  }

  Future<UserModel> getUser(String uid) async {
    try {
      final doc = await users.doc(uid).get();

      if (!doc.exists) {
        throw Exception("User not found");
      }

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw _error(e);
    }
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

  // =========================
  // 🛍️ PRODUCT MODULE (REALTIME)
  // =========================

  Stream<List<ProductModel>> streamProducts() {
    return products
        
        .snapshots()
        .map((snap) => _mapList(snap, ProductModel.fromMap));
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      final docRef = products.doc();

      await docRef.set({
        ...product.toMap(),
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await products.doc(product.id).update({
        ...product.toMap(),
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

  Future<ProductModel> getProductById(String id) async {
    try {
      final doc = await products.doc(id).get();
      return ProductModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw _error(e);
    }
  }

  // =========================
  // 📂 CATEGORY MODULE (REALTIME)
  // =========================

  Stream<List<Map<String, dynamic>>> streamCategories() {
  return categories
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return {
        ...data,
        'id': doc.id,
      };
    }).toList();  });
  }

  Future<void> addCategory(Map<String, dynamic> data) async {
    try {
      final docRef = categories.doc();

      await docRef.set({
        ...data,
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
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

  // =========================
  // 🛒 CART MODULE (REALTIME)
  // =========================

  Stream<List<Map<String, dynamic>>> streamCart(String userId) {
    return carts
        .doc(userId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    });
  }

  Future<void> addToCart({
    required String userId,
    required Map<String, dynamic> item,
  }) async {
    try {
      await carts.doc(userId).collection('items').add({
        ...item,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> removeFromCart({
    required String userId,
    required String itemId,
  }) async {
    try {
      await carts.doc(userId).collection('items').doc(itemId).delete();
    } catch (e) {
      throw _error(e);
    }
  }

  // =========================
  // 📦 ORDER MODULE (REALTIME)
  // =========================

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

  Future<void> placeOrder({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await orders.doc(orderId).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      throw _error(e);
    }
  }

  Future<void> updateOrder({
    required String orderId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await orders.doc(orderId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _error(e);
    }
  }
}