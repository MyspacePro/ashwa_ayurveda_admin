import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../services/firebase/firebase_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  UserProvider(this._firestoreService);

  // =========================
  // 📦 STATE
  // =========================
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<UserModel>>? _usersSubscription;

  bool _isInitialized = false;

  // =========================
  // 📦 GETTERS
  // =========================
  List<UserModel> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalUsers => _users.length;

  int get activeUsers =>
      _users.where((u) => u.isActive && !u.isBlocked).length;

  int get blockedUsers =>
      _users.where((u) => u.isBlocked).length;

  UserModel? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
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
    listenToUsers();
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
  // 👥 REALTIME LISTENER
  // =========================
  void listenToUsers() {
    _usersSubscription?.cancel();

    _setLoading(true);
    _clearError();

    _usersSubscription = _firestoreService.streamUsers().listen(
      (usersList) {
        _users = usersList;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError('Failed to load users: ${e.toString()}');
        _setLoading(false);
      },
    );
  }

  // =========================
  // ➕ CREATE USER
  // =========================
  Future<void> createUser(UserModel user) async {
    try {
      _clearError();
      await _firestoreService.createUser(user);
    } catch (e) {
      _setError('Create user failed: ${e.toString()}');
      rethrow;
    }
  }

  // =========================
  // ✏️ UPDATE USER (OPTIMISTIC)
  // =========================
  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final index = _users.indexWhere((u) => u.id == userId);
    UserModel? backup = index != -1 ? _users[index] : null;

    try {
      _clearError();

      // 🔥 Optimistic Update
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          name: data['name'] ?? _users[index].name,
          phone: data['phone'] ?? _users[index].phone,
          profileImage: data['profileImage'] ?? _users[index].profileImage,
          role: data['role'] ?? _users[index].role,
          isActive: data['isActive'] ?? _users[index].isActive,
          isBlocked: data['isBlocked'] ?? _users[index].isBlocked,
        );
        notifyListeners();
      }

      await _firestoreService.updateUser(userId, {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // 🔁 Rollback
      if (index != -1 && backup != null) {
        _users[index] = backup;
        notifyListeners();
      }

      _setError('Update failed: ${e.toString()}');
      rethrow;
    }
  }

  // =========================
  // 🚫 BLOCK / UNBLOCK
  // =========================
  Future<void> toggleBlockUser(UserModel user) async {
    await updateUser(
      userId: user.id,
      data: {
        'isBlocked': !user.isBlocked,
      },
    );
  }

  // =========================
  // ❌ DELETE USER (SOFT DELETE RECOMMENDED)
  // =========================
  Future<void> deleteUser(String userId) async {
    final index = _users.indexWhere((u) => u.id == userId);
    UserModel? backup = index != -1 ? _users[index] : null;

    try {
      _clearError();

      // 🔥 Optimistic Remove
      if (index != -1) {
        _users.removeAt(index);
        notifyListeners();
      }

      await _firestoreService.deleteUser(userId);
    } catch (e) {
      // 🔁 Rollback
      if (backup != null && index != -1) {
        _users.insert(index, backup);
        notifyListeners();
      }

      _setError('Delete failed: ${e.toString()}');
      rethrow;
    }
  }

  // =========================
  // 🔍 FILTERS
  // =========================
  List<UserModel> get blockedUserList =>
      _users.where((u) => u.isBlocked).toList();

  List<UserModel> get activeUserList =>
      _users.where((u) => u.canLogin).toList();

  List<UserModel> get adminUsers =>
      _users.where((u) => u.isAdmin).toList();

  // =========================
  // 🔄 REFRESH (FORCE RELOAD)
  // =========================
  Future<void> refresh() async {
    _isInitialized = false;
    listenToUsers();
  }

  // =========================
  // 🧹 CLEAR
  // =========================
  void clearUsers() {
    _usersSubscription?.cancel();
    _users = [];
    _error = null;
    _isLoading = false;
    _isInitialized = false;
    notifyListeners();
  }

  // =========================
  // ❌ DISPOSE
  // =========================
  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}