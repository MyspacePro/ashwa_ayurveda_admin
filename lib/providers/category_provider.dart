import 'dart:async';
import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/firebase/firebase_service.dart';

class CategoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  // =========================
  // 🔥 CONSTRUCTOR (DI FIXED)
  // =========================
  CategoryProvider(this._firestoreService);

  // =========================
  // 📦 STATE
  // =========================

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  bool _isInitialized = false;

  // =========================
  // 📦 GETTERS
  // =========================

  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isEmpty => _categories.isEmpty;
  int get totalCategories => _categories.length;

  Category? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
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

    _startStream();
  }

  void _startStream() {
  _subscription?.cancel();

  _setLoading(true);
  _clearError();

  _subscription = _firestoreService.streamCategories().listen(
    (data) {
      _categories = data.cast<Category>();
      _setLoading(false);
      notifyListeners();
    },
    onError: (e) {
      _setError(e.toString());
      _setLoading(false);   },
    );
  }

  // =========================
  // ➕ ADD CATEGORY
  // =========================

  Future<void> addCategory(Category category) async {
    try {
      _clearError();
      await _firestoreService.addCategory(category.toMap());
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // ✏️ UPDATE CATEGORY (OPTIMISTIC)
  // =========================

  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    Category? backup = index != -1 ? _categories[index] : null;

    try {
      _clearError();

      // 🔥 Optimistic update
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }

      await _firestoreService.updateCategory(
        category.id,
        category.toMap(),
      );
    } catch (e) {
      // 🔁 rollback
      if (index != -1 && backup != null) {
        _categories[index] = backup;
        notifyListeners();
      }

      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // ❌ DELETE CATEGORY (OPTIMISTIC)
  // =========================

  Future<void> deleteCategory(String id) async {
    final index = _categories.indexWhere((c) => c.id == id);

    if (index == -1) return;

    final backup = _categories[index];

    // 🔥 optimistic remove
    _categories.removeAt(index);
    notifyListeners();

    try {
      await _firestoreService.deleteCategory(id);
    } catch (e) {
      // 🔁 rollback
      _categories.insert(index, backup);
      notifyListeners();

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
  // 🧹 CLEAR
  // =========================

  void clear() {
    _subscription?.cancel();
    _categories = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
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