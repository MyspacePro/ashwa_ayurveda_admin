import 'package:admin_control/admin/app_routes.dart';
import 'package:admin_control/services/firebase/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/dashboard_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';

import '../../features/products/add_product.dart';
import '../../features/categories/category_screen.dart';
import '../../features/orders/order_screen.dart';

import '../../widgets/dashboard_cards.dart';
import '../../widgets/revenue_chart.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  String selectedRange = "Month";

  int selectedIndex = 0;
  String expandedMenu = "";
  String userRole = "admin";

  @override
  void initState() {
    super.initState();

    /// 🔥 REALTIME INIT (NO FETCH)
    Future.microtask(() {
      context.read<UserProvider>().listenToUsers();
      context.read<ProductProvider>().init();
      context.read<OrderProvider>().listenToOrders();
      context.read<DashboardProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _sidebar(),

          Expanded(
            child: Column(
              children: [
                _header(),

                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F7FB),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: _dashboardContent(),
                    ),
                  ),
                ),

                _footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 SIDEBAR (UNCHANGED)
  Widget _sidebar() {
    final orderCount = context.watch<OrderProvider>().orders.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 250,
      color: const Color(0xFF1E1B3A),
      child: ListView(
        children: [
          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Ashwa Admin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          _menuItem(Icons.dashboard, "Dashboard", 0, () {
            setState(() {
              selectedIndex = 0;
              expandedMenu = "";
            });
          }),

          if (userRole == "admin")
            _expandableMenu(
              title: "Products",
              icon: Icons.shopping_bag,
              children: [
                _subMenu("Product List", () => _navigate(context, "productList")),
                _subMenu("Add Product", () => _navigate(context, "addProduct")),
              ],
            ),

          if (userRole == "admin")
            _expandableMenu(
              title: "Categories",
              icon: Icons.category,
              children: [
                _subMenu("Category List", () => _navigate(context, "categoryList")),
                _subMenu("Add Category", () => _navigate(context, "addCategory")),
                _subMenu("Sub Categories", () => _navigate(context, "subCategory")),
              ],
            ),

          _expandableMenu(
            title: "Orders",
            icon: Icons.shopping_cart,
            badge: orderCount,
            children: [
              _subMenu("Order List", () => _navigate(context, "orderList")),
              _subMenu("Order Details", () => _navigate(context, "orderDetails")),
            ],
          ),

          if (userRole == "admin")
            _expandableMenu(
              title: "Users",
              icon: Icons.people,
              children: [
                _subMenu("User List", () => _navigate(context, "userList")),
                _subMenu("User Details", () => _navigate(context, "userDetails")),
              ],
            ),

          if (userRole == "admin")
            _expandableMenu(
              title: "Staff",
              icon: Icons.admin_panel_settings,
              children: [
                _subMenu("Staff List", () => _navigate(context, "staffList")),
                _subMenu("Assign Role", () => _navigate(context, "assignRole")),
              ],
            ),

          const Divider(color: Colors.white24),

          _menuItem(Icons.settings, "Settings", 99,
              () => _navigate(context, "settings")),

          _menuItem(Icons.person, "Profile", 100,
              () => _navigate(context, "profile")),
        ],
      ),
    );
  }

  Widget _menuItem(
      IconData icon, String title, int index, VoidCallback onTap) {
    bool isActive = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFC857) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isActive ? Colors.black : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _expandableMenu({
    required String title,
    required IconData icon,
    required List<Widget> children,
    int badge = 0,
  }) {
    bool isExpanded = expandedMenu == title;

    return Column(
      children: [
        ListTile(
          leading: Stack(
            children: [
              Icon(icon, color: Colors.white70),
              if (badge > 0)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      badge.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          title:
              Text(title, style: const TextStyle(color: Colors.white)),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child:
                const Icon(Icons.expand_more, color: Colors.white),
          ),
          onTap: () {
            setState(() {
              expandedMenu = isExpanded ? "" : title;
            });
          },
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox(),
          secondChild: Column(children: children),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _subMenu(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(color: Colors.white70)),
        onTap: onTap,
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
  switch (route) {
    case "productList":
      Navigator.pushNamed(context, AppRoutes.productList);
      break;

    case "addProduct":
      Navigator.pushNamed(context, AppRoutes.addProduct);
      break;

    case "orderList":
      Navigator.pushNamed(context, AppRoutes.orders);
      break;

    case "categoryList":
      Navigator.pushNamed(context, AppRoutes.categories);
      break;

    case "userList":
      Navigator.pushNamed(context, AppRoutes.users);
      break;

    case "staffList":
      Navigator.pushNamed(context, AppRoutes.staffDashboard);
      break;

    case "settings":
      Navigator.pushNamed(context, AppRoutes.staffDashboard);
      break;

    case "profile":
      Navigator.pushNamed(context, AppRoutes.staffDashboard);
      break;
  }
}

  /// HEADER
  Widget _header() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dashboard",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(Icons.notifications_none),
              SizedBox(width: 20),
              CircleAvatar(child: Icon(Icons.person)),
            ],
          )
        ],
      ),
    );
  }

  Widget _dashboardContent() {
    return Consumer<DashboardProvider>(
      builder: (_, dash, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 💎 KPI CARDS
            DashboardCards(
              totalRevenue: dash.totalRevenue,
              totalOrders: dash.totalOrders,
              pending: dash.pendingOrders,
              delivered: dash.deliveredOrders,
            ),

            const SizedBox(height: 20),

            /// 📈 CHART
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: dash.last7DaysRevenue.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.value))
                          .toList(),
                      dotData: FlDotData(show: false),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🧠 AI INSIGHT
            _sectionCard(
              title: "AI Insights",
              child: Text("Growth: ${dash.todayGrowth.toStringAsFixed(2)}%"),
            ),

            const SizedBox(height: 20),

            /// 🏆 TOP PRODUCTS
            _sectionCard(
              title: "Top Products",
              child: Column(
                children: dash.topProducts.entries.map((e) {
                  return ListTile(
                    title: Text("Product ${e.key}"),
                    trailing: Text("Sold: ${e.value}"),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                    child: _sectionCard(
                        title: "Recent Orders",
                        child: _ordersList())),
                const SizedBox(width: 20),
                Expanded(
                    child: _sectionCard(
                        title: "New Users",
                        child: _usersList())),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _footer() {
    return Container(
      height: 40,
      alignment: Alignment.center,
      color: Colors.white,
      child: const Text("© 2026 Ashwa Ayurveda Admin",
          style: TextStyle(color: Colors.grey)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6)
      ],
    );
  }

  Widget _ordersList() {
    return Consumer<OrderProvider>(
      builder: (_, orderProv, __) {
        if (orderProv.orders.isEmpty) {
          return const Center(child: Text("No orders"));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: orderProv.orders.length > 5
              ? 5
              : orderProv.orders.length,
          itemBuilder: (_, i) {
            final order = orderProv.orders[i];
            return ListTile(
              title: Text("Order #${order.id}"),
              subtitle: Text("₹${order.totalAmount}"),
            );
          },
        );
      },
    );
  }

  Widget _usersList() {
    return Consumer<UserProvider>(
      builder: (_, userProv, __) {
        if (userProv.users.isEmpty) {
          return const Center(child: Text("No users"));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount:
              userProv.users.length > 5 ? 5 : userProv.users.length,
          itemBuilder: (_, i) {
            final user = userProv.users[i];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
            );
          },
        );
      },
    );
  }

  Widget _sectionCard(
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

