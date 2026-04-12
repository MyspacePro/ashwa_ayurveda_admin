import 'package:admin_control/Support/setting.dart';
import 'package:flutter/material.dart';


import '../../models/product_model.dart';


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

class AppRoutes {
  // =========================
  // ROUTE KEYS
  // =========================

  static const adminLogin = '/login';

  static const adminDashboard = '/dashboard';
  static const staffDashboard = '/staff-dashboard';

  static const userList = '/users';
  static const addUser = '/add-user';
  static const editUser = '/edit-user';

  static const productList = '/products';
  static const addProduct = '/add-product';
  static const editProduct = '/edit-product';

  static const categories = '/categories';
  static const addCategory = '/add-category';
  static const addSubcategory = '/add-subcategory';

  static const orders = '/orders';

  static const coupons = '/coupons';
  static const banners = '/banners';
  static const notifications = '/notifications';
  static const tickets = '/tickets';
   static const Seedone = '/SeedButton';

  static const deliveryTracking = '/delivery-tracking';

  // =========================
  // ROUTES MAP (SAFE VERSION)
  // =========================

  static Map<String, WidgetBuilder> routes = {
    // AUTH
    adminLogin: (_) => const AdminLoginScreen(),
    Seedone: (_) => const SeedButton(),

    // DASHBOARD
    adminDashboard: (_) => const DashboardHome(),
    staffDashboard: (_) => const StaffDashboard(),

    // USERS
    userList: (_) => const UserList(),
    addUser: (_) => const UserDetailScreen(userId: '',),
    editUser: (_) => const UserFormScreen(),

    // PRODUCTS
    productList: (_) => const ProductList(),
    addProduct: (_) => const AddProductScreen(),

    // ⚠️ IMPORTANT: SAFE ARGUMENT HANDLING (FIXED)
    editProduct: (context) {
      final product = ModalRoute.of(context)?.settings.arguments;

      if (product is ProductModel) {
        return EditProduct(product: product);
      }

      return const Scaffold(
        body: Center(
          child: Text("❌ Invalid Product Data"),
        ),
      );
    },

    categories: (_) => const CategoryListScreen(),

addCategory: (_) => const CategoryAddEditScreen(),

addSubcategory: (_) => const CategoryAddEditScreen(),
    // ORDERS
    orders: (_) => const OrderScreen(),

    // OTHERS (REMOVE EXTRA SCAFFOLD WRAP)
    coupons: (_) => const CouponListScreen(),
    banners: (_) => const BannerListScreen(),
    notifications: (_) => const NotificationListScreen(),
    tickets: (_) => const TicketListScreen(),

    // EXTRA
    deliveryTracking: (_) => const DeliveryTrackingScreen(),
  };

  // =========================
  // UNKNOWN ROUTE HANDLER
  // =========================

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            '❌ Route not found:\n${settings.name}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}