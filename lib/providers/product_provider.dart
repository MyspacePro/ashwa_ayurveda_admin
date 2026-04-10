import 'dart:async';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/firebase/firebase_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  ProductProvider(this._firestoreService);

  // =========================
  // 📦 STATE
  // =========================
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<ProductModel>>? _subscription;

  bool _isInitialized = false;

  // =========================
  // 📦 GETTERS
  // =========================
  List<ProductModel> get products => List.unmodifiable(_products);

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isEmpty => _products.isEmpty;

  int get totalProducts => _products.length;

  ProductModel? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // 🚀 INIT (SAFE REALTIME START)
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

    _subscription = _firestoreService.streamProducts().listen(
      (data) {
        _products = data;
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
  // ➕ ADD PRODUCT
  // =========================
  Future<void> addProduct(ProductModel product) async {
    try {
      _clearError();
      await _firestoreService.addProduct(product);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // ✏️ UPDATE PRODUCT (OPTIMISTIC)
  // =========================
  Future<void> updateProduct(ProductModel product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    ProductModel? backup = index != -1 ? _products[index] : null;

    try {
      _clearError();

      // 🔥 Optimistic UI update
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }

      await _firestoreService.updateProduct(product);
    } catch (e) {
      // 🔁 rollback
      if (index != -1 && backup != null) {
        _products[index] = backup;
        notifyListeners();
      }

      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // ❌ DELETE PRODUCT (OPTIMISTIC)
  // =========================
  Future<void> deleteProduct(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);

    if (index == -1) return;

    final backup = _products[index];

    // 🔥 Optimistic remove
    _products.removeAt(index);
    notifyListeners();

    try {
      await _firestoreService.deleteProduct(productId);
    } catch (e) {
      // 🔁 rollback
      _products.insert(index, backup);
      notifyListeners();

      _setError(e.toString());
      rethrow;
    }
  }


  Future<void> updateStock({
    required String productId,
    required int newStock,
  }) async {
    try {
      _clearError();
      await _firestoreService.updateProductStock(
        productId: productId,
        newStock: newStock,
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // 🔄 REFRESH (FORCE RECONNECT)
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
