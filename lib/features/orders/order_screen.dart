import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../../admin/admin_provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderListState();
}

class _OrderListState extends State<OrderScreen> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// 🔥 Prevent multiple listeners
    if (!_isInit) {
      _isInit = true;

      Future.microtask(() {
        Provider.of<OrderProvider>(context, listen: false)
            .listenToOrders();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
      ),
      body: _buildBody(orderProvider, adminProvider, orders),
    );
  }

  Widget _buildBody(
    OrderProvider provider,
    AdminProvider adminProvider,
    List<OrderModel> orders,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    if (orders.isEmpty) {
      return const Center(child: Text("No Orders Found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🆔 ORDER ID (FIXED)
                Text(
                  "Order ID: ${order.orderId}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // 👤 USER
                Text("User: ${order.userId ?? "Unknown"}"),

                // 💰 TOTAL
                Text("Total: ₹${order.totalAmount}"),

                // 📅 DATE
                if (order.createdAt != null)
                  Text(
                    "Date: ${order.createdAt!.toString().substring(0, 16)}",
                  ),

                const SizedBox(height: 12),

                // 🔄 STATUS ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusBadge(order.status),

                    if (adminProvider.isAdmin || adminProvider.isStaff)
                      _statusDropdown(order, provider),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // 🔽 STATUS DROPDOWN (SAFE)
  // =========================
  Widget _statusDropdown(
    OrderModel order,
    OrderProvider provider,
  ) {
    return DropdownButton<OrderStatus>(
      value: order.status,
      items: OrderStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          provider.updateOrderStatus(
            orderId: order.id,
            status: value,
          );
        }
      },
    );
  }

  // =========================
  // 🎨 STATUS BADGE
  // =========================
  Widget _statusBadge(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // =========================
  // 🎨 STATUS COLOR
  // =========================
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}