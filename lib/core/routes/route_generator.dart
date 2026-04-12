import 'package:flutter/material.dart';
import 'package:admin_control/core/routes/app_routes.dart';
import 'package:admin_control/models/product_model.dart';

// AUTH & DASHBOARD
import '../../features/auth/admin_login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/staff_dashboard.dart';

// USERS
import '../../features/users/user_list.dart';
import '../../features/users/user_detail_screen.dart';
import '../../features/users/user_form_screen.dart';

// PRODUCTS
import '../../features/products/product_list.dart';
import '../../features/products/add_product.dart';
import '../../features/products/edit_product.dart';

// CATEGORIES
import '../../features/categories/category_screen.dart';
import '../../features/categories/category_add_edit_screen.dart';

// ORDERS
import '../../features/orders/order_screen.dart';

// OTHERS
import '../../Coupons/coupon_list_screen.dart';
import '../../features/banners/banner_list_screen.dart';
import '../../features/Notifications/notification_list_screen.dart';
import '../../Support/ticket_list_screen.dart';

// EXTRA
import '../../features/delivery/delivery_tracking_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      // =========================
      // AUTH
      // =========================
      case AppRoutes.adminLogin:
        return _build(const AdminLoginScreen());

      // =========================
      // DASHBOARD
      // =========================
      case AppRoutes.adminDashboard:
        return _build(const DashboardHome());

      case AppRoutes.staffDashboard:
        return _build(const StaffDashboard());

      // =========================
      // USERS
      // =========================
      case AppRoutes.userList:
        return _build(const UserList());

      case AppRoutes.addUser:
        return _build(const UserDetailScreen(userId: '',));

      case AppRoutes.editUser:
        return _build(const UserFormScreen());

      // =========================
      // PRODUCTS
      // =========================
      case AppRoutes.productList:
        return _build(const ProductList());

      case AppRoutes.addProduct:
        return _build(const AddProductScreen());

      case AppRoutes.editProduct:
        final args = settings.arguments;

        if (args is ProductModel) {
          return _build(EditProduct(product: args));
        }

        return _errorRoute("Invalid Product Data");

      // =========================
      // CATEGORIES
      // =========================
      case AppRoutes.categories:
        return _build(const CategoryListScreen());

      case AppRoutes.addCategory:
        return _build(const CategoryAddEditScreen());

      case AppRoutes.addSubcategory:
        return _build(const CategoryAddEditScreen());

      // =========================
      // ORDERS
      // =========================
      case AppRoutes.orders:
        return _build(const OrderScreen());

      // =========================
      // OTHERS
      // =========================
      case AppRoutes.coupons:
        return _build(const CouponListScreen());

      case AppRoutes.banners:
        return _build(const BannerListScreen());

      case AppRoutes.notifications:
        return _build(const NotificationListScreen());

      case AppRoutes.tickets:
        return _build(const TicketListScreen());

      // =========================
      // DELIVERY
      // =========================
      case AppRoutes.deliveryTracking:
        return _build(const DeliveryTrackingScreen());

      // =========================
      // DEFAULT (404)
      // =========================
      default:
        return _errorRoute("Route not found: ${settings.name}");
    }
  }

  // =========================
  // ROUTE HELPER
  // =========================
  static MaterialPageRoute _build(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            "❌ $message",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}