import 'dart:async';
import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../services/firebase/firebase_service.dart';

class CategoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  CategoryProvider(this._firestoreService);

  // =========================
  // 📦 STATE
  // =========================
  List<CategoryModel> _categories = [];
  List<SubCategory> _subCategories = [];

  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<CategoryModel>>? _catSub;
  StreamSubscription<List<SubCategory>>? _subCatSub;

  bool _isInitialized = false;
  int _activeStreams = 0;

  // =========================
  // 📦 GETTERS
  // =========================
  List<CategoryModel> get categories =>
      List.unmodifiable(_categories);

  List<SubCategory> get subCategories =>
      List.unmodifiable(_subCategories);

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _categories.isEmpty;

  // =========================
  // 🚀 INIT (SAFE SINGLE CALL)
  // =========================
  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
    _startListeners();
  }

  void _startListeners() {
    _cancelStreams();

    _setLoading(true);
    _clearError();

    _activeStreams = 2;

    // =========================
    // 📂 CATEGORIES STREAM
    // =========================
    _catSub = _firestoreService.streamCategories().listen(
      (data) {
        _categories = data;
        _onStreamUpdated();
      },
      onError: (e) {
        _setError(e.toString());
        _onStreamUpdated();
      },
    );

    // =========================
    // 📂 SUBCATEGORIES STREAM
    // =========================
    _subCatSub = _firestoreService.streamSubCategories().listen(
      (data) {
        _subCategories = data;
        _onStreamUpdated();
      },
      onError: (e) {
        _setError(e.toString());
        _onStreamUpdated();
      },
    );
  }

  void _onStreamUpdated() {
    _activeStreams--;

    if (_activeStreams <= 0) {
      _setLoading(false);
    }

    notifyListeners();
  }

  // =========================
  // 🔄 REFRESH
  // =========================
  Future<void> refresh() async {
    _isInitialized = false;
    await _startFresh();
  }

  Future<void> _startFresh() async {
    _isInitialized = true;
    _startListeners();
  }

  // =========================
  // 📂 FILTERS
  // =========================
  List<SubCategory> subCategoriesByCategory(String categoryId) {
    return _subCategories
        .where((s) => s.categoryId == categoryId)
        .toList();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  SubCategory? getSubCategoryById(String id) {
    try {
      return _subCategories.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // ➕ ADD CATEGORY
  // =========================
  Future<void> addCategory(CategoryModel category) async {
    try {
      _clearError();
      await _firestoreService.addCategory(category.toMap());
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // ✏️ UPDATE CATEGORY
  // =========================
  Future<void> updateCategory(CategoryModel category) async {
    try {
      _clearError();
      await _firestoreService.updateCategory(
        category.id,
        category.toMap(),
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // ❌ DELETE CATEGORY
  // =========================
  Future<void> deleteCategory(String id) async {
    try {
      _clearError();
      await _firestoreService.deleteCategory(id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // 🔧 HELPERS
  // =========================
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
  }

  void _setError(String message) {
    _error = message;
  }

  void _clearError() {
    _error = null;
  }

  void _cancelStreams() {
    _catSub?.cancel();
    _subCatSub?.cancel();
    _catSub = null;
    _subCatSub = null;
  }

  // =========================
  // 🧹 DISPOSE
  // =========================
  @override
  void dispose() {
    _cancelStreams();
    super.dispose();
  }
}