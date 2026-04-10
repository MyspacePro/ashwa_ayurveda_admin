import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔥 SERVICES
import '../services/firebase/firebase_service.dart';

// 🔐 AUTH
import '../features/auth/admin_login_screen.dart';

// 📊 DASHBOARD
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/staff_dashboard.dart';

// 📦 PRODUCTS
import '../features/products/product_list.dart';
import '../features/products/add_product.dart';

// 📂 CATEGORIES
import '../features/categories/category_screen.dart';

// 🛒 ORDERS
import '../features/orders/order_screen.dart';

// 👤 USERS
import '../features/users/user_list.dart';

// 👥 STAFF


class AppRoutes {
  // =========================
  // 🔐 AUTH
  // =========================
  static const adminLogin = '/login';

  // =========================
  // 📊 DASHBOARD
  // =========================
  static const adminDashboard = '/dashboard';
  static const staffDashboard = '/staff-dashboard';

  // =========================
  // 📦 PRODUCTS
  // =========================
  static const productList = '/products';
  static const addProduct = '/add-product';

  // =========================
  // 📂 CATEGORIES
  // =========================
  static const categories = '/categories';

  // =========================
  // 🛒 ORDERS
  // =========================
  static const orders = '/orders';

  // =========================
  // 👤 USERS
  // =========================
  static const users = '/users';

  // =========================
  // 🌐 ROUTES MAP
  // =========================
  static Map<String, WidgetBuilder> routes = {
    // 🔐 AUTH
    adminLogin: (_) => const AdminLoginScreen(),

    // 📊 DASHBOARD
    adminDashboard: (_) => const DashboardHome(),
    staffDashboard: (_) => const StaffDashboard(),

    // 📦 PRODUCTS
    productList: (_) => const ProductList(),
    addProduct: (_) => const AddProductScreen(),

    // 📂 CATEGORIES (FIXED with Provider)
    categories: (context) => CategoryListScreen(
          firestoreService: context.read<FirestoreService>(),
        ),

    // 🛒 ORDERS
    orders: (_) => const OrderScreen(),

    // 👤 USERS
    users: (_) => const UserList(),
  };

  // =========================
  // ❌ UNKNOWN ROUTE HANDLER
  // =========================
  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            "❌ Route not found: ${settings.name}",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // =========================
  // 🚀 NAVIGATION HELPERS
  // =========================
  static void push(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  static void pushReplace(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static void popToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}