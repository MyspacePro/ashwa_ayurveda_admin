import 'package:flutter/material.dart';

/// 🔹 Enum for user roles (RBAC system)
enum UserRole { admin, staff, user, none }

/// 🔹 Production-ready Admin Provider
class AdminProvider with ChangeNotifier {
  UserRole _currentRole = UserRole.none;

  bool _isLoading = false;
  String? _error;

  // =========================
  // 📦 GETTERS
  // =========================

  UserRole get currentRole => _currentRole;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAdmin => _currentRole == UserRole.admin;
  bool get isStaff => _currentRole == UserRole.staff;
  bool get isUser => _currentRole == UserRole.user;
  bool get isNone => _currentRole == UserRole.none;

  // =========================
  // 🔐 ROLE SETTER
  // =========================

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  // =========================
  // 🔄 FROM STRING (FIREBASE SAFE)
  // =========================

  void setRoleFromString(String role) {
    switch (role.toLowerCase()) {
      case "admin":
        _currentRole = UserRole.admin;
        break;
      case "staff":
        _currentRole = UserRole.staff;
        break;
      case "user":
        _currentRole = UserRole.user;
        break;
      default:
        _currentRole = UserRole.none;
    }
    notifyListeners();
  }

  // =========================
  // 🔁 RESET ROLE
  // =========================

  void resetRole() {
    _currentRole = UserRole.none;
    notifyListeners();
  }

  // =========================
  // 🧠 PERMISSION SYSTEM (IMPORTANT FOR ADMIN PANEL)
  // =========================

  bool canEditUsers() => isAdmin || isStaff;
  bool canDeleteUsers() => isAdmin;
  bool canBlockUsers() => isAdmin || isStaff;

  bool canViewOrders() => isAdmin || isStaff;
  bool canEditOrders() => isAdmin || isStaff;
  bool canDeleteOrders() => isAdmin;

  // =========================
  // 🔄 LOADING HANDLERS
  // =========================

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // =========================
  // ❌ ERROR HANDLER
  // =========================

  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}