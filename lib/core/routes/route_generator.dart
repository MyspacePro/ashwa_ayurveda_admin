import 'package:admin_control/Coupons/coupon_add_edit_screen.dart';
import 'package:admin_control/Coupons/coupon_list_screen.dart';
import 'package:admin_control/Support/setting.dart';
import 'package:admin_control/Support/ticket_list_screen.dart';
import 'package:admin_control/features/Notifications/notification_list_screen.dart';
import 'package:admin_control/features/auth/admin_login_screen.dart';
import 'package:admin_control/features/banners/banner_list_screen.dart';
import 'package:admin_control/features/categories/category_add_edit_screen.dart';
import 'package:admin_control/features/categories/category_screen.dart';
import 'package:admin_control/features/dashboard/dashboard_screen.dart';
import 'package:admin_control/features/dashboard/staff_dashboard.dart';
import 'package:admin_control/features/delivery/delivery_tracking_screen.dart';
import 'package:admin_control/features/orders/order_detail_screen.dart';
import 'package:admin_control/features/orders/order_screen.dart';
import 'package:admin_control/features/products/add_product.dart';
import 'package:admin_control/features/products/edit_product.dart';
import 'package:admin_control/features/products/product_list.dart';
import 'package:admin_control/features/users/user_detail_screen.dart';
import 'package:admin_control/features/users/user_form_screen.dart';
import 'package:admin_control/features/users/user_list.dart';
import 'package:admin_control/models/coupon_model.dart';
import 'package:admin_control/models/order_model.dart';
import 'package:admin_control/models/product_model.dart';
import 'package:admin_control/models/user_model.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint(
      '[RouteGenerator] route: ${settings.name}, argsType: ${settings.arguments?.runtimeType}',
    );

    switch (settings.name) {
      case AppRoutes.adminLogin:
        return _fadeRoute(const AdminLoginScreen(), settings);
      case AppRoutes.adminDashboard:
        return _fadeRoute(const DashboardHome(), settings);
      case AppRoutes.staffDashboard:
        return _fadeRoute(const StaffDashboard(), settings);

      case AppRoutes.userList:
        return _fadeRoute(const UserList(), settings);
      case AppRoutes.addUser:
        return _fadeRoute(const UserFormScreen(), settings);
      case AppRoutes.editUser:
        final args = settings.arguments;
        if (args is UserModel) {
          return _fadeRoute(UserFormScreen(user: args), settings);
        }
        return _errorRoute(
          settings,
          'Invalid user argument for edit screen.',
        );
      case AppRoutes.userDetail:
        final args = settings.arguments;
        if (args is String && args.trim().isNotEmpty) {
          return _fadeRoute(UserDetailScreen(userId: args), settings);
        }
        return _errorRoute(
          settings,
          'User detail requires a valid userId (String).',
        );

      case AppRoutes.productList:
        return _fadeRoute(const ProductList(), settings);
      case AppRoutes.addProduct:
        return _fadeRoute(const AddProductScreen(), settings);
      case AppRoutes.editProduct:
        final args = settings.arguments;
        if (args is ProductModel) {
          return _fadeRoute(EditProduct(product: args), settings);
        }
        return _errorRoute(
          settings,
          'Invalid product argument for edit screen.',
        );

      case AppRoutes.categories:
        return _fadeRoute(const CategoryListScreen(), settings);
      case AppRoutes.addCategory:
      case AppRoutes.addSubcategory:
        return _fadeRoute(const CategoryAddEditScreen(), settings);

      case AppRoutes.orders:
        return _fadeRoute(const OrderScreen(), settings);
      case AppRoutes.orderDetail:
        final args = settings.arguments;
        if (args is OrderModel) {
          return _fadeRoute(OrderDetailScreen(order: args), settings);
        }
        return _errorRoute(
          settings,
          'Order detail requires an OrderModel argument.',
        );

      case AppRoutes.coupons:
        return _fadeRoute(const CouponListScreen(), settings);
      case AppRoutes.couponForm:
        final args = settings.arguments;
        if (args == null || args is CouponModel) {
          return _fadeRoute(AddEditCouponScreen(coupon: args as CouponModel?), settings);
        }
        return _errorRoute(
          settings,
          'Coupon form expects CouponModel? argument.',
        );

      case AppRoutes.banners:
        return _fadeRoute(const BannerListScreen(), settings);
      case AppRoutes.notifications:
        return _fadeRoute(const NotificationListScreen(), settings);
      case AppRoutes.tickets:
        return _fadeRoute(const TicketListScreen(), settings);

      case AppRoutes.deliveryTracking:
        return _fadeRoute(const DeliveryTrackingScreen(), settings);
      case AppRoutes.settings:
        return _fadeRoute(const Scaffold(body: Center(child: SeedButton())), settings);

      default:
        return _errorRoute(settings, 'Route not found.');
    }
  }

  static PageRouteBuilder<dynamic> _fadeRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: animation,
        child: page,
      ),
    );
  }

  static MaterialPageRoute<dynamic> _errorRoute(
    RouteSettings settings,
    String message,
  ) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Navigation Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '❌ $message\n\nRoute: ${settings.name}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
