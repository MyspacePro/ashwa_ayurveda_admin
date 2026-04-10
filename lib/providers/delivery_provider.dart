import 'dart:async';

import 'package:flutter/material.dart';

import '../models/delivery_model.dart';
import '../services/firebase/firebase_service.dart';

class DeliveryProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  DeliveryProvider(this._firestoreService);

  List<DeliveryModel> _deliveries = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<DeliveryModel>>? _subscription;

  List<DeliveryModel> get deliveries => List.unmodifiable(_deliveries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToDeliveries() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.streamDeliveries().listen((data) {
      _deliveries = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateDelivery({
    required String orderId,
    required DeliveryStatus status,
    required String partner,
    required String trackingId,
  }) async {
    await _firestoreService.updateDelivery(
      orderId: orderId,
      status: status,
      deliveryPartner: partner,
      trackingId: trackingId,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
