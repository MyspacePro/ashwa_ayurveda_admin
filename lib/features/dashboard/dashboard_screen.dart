import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

enum _AdminSection {
  dashboard,
  users,
  products,
  categories,
  orders,
  coupons,
  banners,
  notifications,
  tickets,
}

class _DashboardHomeState extends State<DashboardHome> {
  _AdminSection _section = _AdminSection.dashboard;
  bool _isCollapsed = false;

  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _productSearchController = TextEditingController();

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
  void dispose() {
    _userSearchController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    if (admin.isNone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isMobile = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      drawer: isMobile ? Drawer(child: _buildSidebar(isMobile: true)) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) _buildSidebar(isMobile: false),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(isMobile),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: SingleChildScrollView(
                        key: ValueKey(_section),
                        padding: const EdgeInsets.all(20),
                        child: _buildSectionContent(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE9ECF6))),
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          Expanded(
            child: Text(
              _sectionLabel(_section),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined, size: 18),
                SizedBox(width: 6),
                Text('Admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({required bool isMobile}) {
    final items = <(_AdminSection, IconData, String)>[
      (_AdminSection.dashboard, Icons.dashboard_outlined, 'Dashboard'),
      (_AdminSection.users, Icons.group_outlined, 'Users'),
      (_AdminSection.products, Icons.shopping_bag_outlined, 'Products'),
      (_AdminSection.categories, Icons.category_outlined, 'Categories'),
      (_AdminSection.orders, Icons.receipt_long_outlined, 'Orders'),
      (_AdminSection.coupons, Icons.discount_outlined, 'Coupons'),
      (_AdminSection.banners, Icons.image_outlined, 'Banners'),
      (_AdminSection.notifications, Icons.notifications_outlined, 'Notifications'),
      (_AdminSection.tickets, Icons.support_agent_outlined, 'Tickets / Support'),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: isMobile ? 290 : (_isCollapsed ? 88 : 260),
      color: const Color(0xFF111827),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF4F46E5),
                  child: Icon(Icons.spa, color: Colors.white),
                ),
                if (!(_isCollapsed && !isMobile)) ...[
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Ashwa Admin',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                if (!isMobile)
                  IconButton(
                    onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                    icon: Icon(
                      _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                final isActive = _section == item.$1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() => _section = item.$1);
                      if (isMobile) Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(item.$2, color: Colors.white),
                          if (!(_isCollapsed && !isMobile)) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.$3,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_section) {
      case _AdminSection.dashboard:
        return _dashboardOverview();
      case _AdminSection.users:
        return _usersSection();
      case _AdminSection.products:
        return _productsSection();
      case _AdminSection.categories:
        return _categoriesSection();
      case _AdminSection.orders:
        return _ordersSection();
      case _AdminSection.coupons:
      case _AdminSection.banners:
      case _AdminSection.notifications:
      case _AdminSection.tickets:
        return _managementPlaceholder(_sectionLabel(_section));
    }
  }

  Widget _dashboardOverview() {
    return Consumer3<UserProvider, ProductProvider, OrderProvider>(
      builder: (_, users, products, orders, __) {
        final cardData = [
          ('Users', users.totalUsers.toString(), Icons.people_alt_outlined, const Color(0xFF2563EB)),
          ('Orders', orders.totalOrders.toString(), Icons.shopping_cart_outlined, const Color(0xFF059669)),
          ('Revenue', '₹${orders.totalRevenue.toStringAsFixed(0)}', Icons.currency_rupee_outlined, const Color(0xFFEA580C)),
          ('Products', products.totalProducts.toString(), Icons.inventory_2_outlined, const Color(0xFF7C3AED)),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: cardData
                  .map((e) => _metricCard(e.$1, e.$2, e.$3, e.$4))
                  .toList(),
            ),
            const SizedBox(height: 22),
            _panel(
              title: 'Recent Orders',
              child: orders.orders.isEmpty
                  ? const Text('No recent orders')
                  : Column(
                      children: orders.orders.take(5).map((order) {
                        return ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text('Order #${order.orderId}'),
                          subtitle: Text(order.userId ?? 'Unknown user'),
                          trailing: Text(order.status.name.toUpperCase()),
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _usersSection() {
    return Consumer<UserProvider>(
      builder: (_, users, __) {
        final query = _userSearchController.text.toLowerCase();
        final filtered = users.users
            .where((u) => u.name.toLowerCase().contains(query) || u.email.toLowerCase().contains(query))
            .toList();

        return Column(
          children: [
            _searchField(_userSearchController, 'Search users by name or email'),
            const SizedBox(height: 12),
            _panel(
              title: 'Users (${filtered.length})',
              child: users.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final user = filtered[i];
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: FilledButton.tonal(
                            onPressed: () => users.toggleBlockUser(user),
                            child: Text(user.isBlocked ? 'Unblock' : 'Block'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _productsSection() {
    return Consumer<ProductProvider>(
      builder: (_, products, __) {
        final query = _productSearchController.text.toLowerCase();
        final filtered = products.products
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();

        return Column(
          children: [
            _searchField(_productSearchController, 'Search products by title'),
            const SizedBox(height: 12),
            _panel(
              title: 'Products (${filtered.length})',
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final product = filtered[i];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('Stock: ${product.stock}'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(onPressed: () {}, child: const Text('Edit')),
                        FilledButton.tonal(
                          onPressed: () async {
                            await products.deleteProduct(product.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Product deleted')),
                              );
                            }
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _categoriesSection() {
    return Consumer<CategoryProvider>(
      builder: (_, categories, __) {
        return _panel(
          title: 'Categories (${categories.categories.length})',
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.categories.length,
            itemBuilder: (_, i) {
              final category = categories.categories[i];
              return ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(category.name),
                subtitle: Text(category.id),
                trailing: OutlinedButton(onPressed: () {}, child: const Text('Edit')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _ordersSection() {
    return Consumer<OrderProvider>(
      builder: (_, orders, __) {
        return _panel(
          title: 'Orders (${orders.orders.length})',
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.orders.length,
            itemBuilder: (_, i) {
              final order = orders.orders[i];
              return ListTile(
                title: Text('Order ${order.orderId}'),
                subtitle: Text('₹${order.totalAmount.toStringAsFixed(0)}'),
                trailing: DropdownButton<OrderStatus>(
                  value: order.status,
                  onChanged: (value) {
                    if (value != null) {
                      orders.updateOrderStatus(orderId: order.id, status: value);
                    }
                  },
                  items: OrderStatus.values
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.name),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _managementPlaceholder(String title) {
    return _panel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This module is ready for CRUD integrations.'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Create')),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Update')),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.delete_outline), label: const Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x110F172A), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 230,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x110F172A), blurRadius: 12, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _searchField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  String _sectionLabel(_AdminSection section) {
    return switch (section) {
      _AdminSection.dashboard => 'Dashboard',
      _AdminSection.users => 'Users',
      _AdminSection.products => 'Products',
      _AdminSection.categories => 'Categories',
      _AdminSection.orders => 'Orders',
      _AdminSection.coupons => 'Coupons',
      _AdminSection.banners => 'Banners',
      _AdminSection.notifications => 'Notifications',
      _AdminSection.tickets => 'Tickets / Support',
    };
  }
}
