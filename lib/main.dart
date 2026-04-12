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
import 'core/routes/app_routes.dart';

// FIREBASE OPTIONS
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestoreService = FirestoreService();
  final couponService = CouponService();

  runApp(
    AdminControlApp(
      firestoreService: firestoreService,
      couponService: couponService,
    ),
  );
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
        /// 🔥 CORE SERVICE
        Provider<FirestoreService>.value(value: firestoreService),

        /// 📊 DASHBOARD
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(firestoreService),
        ),

        /// 🔐 ADMIN
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),

        /// 📦 PRODUCTS
        ChangeNotifierProvider(
          create: (_) => ProductProvider(firestoreService),
        ),

        /// 👤 USERS
        ChangeNotifierProvider(
          create: (_) => UserProvider(firestoreService),
        ),

        /// 🛒 ORDERS
        ChangeNotifierProvider(
          create: (_) => OrderProvider(firestoreService),
        ),

        /// 🗂 CATEGORIES
        ChangeNotifierProvider(
  create: (context) {
    final provider = CategoryProvider(firestoreService);
    provider.init(); // 🔥 AUTO INIT
    return provider;
  },
),

        /// 🎟 COUPONS
        ChangeNotifierProvider(
          create: (_) => CouponProvider(couponService),
        ),

        /// 🚚 DELIVERY
        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(firestoreService),
        ),

        /// 👨‍💼 STAFF
        ChangeNotifierProvider(
          create: (_) => StaffProvider(firestoreService),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Admin Control Panel',

        /// 🎨 THEME
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,

        /// ⚠️ CURRENT ROUTING (OK BUT NOT BEST)
        initialRoute: AppRoutes.adminLogin,
        routes: AppRoutes.routes,
      

        /// 🚀 RECOMMENDED UPGRADE (next step)
        /// Replace above 3 lines with:
        /// onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}