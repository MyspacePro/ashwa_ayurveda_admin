import 'package:admin_control/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// CORE
import 'core/theme/app_theme.dart';

// PROVIDERS
import 'admin/admin_provider.dart';
import 'providers/product_provider.dart';
import 'providers/user_provider.dart';
import 'providers/order_provider.dart';
import 'providers/category_provider.dart';
import 'providers/coupon_provider.dart';
import 'providers/delivery_provider.dart';
import 'providers/staff_provider.dart';

// SERVICES
import 'services/firebase/firebase_service.dart';
import 'services/firebase/coupon_service.dart';

// ROUTES
import 'admin/app_routes.dart';

// FIREBASE OPTIONS
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestoreService = FirestoreService();
  final couponService = CouponService();

  runApp(AdminControlApp(firestoreService: firestoreService, couponService: couponService));
}

class AdminControlApp extends StatelessWidget {
  final FirestoreService firestoreService;
  final CouponService couponService;

  const AdminControlApp({
    super.key,
    required this.firestoreService,
    required this.couponService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>.value(value: firestoreService),
        ChangeNotifierProvider(
  create: (context) =>
      DashboardProvider(context.read<FirestoreService>()),),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => UserProvider(firestoreService)),
        ChangeNotifierProvider(
  create: (context) =>
      OrderProvider(context.read<FirestoreService>()),),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(create: (_) => CouponProvider(couponService)),
        ChangeNotifierProvider(create: (_) => DeliveryProvider(firestoreService)),
        ChangeNotifierProvider(create: (_) => StaffProvider(firestoreService)),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Admin Control Panel',

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        /// ✅ ONLY ROUTES FILE CONTROLS NAVIGATION
        initialRoute: AppRoutes.adminLogin,

        routes: AppRoutes.routes,

        onUnknownRoute: AppRoutes.unknownRoute,
      ),
    );
  }
}