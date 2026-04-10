import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/firebase/firebase_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  OrderProvider(this._firestoreService);

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalOrders => _orders.length;
  double get totalRevenue =>
      _orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  int get pendingCount =>
      _orders.where((o) => o.status == OrderStatus.pending).length;
  int get deliveredCount =>
      _orders.where((o) => o.status == OrderStatus.delivered).length;

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

  void listenToOrders() {
    _ordersSubscription?.cancel();
    _setLoading(true);
    _clearError();

    _ordersSubscription = _firestoreService.streamOrders().listen(
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

  void listenToUserOrders(String userId) {
    _ordersSubscription?.cancel();
    _setLoading(true);
    _clearError();

    _ordersSubscription = _firestoreService.streamUserOrders(userId).listen(
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
      final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
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

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    final backup = index != -1 ? _orders[index] : null;

    try {
      _clearError();
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
        notifyListeners();
      }

      await _firestoreService.updateOrderStatus(
        orderId: orderId,
        newStatus: status,
      );
    } catch (e) {
      if (index != -1 && backup != null) {
        _orders[index] = backup;
        notifyListeners();
      }
      _setError(e.toString());
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
