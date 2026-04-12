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

  List<OrderModel> get validOrders =>
      _orders.where((o) => o.status != OrderStatus.cancelled).toList();

  int get totalOrders => validOrders.length;

  double get totalRevenue =>
      validOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

  int get pendingOrders =>
      validOrders.where((o) => o.status == OrderStatus.pending).length;

  int get deliveredOrders =>
      validOrders.where((o) => o.status == OrderStatus.delivered).length;

  int get cancelledOrders =>
      _orders.where((o) => o.status == OrderStatus.cancelled).length;

  double get averageOrderValue =>
      validOrders.isEmpty ? 0 : totalRevenue / validOrders.length;

  // =========================
  // 📅 SAFE DATE HELPERS (FIXED NULL SAFETY)
  // =========================

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month;
  }

  bool _isSameWeek(DateTime? date, DateTime now) {
    if (date == null) return false;

    final startOfWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  // =========================
  // 📊 TIME BASED REVENUE
  // =========================

  double get todayRevenue {
    final now = DateTime.now();

    return validOrders
        .where((o) => _isSameDay(o.createdAt, now))
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get weeklyRevenue {
    final now = DateTime.now();

    return validOrders
        .where((o) => _isSameWeek(o.createdAt, now))
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get monthlyRevenue {
    final now = DateTime.now();

    return validOrders
        .where((o) => _isSameMonth(o.createdAt, now))
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  // =========================
  // 📈 GROWTH %
  // =========================

  double get todayGrowth {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final today = validOrders
        .where((o) => _isSameDay(o.createdAt, now))
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    final yesterdayRevenue = validOrders
        .where((o) => _isSameDay(o.createdAt, yesterday))
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    if (yesterdayRevenue == 0) return 0;

    return ((today - yesterdayRevenue) / yesterdayRevenue) * 100;
  }

  // =========================
  // 🏆 TOP PRODUCTS
  // =========================

  Map<String, int> get topProducts {
    final Map<String, int> productCount = {};

    for (final order in validOrders) {
      for (final item in order.products) {
        productCount[item.productId] =
            (productCount[item.productId] ?? 0) + item.quantity;
      }
    }

    final sorted = productCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(5));
  }

  // =========================
  // 📈 LAST 7 DAYS REVENUE
  // =========================

  Map<String, double> get last7DaysRevenue {
    final Map<String, double> data = {};

    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));

      final revenue = validOrders
          .where((o) => _isSameDay(o.createdAt, day))
          .fold(0.0, (sum, o) => sum + o.totalAmount);

      data["${day.day}/${day.month}"] = revenue;
    }

    return data;
  }

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