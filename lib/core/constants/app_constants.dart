class AppConstants {
  AppConstants._(); // 🔒 Prevent instantiation

  // =========================
  // 🔥 APP INFO
  // =========================
  static const String appName = "Ashwa Ayurved Admin";
  static const String currencySymbol = "₹";

  // =========================
  // 🔐 ADMIN CONFIG
  // =========================
  static const String adminEmail = "admin@ashwa.com";

  // =========================
  // ⏱ TIMEOUTS
  // =========================
  static const int apiTimeoutSeconds = 30;

  // =========================
  // 🔥 FIREBASE COLLECTIONS
  // =========================
  static const String usersCollection = "users";
  static const String productsCollection = "products";
  static const String categoriesCollection = "categories";
  static const String cartsCollection = "carts";
  static const String ordersCollection = "orders";
  static const String wishlistCollection = "wishlist";

  // =========================
  // 📱 PAGINATION
  // =========================
  static const int pageLimit = 10;

  // =========================
  // 🖼 PLACEHOLDER
  // =========================
  static const String placeholderImage =
      "https://via.placeholder.com/150";

  // =========================
  // 🔐 ERROR MESSAGES
  // =========================
  static const String errorSomethingWentWrong = "Something went wrong";
  static const String errorNoInternet = "No internet connection";
  static const String errorUnauthorized = "Unauthorized access";
}

/// =========================
/// 📦 ORDER STATUS (TYPE SAFE)
/// =========================
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

/// Extension for Firestore mapping
extension OrderStatusX on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return "pending";
      case OrderStatus.processing:
        return "processing";
      case OrderStatus.shipped:
        return "shipped";
      case OrderStatus.delivered:
        return "delivered";
      case OrderStatus.cancelled:
        return "cancelled";
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case "processing":
        return OrderStatus.processing;
      case "shipped":
        return OrderStatus.shipped;
      case "delivered":
        return OrderStatus.delivered;
      case "cancelled":
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}