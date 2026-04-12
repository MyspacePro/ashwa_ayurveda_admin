import 'dart:async';
import 'package:flutter/material.dart';

import '../models/delivery_model.dart';
import '../services/firebase/firebase_service.dart';

class DeliveryProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  DeliveryProvider(this._firestoreService);

  // =========================
  // 📦 STATE
  // =========================

  List<DeliveryModel> _deliveries = [];

  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<DeliveryModel>>? _subscription;
  bool _isInitialized = false;

  // =========================
  // 📦 GETTERS
  // =========================

  List<DeliveryModel> get deliveries => List.unmodifiable(_deliveries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalDeliveries => _deliveries.length;

  int get pendingDeliveries =>
      _deliveries.where((d) => d.deliveryStatus == DeliveryStatus.pending).length;

  int get shippedDeliveries =>
      _deliveries.where((d) => d.deliveryStatus == DeliveryStatus.shipped).length;

  int get deliveredDeliveries =>
      _deliveries.where((d) => d.deliveryStatus == DeliveryStatus.delivered).length;

  int get failedDeliveries =>
      _deliveries.where((d) => d.deliveryStatus == DeliveryStatus.failed).length;

  DeliveryModel? getByOrderId(String orderId) {
    try {
      return _deliveries.firstWhere((d) => d.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // 🚀 INIT (SAFE)
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

    _subscription = _firestoreService.streamDeliveries().listen(
      (data) {
        _deliveries = data;
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
  // 🔄 UPDATE DELIVERY (OPTIMISTIC)
  // =========================

  Future<void> updateDelivery({
    required String orderId,
    required DeliveryStatus status,
    required String partner,
    required String trackingId,
  }) async {
    final index =
        _deliveries.indexWhere((d) => d.orderId == orderId);

    DeliveryModel? backup =
        index != -1 ? _deliveries[index] : null;

    try {
      _clearError();

      // 🔥 Optimistic update
      if (index != -1) {
        _deliveries[index] = _deliveries[index].copyWith(
          deliveryStatus: status,
          deliveryPartner: partner,
          trackingId: trackingId,
        );
        notifyListeners();
      }

      await _firestoreService.updateDelivery(
        orderId: orderId,
        status: status,
        deliveryPartner: partner,
        trackingId: trackingId,
      );
    } catch (e) {
      // 🔁 rollback
      if (index != -1 && backup != null) {
        _deliveries[index] = backup;
        notifyListeners();
      }

      _setError(e.toString());
      rethrow;
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