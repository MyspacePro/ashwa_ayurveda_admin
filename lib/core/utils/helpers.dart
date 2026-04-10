import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // =========================
  // NAVIGATION HELPERS
  // =========================

  static void push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pushReplace(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  // =========================
  // SNACKBAR
  // =========================

  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Success message
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  // Error message
  static void showError(BuildContext context, String message) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red,
    );
  }

  // =========================
  // LOADING DIALOG
  // =========================

  static void showLoadingDialog(BuildContext context,
      {String message = "Loading..."}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  // =========================
  // DATE HELPERS
  // =========================

  static String formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy").format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat("dd MMM yyyy • hh:mm a").format(date);
  }

  static String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 8) {
      return formatDate(date);
    } else if (diff.inDays >= 1) {
      return "${diff.inDays}d ago";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours}h ago";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

  // =========================
  // CURRENCY FORMATTER (INR)
  // =========================

  static String formatPrice(num price) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  // =========================
  // NULL SAFETY HELPERS
  // =========================

  static String safeString(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  static int safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // =========================
  // VALIDATORS
  // =========================

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return "Enter valid email";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }
}