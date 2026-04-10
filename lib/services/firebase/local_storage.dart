import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  // ==============================
  // 🚀 INIT (CALL IN MAIN)
  // ==============================

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _safePrefs {
    if (_prefs == null) {
      throw Exception("LocalStorage not initialized. Call init() first.");
    }
    return _prefs!;
  }

  // ==============================
  // 🔑 KEYS (SCALABLE STRUCTURE)
  // ==============================

  static const String _tokenKey = "auth_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _userKey = "user_data";
  static const String _firstLoginKey = "first_login_done";

  // ==============================
  // ⚠️ ERROR HANDLER
  // ==============================

  static void _handleError(String method, dynamic e) {
    debugPrint("LocalStorage Error [$method]: $e");
  }

  // ==============================
  // 🚀 FIRST LOGIN
  // ==============================

  static bool isFirstLoginSync() {
    try {
      return !(_safePrefs.getBool(_firstLoginKey) ?? false);
    } catch (e) {
      _handleError("isFirstLoginSync", e);
      return true;
    }
  }

  static Future<bool> isFirstLogin() async {
    return isFirstLoginSync();
  }

  static Future<void> setFirstLoginDone() async {
    try {
      await _safePrefs.setBool(_firstLoginKey, true);
    } catch (e) {
      _handleError("setFirstLoginDone", e);
    }
  }

  // ==============================
  // 🔐 ACCESS TOKEN
  // ==============================

  static Future<void> saveToken(String token) async {
    try {
      await _safePrefs.setString(_tokenKey, token);
    } catch (e) {
      _handleError("saveToken", e);
    }
  }

  static String? getTokenSync() {
    try {
      return _safePrefs.getString(_tokenKey);
    } catch (e) {
      _handleError("getTokenSync", e);
      return null;
    }
  }

  static Future<String?> getToken() async {
    return getTokenSync();
  }

  static Future<void> removeToken() async {
    try {
      await _safePrefs.remove(_tokenKey);
    } catch (e) {
      _handleError("removeToken", e);
    }
  }

  // ==============================
  // 🔄 REFRESH TOKEN
  // ==============================

  static Future<void> saveRefreshToken(String token) async {
    try {
      await _safePrefs.setString(_refreshTokenKey, token);
    } catch (e) {
      _handleError("saveRefreshToken", e);
    }
  }

  static String? getRefreshTokenSync() {
    try {
      return _safePrefs.getString(_refreshTokenKey);
    } catch (e) {
      _handleError("getRefreshTokenSync", e);
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    return getRefreshTokenSync();
  }

  static Future<void> removeRefreshToken() async {
    try {
      await _safePrefs.remove(_refreshTokenKey);
    } catch (e) {
      _handleError("removeRefreshToken", e);
    }
  }

  // ==============================
  // 👤 USER DATA
  // ==============================

  static Future<void> saveUser(Map<String, dynamic> user) async {
    try {
      final encoded = jsonEncode(user);
      await _safePrefs.setString(_userKey, encoded);
    } catch (e) {
      _handleError("saveUser", e);
    }
  }

  static Map<String, dynamic>? getUserSync() {
    try {
      final data = _safePrefs.getString(_userKey);
      if (data == null) return null;
      return jsonDecode(data);
    } catch (e) {
      _handleError("getUserSync", e);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUser() async {
    return getUserSync();
  }

  static Future<void> removeUser() async {
    try {
      await _safePrefs.remove(_userKey);
    } catch (e) {
      _handleError("removeUser", e);
    }
  }

  // ==============================
  // 🔍 AUTH CHECK
  // ==============================

  static bool isLoggedInSync() {
    final token = getTokenSync();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isLoggedIn() async {
    return isLoggedInSync();
  }

  // ==============================
  // 🚪 LOGOUT (SAFE)
  // ==============================

  static Future<void> clearAuth() async {
    try {
      await Future.wait([
        _safePrefs.remove(_tokenKey),
        _safePrefs.remove(_refreshTokenKey),
        _safePrefs.remove(_userKey),
      ]);
    } catch (e) {
      _handleError("clearAuth", e);
    }
  }

  // ==============================
  // 💣 CLEAR ALL
  // ==============================

  static Future<void> clearAll() async {
    try {
      await _safePrefs.clear();
    } catch (e) {
      _handleError("clearAll", e);
    }
  }
}