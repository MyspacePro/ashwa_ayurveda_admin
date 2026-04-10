import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/delivery_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
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
      context.read<OrderProvider>().listenToOrders();
      context.read<CategoryProvider>().listenToCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      drawer: isMobile ? Drawer(child: _sidebar(isMobile: true)) : null,
      body: Row(
        children: [if (!isMobile) _sidebar(isMobile: false), Expanded(child: _content(isMobile))],
      ),
    );
  }

  Widget _content(bool isMobile) => Column(children: [
        AppBar(leading: isMobile ? Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: ()=>Scaffold.of(context).openDrawer())) : null, title: Text(_label(_active))),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: _screenForActive())),
      ]);

  Widget _sidebar({required bool isMobile}) {
    final groups = {
      'Dashboard': [AdminMenuItem.dashboard],
      'Users': [AdminMenuItem.userList, AdminMenuItem.addUser, AdminMenuItem.editUser],
      'Products': [AdminMenuItem.allProducts, AdminMenuItem.addProduct, AdminMenuItem.editProduct],
      'Categories': [AdminMenuItem.allCategories, AdminMenuItem.addCategory, AdminMenuItem.addSubcategory],
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
      width: 280,
      color: const Color(0xFF111827),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: groups.entries.map((entry) {
          final key = entry.key;
          final items = entry.value;
          final expandable = items.length > 1;
          final expanded = _expandedGroups.contains(key);

          if (!expandable) {
            return _tile(key, items.first, iconFor(key), 0);
          }

          return Column(
            children: [
              ListTile(
                leading: Icon(iconFor(key), color: Colors.white),
                title: Text(key, style: const TextStyle(color: Colors.white)),
                trailing: AnimatedRotation(turns: expanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.expand_more, color: Colors.white70)),
                onTap: () => setState(() => expanded ? _expandedGroups.remove(key) : _expandedGroups.add(key)),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(children: items.map((e) => _tile(_label(e), e, Icons.circle, 28)).toList()),
                crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 240),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _tile(String title, AdminMenuItem item, IconData icon, double indent) {
    final active = _active == item;
    return Padding(
      padding: EdgeInsets.only(left: indent, top: 4, bottom: 4),
      child: Material(
        color: active ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          dense: true,
          leading: Icon(icon, color: Colors.white, size: indent > 0 ? 10 : 20),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          onTap: () => setState(() => _active = item),
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
        final user = context.watch<UserProvider>().users.isNotEmpty ? context.watch<UserProvider>().users.first : null;
        return user == null ? const Text('No users to edit') : UserFormScreen(user: user);
      case AdminMenuItem.allProducts:
      case AdminMenuItem.addProduct:
        return const ProductFormScreen();
      case AdminMenuItem.editProduct:
        final p = context.watch<ProductProvider>().products.isNotEmpty ? context.watch<ProductProvider>().products.first : null;
        return p == null ? const Text('No product to edit') : ProductFormScreen(product: p);
      case AdminMenuItem.allCategories:
      case AdminMenuItem.addCategory:
        return const CategoryFormScreen();
      case AdminMenuItem.addSubcategory:
        return const CategoryFormScreen(parentId: 'parent-category-id');
      case AdminMenuItem.deliveryTracking:
        return const DeliveryTrackingScreen();
      case AdminMenuItem.settings:
        return const StaffManagementScreen();
      default:
        return const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Module ready with clean architecture hooks.')));
    }
  }

  Widget _usersList() => Consumer<UserProvider>(builder: (_, users, __) => Column(children: users.users.map((u)=>Card(child: ListTile(title: Text(u.name), subtitle: Text('${u.email} • Wallet ₹${u.walletBalance.toStringAsFixed(2)} • KYC ${u.kycStatus}'), trailing: Switch(value: !u.isBlocked, onChanged: (_)=>users.toggleBlockUser(u))))).toList()));

  Widget _dashboard() {
    return Consumer3<UserProvider, ProductProvider, OrderProvider>(builder: (_, users, products, orders, __) {
      final cards = [
        ('Total Users', users.totalUsers.toString(), Icons.group),
        ('Total Orders', orders.totalOrders.toString(), Icons.receipt),
        ('Revenue', '₹${orders.totalRevenue.toStringAsFixed(0)}', Icons.currency_rupee),
        ('Products Count', products.totalProducts.toString(), Icons.inventory_2),
      ];

      final orderBars = List.generate(7, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (orders.orders.length > i ? orders.orders[i].totalItems : 0).toDouble(), color: Colors.indigo)]));
      final lineSpots = List.generate(7, (i) => FlSpot(i.toDouble(), orders.orders.length > i ? orders.orders[i].totalAmount : 0));
      final categoryMap = <String, double>{};
      for (final order in orders.orders.take(40)) {
        for (final item in order.products) {
          categoryMap[item.categoryId] = (categoryMap[item.categoryId] ?? 0) + item.total;
        }
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 12, children: cards.map((e)=>Container(width: 250,padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(14),boxShadow: const [BoxShadow(color: Color(0x11000000),blurRadius: 12)]), child: Row(children:[Icon(e.$3),const SizedBox(width:10),Column(crossAxisAlignment: CrossAxisAlignment.start,children:[Text(e.$1),Text(e.$2,style: const TextStyle(fontSize:22,fontWeight: FontWeight.bold))])]))).toList()),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _chartCard('Sales Chart', LineChart(LineChartData(lineBarsData: [LineChartBarData(spots: lineSpots, isCurved: true, color: Colors.green)])))),
          const SizedBox(width: 12),
          Expanded(child: _chartCard('Orders per Day', BarChart(BarChartData(barGroups: orderBars)))),
        ]),
        const SizedBox(height: 12),
        _chartCard('Category-wise Sales', SizedBox(height: 220, child: ListView(children: categoryMap.entries.map((e)=>ListTile(title: Text(e.key), trailing: Text('₹${e.value.toStringAsFixed(0)}')).toList())))),
        const SizedBox(height: 12),
        _chartCard('Recent Orders', Column(children: orders.orders.take(6).map((o)=>ListTile(title: Text('Order ${o.orderId}'), subtitle: Text(o.userId), trailing: Text(o.status.name.toUpperCase()))).toList())),
        const SizedBox(height: 12),
        _chartCard('Recent Users', Column(children: users.users.take(6).map((u)=>ListTile(title: Text(u.name), subtitle: Text(u.email))).toList())),
      ]);
    });
  }

  Widget _chartCard(String title, Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 12), SizedBox(height: 220, child: child)]),
      );

  String _label(AdminMenuItem item) => item.name.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}').replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
}
