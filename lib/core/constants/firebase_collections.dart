class FirebaseCollections {
  // =========================
  // 🔥 MAIN COLLECTIONS
  // =========================
  static const String users = "users";
  static const String products = "products";
  static const String categories = "categories";
  static const String carts = "carts";
  static const String orders = "orders";
  static const String wishlist = "wishlist";

  // =========================
  // 📦 SUB-COLLECTIONS
  // =========================

  // Cart items inside carts/{userId}/items
  static const String cartItems = "items";

  // Order items inside orders/{orderId}/items
  static const String orderItems = "items";

  // Wishlist items (optional structure)
  static const String wishlistItems = "items";

  // =========================
  // 📊 OPTIONAL FUTURE COLLECTIONS
  // =========================
  static const String banners = "banners";
  static const String analytics = "analytics";
  static const String notifications = "notifications";

  // =========================
  // 🧾 FIELD KEYS (BEST PRACTICE)
  // =========================

  // Common fields
  static const String id = "id";
  static const String createdAt = "createdAt";
  static const String updatedAt = "updatedAt";

  // User fields
  static const String name = "name";
  static const String email = "email";
  static const String phone = "phone";

  // Product fields
  static const String price = "price";
  static const String description = "description";
  static const String categoryId = "categoryId";
  static const String stock = "stock";
  static const String rating = "rating";
  static const String images = "images";

  // Order fields
  static const String userId = "userId";
  static const String status = "status";
  static const String total = "total";
  static const String address = "address";

  // Cart fields
  static const String quantity = "qty";
}