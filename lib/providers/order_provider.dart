import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/firebase/firebase_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  OrderProvider(this._firestoreService);

  // =========================
  // 📦 STATE
  // =========================
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<OrderModel>>? _subscription;

  bool _isInitialized = false;

  // =========================
  // 📦 GETTERS
  // =========================
  List<OrderModel> get orders => List.unmodifiable(_orders);

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isEmpty => _orders.isEmpty;

  int get totalOrders => _orders.length;

  double get totalRevenue =>
      _orders.fold(0.0, (sum, o) => sum + o.totalAmount);

  int get pendingCount =>
      _orders.where((o) => o.status == OrderStatus.pending).length;

  int get confirmedCount =>
      _orders.where((o) => o.status == OrderStatus.confirmed).length;

  int get shippedCount =>
      _orders.where((o) => o.status == OrderStatus.shipped).length;

  int get deliveredCount =>
      _orders.where((o) => o.status == OrderStatus.delivered).length;

  int get cancelledCount =>
      _orders.where((o) => o.status == OrderStatus.cancelled).length;

  /// 🔥 Today Revenue (IMPORTANT FOR DASHBOARD)
  double get todayRevenue {
    final today = DateTime.now();
    return _orders.fold(0.0, (sum, order) {
      final date = order.createdAt;
      if (date == null) return sum;
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        return sum + order.totalAmount;
      }
      return sum;
    });
  }

  /// 🔥 Active Orders (Pending + Confirmed + Shipped)
  List<OrderModel> get activeOrders => _orders.where((o) {
        return o.status == OrderStatus.pending ||
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.shipped;
      }).toList();

  // =========================
  // 🚀 INIT
  // =========================
  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
    _startStream();
  }

  void _startStream() {
    _subscription?.cancel();

    _setLoading(true);
    _clearError();

    _subscription = _firestoreService.streamOrders().listen(
      (data) {
        _orders = data;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  /// 👤 USER ORDERS
  void listenToUserOrders(String userId) {
    _subscription?.cancel();

    _setLoading(true);
    _clearError();

    _subscription = _firestoreService.streamUserOrders(userId).listen(
      (data) {
        _orders = data;
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
  }) async {
    if (items.isEmpty) return null;

    try {
      _clearError();

      final subtotal =
          items.fold<double>(0, (sum, item) => sum + item.total);

      final orderId = await _firestoreService.placeOrder({
        'userId': userId,
        'products': items.map((e) => e.toOrderMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': 0,
        'discount': 0,
        'totalAmount': totalAmount > 0 ? totalAmount : subtotal,
        'address': address,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus.name,
      });

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
    final backup = index != -1 ? _orders[index] : null;

    try {
      _clearError();

      /// 🔥 Optimistic update
      if (index != -1) {
        _orders[index] =
            _orders[index].copyWith(status: status);
        notifyListeners();
      }

      await _firestoreService.updateOrderStatus(
        orderId: orderId,
        newStatus: status,
      );
    } catch (e) {
      /// 🔁 rollback
      if (index != -1 && backup != null) {
        _orders[index] = backup;
        notifyListeners();
      }

      _setError(e.toString());
    }
  }

  // =========================
  // 🔄 REFRESH
  // =========================
  Future<void> refresh() async {
    _isInitialized = false;
    _startStream();
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