import 'package:admin_control/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';

import '../delivery/delivery_tracking_screen.dart';
import '../settings/staff_management_screen.dart';
import '../users/user_form_screen.dart';
import '../products/product_form_screen.dart';
import '../categories/category_form_screen.dart';

enum AdminMenuItem {
  dashboard,
  userList,
  addUser,
  editUser,
  allProducts,
  addProduct,
  editProduct,
  allCategories,
  addCategory,
  addSubcategory,
  orders,
  coupons,
  banners,
  notifications,
  support,
  deliveryTracking,
  settings,
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  AdminMenuItem _active = AdminMenuItem.dashboard;
  final Set<String> _expandedGroups = {'Users'};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProvider>().listenToUsers();
      context.read<ProductProvider>().init();
       context.read<OrderProvider>().init();
      context.read<CategoryProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      drawer: isMobile ? Drawer(child: _sidebar(context)) : null,
      body: Row(
            children: [
          if (!isMobile) _sidebar(context),
          Expanded(child: _content(isMobile)),
        ],
      ),
    );
  }
Widget _content(bool isMobile) {
    return Column(
      children: [
        AppBar(
          backgroundColor: const Color(0xFF1F2937),
          leading: isMobile
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white70),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null,
          title: Text(
            _label(_active),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _screenForActive(),
          ),
        ),
      ],
    );
  }


  String _routeForMenu(AdminMenuItem item) {
    switch (item) {
      case AdminMenuItem.dashboard:
        return AppRoutes.adminDashboard;
      case AdminMenuItem.userList:
      case AdminMenuItem.addUser:
      case AdminMenuItem.editUser:
        return AppRoutes.editUser;
      case AdminMenuItem.allProducts:
      case AdminMenuItem.addProduct:
      case AdminMenuItem.editProduct:
        return AppRoutes.productList;
      case AdminMenuItem.allCategories:
      case AdminMenuItem.addCategory:
      case AdminMenuItem.addSubcategory:
        return AppRoutes.categories;
      case AdminMenuItem.orders:
        return AppRoutes.orders;
      case AdminMenuItem.coupons:
        return AppRoutes.coupons;
      case AdminMenuItem.banners:
        return AppRoutes.banners;
      case AdminMenuItem.notifications:
        return AppRoutes.notifications;
      case AdminMenuItem.support:
        return AppRoutes.tickets;
      case AdminMenuItem.deliveryTracking:
      case AdminMenuItem.settings:
        return AppRoutes.Seedone;
    }
  }

  Widget _sidebar(BuildContext context) {
    final groups = {
      'Dashboard': [AdminMenuItem.dashboard],
      'Users': [
        AdminMenuItem.userList,
        AdminMenuItem.addUser,
        AdminMenuItem.editUser,
      ],
      'Products': [
        AdminMenuItem.allProducts,
        AdminMenuItem.addProduct,
        AdminMenuItem.editProduct,
      ],
      'Categories': [
        AdminMenuItem.allCategories,
        AdminMenuItem.addCategory,
        AdminMenuItem.addSubcategory,
      ],
      'Orders': [AdminMenuItem.orders],
      'Coupons': [AdminMenuItem.coupons],
      'Banners': [AdminMenuItem.banners],
      'Notifications': [AdminMenuItem.notifications],
      'Support': [AdminMenuItem.support],
      'Delivery Tracking': [AdminMenuItem.deliveryTracking],
      'Settings': [AdminMenuItem.settings],
    };

    IconData iconFor(String key) => {
          'Dashboard': Icons.dashboard_outlined,
          'Users': Icons.group_outlined,
          'Products': Icons.shopping_bag_outlined,
          'Categories': Icons.category_outlined,
          'Orders': Icons.receipt_long_outlined,
          'Coupons': Icons.discount_outlined,
          'Banners': Icons.image_outlined,
          'Notifications': Icons.notifications_outlined,
          'Support': Icons.support_agent_outlined,
          'Delivery Tracking': Icons.local_shipping_outlined,
          'Settings': Icons.settings_outlined,
        }[key]!;

    return Container(
       width: 260,
      color: const Color(0xFF1F2937),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: groups.entries.map((entry) {
          final key = entry.key;
          final items = entry.value;
           final expanded = _expandedGroups.contains(key);

if (items.length == 1) {
            return _tile(key, items.first, iconFor(key), context);
          }

          return Column(
            children: [
              ListTile(
                leading: Icon(iconFor(key), color: Colors.white),
                title: Text(key, style: const TextStyle(color: Colors.white)),
                trailing: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70,
                ),
                onTap: () {
                  setState(() {
                    expanded
                        ? _expandedGroups.remove(key)
                        : _expandedGroups.add(key);
                  });
                },
              ),
              if (expanded)
                Column(
                  children: items
                      .map(
                        (e) => _tile(
                          _label(e),
                          e,
                          Icons.circle,
                          context,
                          indent: 20,
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _tile(
    String title,
    AdminMenuItem item,
    IconData icon,
    BuildContext context, {
    double indent = 0,
  }) {
    final active = _active == item;

    return Padding(
      padding: EdgeInsets.only(left: indent, top: 4, bottom: 4),
      child: Material(
        color: active ? const Color(0xFF6B4EEA) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          dense: true,
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white)),
           onTap: () {
            setState(() => _active = item);
            final route = _routeForMenu(item);
            Navigator.pushReplacementNamed(context, route);
          },
        ),
      ),
    );
  }

  Widget _screenForActive() {
    switch (_active) {
      case AdminMenuItem.dashboard:
        return _dashboard();
      case AdminMenuItem.userList:
        return _usersList();
      case AdminMenuItem.addUser:
        return const UserFormScreen();
      case AdminMenuItem.editUser:
      final user = context.watch<UserProvider>().users.isNotEmpty
            ? context.watch<UserProvider>().users.first
            : null;
        return user == null
            ? const Text('No users', style: TextStyle(color: Colors.white70))
            : UserFormScreen(user: user);
      case AdminMenuItem.allProducts:
      case AdminMenuItem.addProduct:
        return const ProductFormScreen();
      case AdminMenuItem.editProduct:
      final p = context.watch<ProductProvider>().products.isNotEmpty
            ? context.watch<ProductProvider>().products.first
            : null;
        return p == null
            ? const Text('No product', style: TextStyle(color: Colors.white70))
            : ProductFormScreen(product: p);
      case AdminMenuItem.allCategories:
      case AdminMenuItem.addCategory:
        return const CategoryFormScreen();
      case AdminMenuItem.addSubcategory:
       return const CategoryFormScreen(parentId: 'parent');
       case AdminMenuItem.deliveryTracking:
        return const DeliveryTrackingScreen();
      case AdminMenuItem.settings:
        return const StaffManagementScreen();
      default:
      return const Center(
          child: Text('Module ready', style: TextStyle(color: Colors.white70)),
        );
    }
  }
  
  Widget _usersList() {
    return Consumer<UserProvider>(
      builder: (_, users, __) {
        return Column(
          children: users.users
              .map(
                (u) => Card(
                  color: const Color(0xFF2C3E50),
                  child: ListTile(
                    title: Text(
                      u.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${u.email} • ₹${u.walletBalance}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Switch(
                      value: !u.isBlocked,
                      onChanged: (_) => users.toggleBlockUser(u),
                      activeColor: Colors.deepPurpleAccent,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _dashboard() {
     return Consumer3<UserProvider, ProductProvider, OrderProvider>(
      builder: (_, users, products, orders, __) {
        
        
        final cards = [
          ('Users', users.totalUsers.toString(), Icons.group),
          ('Orders', orders.totalOrders.toString(), Icons.receipt),
          ('Revenue', '₹${orders.totalRevenue}', Icons.currency_rupee),
          ('Products', products.totalProducts.toString(), Icons.inventory),
        ];

        final orderBars = List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (orders.orders.length > i ? orders.orders[i].totalItems : 0)
                    .toDouble(),
                color: Colors.deepPurpleAccent,
              ),
            ],
          ),
        );

        final lineSpots = List.generate(
          7,
          (i) => FlSpot(
            i.toDouble(),
            orders.orders.length > i ? orders.orders[i].totalAmount : 0,
          ),
        );

        final categoryMap = <String, double>{};

        for (final order in orders.orders) {
          for (final item in order.products) {
           final key = item.categoryId ?? 'unknown';

            categoryMap[key] =
                (categoryMap[key] ?? 0) + item.total;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards
                  .map(
                    (e) => Container(
                      width: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(e.$3, color: Colors.deepPurpleAccent),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.$1,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                e.$2,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _chartCard(
                    'Sales',
                    LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineSpots,
                            color: Colors.deepPurpleAccent,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.deepPurpleAccent.withValues(alpha: .3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _chartCard(
                    'Orders',
                    BarChart(
                      BarChartData(
                        barGroups: orderBars,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _chartCard(
              'Category Sales',
              SizedBox(
                height: 220,
                child: ListView(
                  children: categoryMap.entries
                      .map(
                        (e) => ListTile(
                          title: Text(
                            e.key,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Text(
                            '₹${e.value.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chartCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: child),
        ],
      ),
    );
  }

String _label(AdminMenuItem item) {
    return item.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .trim();
  }
}