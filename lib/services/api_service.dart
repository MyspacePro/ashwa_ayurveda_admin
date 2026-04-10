import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_control/services/firebase/local_storage.dart';
import '../models/api_response.dart';

class ApiService {
  static const String baseUrl = "https://yourapi.com";

  // =========================
  // 🔥 HEADERS
  // =========================

  static Future<Map<String, String>> _getHeaders() async {
    final token = LocalStorage.getTokenSync();

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  // =========================
  // 🚀 CORE REQUEST
  // =========================

  static Future<ApiResponse> _request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');

      http.Response response;

      switch (method) {
        case "GET":
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
          break;

        case "POST":
          response = await http
              .post(
                uri,
                headers: headers,
                body: jsonEncode(body ?? {}),
              )
              .timeout(const Duration(seconds: 15));
          break;

        case "PUT":
          response = await http
              .put(
                uri,
                headers: headers,
                body: jsonEncode(body ?? {}),
              )
              .timeout(const Duration(seconds: 15));
          break;

        case "DELETE":
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
          break;

        default:
          throw Exception("Invalid HTTP method");
      }

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: "Network error: ${e.toString()}",
      );
    }
  }

  // =========================
  // 📥 METHODS
  // =========================

  static Future<ApiResponse> get(String endpoint) async {
    return _request(endpoint: endpoint, method: "GET");
  }

  static Future<ApiResponse> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _request(
      endpoint: endpoint,
      method: "POST",
      body: body,
    );
  }

  static Future<ApiResponse> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _request(
      endpoint: endpoint,
      method: "PUT",
      body: body,
    );
  }

  static Future<ApiResponse> delete(String endpoint) async {
    return _request(endpoint: endpoint, method: "DELETE");
  }

  // =========================
  // ✅ HANDLE RESPONSE
  // =========================

  static ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = response.body;
    }

    // ✅ SUCCESS
    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(
        success: true,
        data: decoded,
        statusCode: statusCode,
      );
    }

    // 🔐 UNAUTHORIZED
    if (statusCode == 401) {
      return ApiResponse(
        success: false,
        message: "Unauthorized. Please login again.",
        statusCode: statusCode,
      );
    }

    // ❌ SAFE ERROR HANDLING
    String message = "Something went wrong";

    if (decoded is Map && decoded.containsKey('message')) {
      message = decoded['message'];
    }

    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}