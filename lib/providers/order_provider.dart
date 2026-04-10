import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/firebase/firebase_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  // =========================
  // 🔥 CONSTRUCTOR (DI FIXED)
  // =========================
  OrderProvider(this._firestoreService);

  // =========================
  // 📦 STATE
  // =========================

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  bool _isInitialized = false;

  // =========================
  // 📦 GETTERS
  // =========================

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalOrders => _orders.length;

  double get totalRevenue => _orders.fold(
      0.0, (sum, order) => sum + order.totalAmount);

  int get pendingCount =>
      _orders.where((o) => o.status == OrderStatus.pending).length;

  int get deliveredCount =>
      _orders.where((o) => o.status == OrderStatus.delivered).length;

  int get cancelledCount =>
      _orders.where((o) => o.status == OrderStatus.cancelled).length;

  OrderModel? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // 🔄 STATE HELPERS
  // =========================

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
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
  // 🚀 INIT (REALTIME START)
  // =========================

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    listenToOrders();
  }

  // =========================
  // 📥 ALL ORDERS (REALTIME)
  // =========================

  void listenToOrders() {
    _ordersSubscription?.cancel();

    _setLoading(true);
    _clearError();

    _ordersSubscription =
        _firestoreService.streamOrders().listen(
      (ordersList) {
        _orders = ordersList;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  // =========================
  // 👤 USER ORDERS (REALTIME)
  // =========================

  void listenToUserOrders(String userId) {
    _ordersSubscription?.cancel();

    _setLoading(true);
    _clearError();

    _ordersSubscription =
        _firestoreService.streamUserOrders(userId).listen(
      (ordersList) {
        _orders = ordersList;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  // =========================
  // ➕ PLACE ORDER
  // =========================

  Future<String?> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    required double totalAmount,
    required String address,
    required String paymentMethod,
    required PaymentStatus paymentStatus,
    double? deliveryFee,
    double? discount,
  }) async {
    if (items.isEmpty) return null;

    try {
      _clearError();

      final orderId = _generateOrderId();

      final subtotal = items.fold(0.0, (s, i) => s + i.total);
      final finalDelivery = deliveryFee ?? 40.0;
      final finalDiscount = discount ?? 0.0;

      final calculatedTotal =
          subtotal + finalDelivery - finalDiscount;

      final safeTotal =
          totalAmount > 0 ? totalAmount : calculatedTotal;

      final orderMap = {
        "orderId": orderId,
        "userId": userId,
        "items": items.map((e) => e.toJson()).toList(),
        "subtotal": subtotal,
        "deliveryFee": finalDelivery,
        "discount": finalDiscount,
        "totalAmount": safeTotal,
        "address": address,
        "paymentMethod": paymentMethod,
        "paymentStatus": paymentStatus.name,
        "status": OrderStatus.pending.name,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

      await _firestoreService.placeOrder(
        orderId: orderId,
        data: orderMap,
      );

      return orderId;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // =========================
  // 🔄 UPDATE STATUS (OPTIMISTIC)
  // =========================
Future<void> updateOrderStatus({
  required String orderId,
  required OrderStatus status,
}) async {
  final index = _orders.indexWhere((o) => o.id == orderId);
  OrderModel? backup = index != -1 ? _orders[index] : null;

  try {
    _clearError();

    // 🔄 Optimistic UI update
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }

    // 🔥 Firestore update
    await _firestoreService.updateOrder(
      orderId: orderId,
      data: {
        "status": status.name,
        "updatedAt": FieldValue.serverTimestamp(),
      },
    );
  } catch (e) {
    // 🔙 Rollback if failed
    if (index != -1 && backup != null) {
      _orders[index] = backup;
      notifyListeners();
    }

    _setError(e.toString());
  }
}


  // =========================
  // 🔍 FILTERS
  // =========================

  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  List<OrderModel> get pendingOrders =>
      getOrdersByStatus(OrderStatus.pending);

  List<OrderModel> get deliveredOrders =>
      getOrdersByStatus(OrderStatus.delivered);

  List<OrderModel> get cancelledOrders =>
      getOrdersByStatus(OrderStatus.cancelled);

  // =========================
  // 🧹 CLEAR
  // =========================

  void clearOrders() {
    _ordersSubscription?.cancel();
    _orders = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // =========================
  // 🔄 FORCE REFRESH
  // =========================

  Future<void> refresh() async {
    _isInitialized = false;
    listenToOrders();
  }

  // =========================
  // 🧹 DISPOSE
  // =========================

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  // =========================
  // 🔢 ORDER ID
  // =========================

  String _generateOrderId() {
    return "ORD-${DateTime.now().millisecondsSinceEpoch}";
  }
}