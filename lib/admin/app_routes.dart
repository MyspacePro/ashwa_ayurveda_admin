import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase/firebase_service.dart';
import '../features/auth/admin_login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/staff_dashboard.dart';
import '../features/products/product_list.dart';
import '../features/products/add_product.dart';
import '../features/categories/category_screen.dart';
import '../features/orders/order_screen.dart';
import '../features/users/user_list.dart';
import '../Coupons/coupon_list_screen.dart';
import '../features/banners/banner_list_screen.dart';
import '../features/Notifications/notification_list_screen.dart';
import '../Support/ticket_list_screen.dart';

class AppRoutes {
  static const adminLogin = '/login';
  static const adminDashboard = '/dashboard';
  static const staffDashboard = '/staff-dashboard';

  static const productList = '/products';
  static const addProduct = '/add-product';
  static const categories = '/categories';
  static const orders = '/orders';
  static const users = '/users';
  static const coupons = '/coupons';
  static const banners = '/banners';
  static const notifications = '/notifications';
  static const tickets = '/tickets';

  static Map<String, WidgetBuilder> routes = {
    adminLogin: (_) => const AdminLoginScreen(),
    adminDashboard: (_) => const DashboardHome(),
    staffDashboard: (_) => const StaffDashboard(),
    productList: (_) => const ProductList(),
    addProduct: (_) => const AddProductScreen(),
    categories: (context) => CategoryListScreen(
          firestoreService: context.read<FirestoreService>(),
        ),
    orders: (_) => const OrderScreen(),
    users: (_) => const UserList(),
    coupons: (_) => const Scaffold(body: CouponListScreen()),
    banners: (_) => const Scaffold(body: BannerListScreen()),
    notifications: (_) => const Scaffold(body: NotificationListScreen()),
    tickets: (_) => const Scaffold(body: TicketListScreen()),
  };

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            '❌ Route not found: ${settings.name}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
