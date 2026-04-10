import 'dart:async';

import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../services/firebase/firebase_service.dart';

class CategoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  CategoryProvider(this._firestoreService);

  List<Category> _categories = [];
  List<SubCategory> _subCategories = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<Category>>? _categoriesSubscription;
  StreamSubscription<List<SubCategory>>? _subCategoriesSubscription;

  List<Category> get categories => List.unmodifiable(_categories);
  List<SubCategory> get subCategories => List.unmodifiable(_subCategories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<SubCategory> subCategoriesByCategory(String categoryId) {
    return _subCategories.where((s) => s.categoryId == categoryId).toList();
  }

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

  void listenToCategories() {
    _categoriesSubscription?.cancel();
    _setLoading(true);
    _clearError();

    _categoriesSubscription = _firestoreService.streamCategories().listen(
      (data) {
        _categories = data;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  void listenToSubCategories({String? categoryId}) {
    _subCategoriesSubscription?.cancel();
    _subCategoriesSubscription =
        _firestoreService.streamSubCategories(categoryId: categoryId).listen(
      (data) {
        _subCategories = data;
        notifyListeners();
      },
      onError: (e) {
        _setError(e.toString());
      },
    );
  }

  Future<void> addCategory(Category category) async {
    try {
      _clearError();
      await _firestoreService.addCategory(category.toMap(isCreate: true));
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      _clearError();
      await _firestoreService.updateCategory(category.id, category.toMap());
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _subCategoriesSubscription?.cancel();
    super.dispose();
  }
}
