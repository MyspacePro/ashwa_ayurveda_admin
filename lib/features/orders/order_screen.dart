import 'package:admin_control/core/routes/app_routes.dart';
import 'package:admin_control/core/routes/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../admin/admin_provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderListState();
}

class _OrderListState extends State<OrderScreen> {
  OrderStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrderProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final admin = context.watch<AdminProvider>();
    final orders = _applyFilter(provider.orders);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Orders'),
        backgroundColor: const Color(0xFF111827),
      ),
      body: Column(
        children: [
          _dashboard(provider),
          _filters(),
          Expanded(child: _buildBody(provider, admin, orders)),
        ],
      ),
    );
  }

  Widget _dashboard(OrderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _card('Total', provider.totalOrders.toString()),
          _card('Revenue', '₹${provider.totalRevenue.toStringAsFixed(0)}'),
          _card('Today', '₹${provider.todayRevenue.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _card(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          _filterChip('All', null),
          ...OrderStatus.values.map((s) => _filterChip(s.name, s)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, OrderStatus? status) {
    final isSelected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label.toUpperCase()),
        selected: isSelected,
        onSelected: (_) => setState(() => _filter = status),
      ),
    );
  }

  List<OrderModel> _applyFilter(List<OrderModel> orders) {
    if (_filter == null) return orders;
    return orders.where((o) => o.status == _filter).toList();
  }

  Widget _buildBody(
    OrderProvider provider,
    AdminProvider admin,
    List<OrderModel> orders,
  ) {
    if (provider.isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && orders.isEmpty) {
      return Center(
        child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text('No Orders Found', style: TextStyle(color: Colors.white70)),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) => _orderCard(orders[i], provider, admin),
      ),
    );
  }

  Widget _orderCard(
    OrderModel order,
    OrderProvider provider,
    AdminProvider admin,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => NavigationService.navigateTo(
        AppRoutes.orderDetail,
        arguments: order,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order: ${order.orderId}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text('User: ${order.userId}', style: const TextStyle(color: Colors.white70)),
            Text(
              '₹${order.totalAmount}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (order.createdAt != null)
              Text(
                order.createdAt.toString(),
                style: const TextStyle(color: Colors.white38),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusBadge(order.status),
                if (admin.isAdmin || admin.isStaff)
                  _statusDropdown(order, provider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusDropdown(OrderModel order, OrderProvider provider) {
    return DropdownButton<OrderStatus>(
      value: order.status,
      dropdownColor: const Color(0xFF1F2937),
      items: OrderStatus.values
          .map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(
                status.name.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        provider.updateOrderStatus(orderId: order.id, status: value);
      },
    );
  }

  Widget _statusBadge(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
