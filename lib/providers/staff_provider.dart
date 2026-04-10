import 'dart:async';

import 'package:flutter/material.dart';

import '../models/staff_model.dart';
import '../services/firebase/firebase_service.dart';

class StaffProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  StaffProvider(this._firestoreService);

  List<StaffModel> _staff = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<StaffModel>>? _subscription;

  List<StaffModel> get staff => List.unmodifiable(_staff);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToStaff() {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.streamStaff().listen((data) {
      _staff = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> upsertStaff(StaffModel model) async {
    await _firestoreService.upsertStaff(model);
  }

  bool canAccessDelivery(StaffRole role) => role == StaffRole.admin || role == StaffRole.delivery;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
