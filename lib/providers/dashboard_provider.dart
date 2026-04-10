import 'dart:async';
import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../services/firebase/firebase_service.dart';

class DashboardProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  DashboardProvider(this._firestoreService);

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

  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalOrders => _orders.length;

  double get totalRevenue =>
      _orders.fold(0.0, (sum, o) => sum + o.totalAmount);

  int get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).length;

  int get deliveredOrders =>
      _orders.where((o) => o.status == OrderStatus.delivered).length;

  int get cancelledOrders =>
      _orders.where((o) => o.status == OrderStatus.cancelled).length;

  double get averageOrderValue =>
      _orders.isEmpty ? 0 : totalRevenue / _orders.length;

  // =========================
  // 📅 DATE HELPERS
  // =========================

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _isSameWeek(DateTime date, DateTime now) {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(startOfWeek);
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  // =========================
  // 📊 TIME BASED REVENUE
  // =========================

  double get todayRevenue {
    final now = DateTime.now();

    return _orders
        .where((o) =>
            o.createdAt != null &&
            _isSameDay(o.createdAt!, now))
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get weeklyRevenue {
    final now = DateTime.now();

    return _orders
        .where((o) =>
            o.createdAt != null &&
            _isSameWeek(o.createdAt!, now))
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get monthlyRevenue {
    final now = DateTime.now();

    return _orders
        .where((o) =>
            o.createdAt != null &&
            _isSameMonth(o.createdAt!, now))
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  // =========================
  // 📈 GROWTH %
  // =========================

  double get todayGrowth {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final today = _orders
        .where((o) =>
            o.createdAt != null &&
            _isSameDay(o.createdAt!, now))
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    final yesterdayRevenue = _orders
        .where((o) =>
            o.createdAt != null &&
            _isSameDay(o.createdAt!, yesterday))
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    if (yesterdayRevenue == 0) return 0;

    return ((today - yesterdayRevenue) / yesterdayRevenue) * 100;
  }

  // =========================
  // 🏆 TOP PRODUCTS
  // =========================

  Map<String, int> get topProducts {
    final Map<String, int> productCount = {};

    for (var order in _orders) {
      for (var item in order.items) {
        productCount[item.productId] =
            (productCount[item.productId] ?? 0) + item.quantity;
      }
    }

    final sorted = productCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(5));
  }

  // =========================
  // 📈 CHART DATA
  // =========================

  Map<String, double> get last7DaysRevenue {
    final Map<String, double> data = {};

    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));

      final revenue = _orders
          .where((o) =>
              o.createdAt != null &&
              _isSameDay(o.createdAt!, day))
          .fold(0.0, (sum, o) => sum + o.totalAmount);

      data["${day.day}/${day.month}"] = revenue;
    }

    return data;
  }

  // =========================
  // 🚀 INIT (REALTIME)
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

    /// 🔥 FIXED: Direct List<OrderModel>
    _subscription = _firestoreService.streamOrders().listen(
      (ordersList) {
        _orders = ordersList;
        _setLoading(false);
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
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
    _error = null;
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
