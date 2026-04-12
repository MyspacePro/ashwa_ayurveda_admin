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
  bool _isDisposed = false;

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

    _setLoading(true, silent: _products.isNotEmpty);
    _clearError();

    _subscription = _firestoreService.streamProducts().listen(
      (data) {
        if (_isDisposed) return;

        _products = data;
        _setLoading(false, silent: true);
        notifyListeners();
      },
      onError: (e) {
        if (_isDisposed) return;

        _setError(_parseError(e));
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
      // stream auto update karega
    } catch (e) {
      _setError(_parseError(e));
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

      // 🔥 Optimistic update
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

      _setError(_parseError(e));
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

      _setError(_parseError(e));
      rethrow;
    }
  }

  // =========================
  // 📦 STOCK UPDATE
  // =========================
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
      _setError(_parseError(e));
      rethrow;
    }
  }

  // =========================
  // 🔄 REFRESH (SAFE RECONNECT)
  // =========================
  Future<void> refresh() async {
    try {
      _isInitialized = false;
      _subscription?.cancel();
      _startStream();
    } catch (e) {
      _setError(_parseError(e));
    }
  }

  // =========================
  // 🔧 HELPERS
  // =========================
  void _setLoading(bool value, {bool silent = false}) {
    if (_isLoading == value) return;
    _isLoading = value;

    if (!silent) notifyListeners();
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

  String _parseError(dynamic e) {
    return e.toString().replaceAll('Exception:', '').trim();
  }

  // =========================
  // 🧹 DISPOSE
  // =========================
  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}