import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../../admin/admin_provider.dart';
import '../../models/cart_item_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Order Info"),
                  _infoTile("Order ID", order.orderId),
                  _infoTile("User ID", order.userId),
                  _infoTile("Date", _formatDate(order.createdAt)),

                  const SizedBox(height: 20),

                  _sectionTitle("Items"),
                  ...order.products.map((item) => _itemTile(item)).toList(),

                  const SizedBox(height: 20),

                  _sectionTitle("Price Details"),
                  _priceRow("Subtotal", order.subtotal),
                  _priceRow("Delivery Fee", order.deliveryFee),
                  _priceRow("Discount", -order.discount),
                  const Divider(),
                  _priceRow("Total", order.totalAmount, isBold: true),

                  const SizedBox(height: 20),

                  _sectionTitle("Payment"),
                  _infoTile("Method", order.paymentMethod),
                  _infoTile("Status", order.paymentStatus.name.toUpperCase()),

                  const SizedBox(height: 20),

                  _sectionTitle("Delivery"),
                  _infoTile("Address", order.address),

                  const SizedBox(height: 20),

                  _sectionTitle("Order Status"),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statusBadge(order.status.name),

                      if (adminProvider.isAdmin || adminProvider.isStaff)
                        DropdownButton<String>(
                          value: order.status.name,
                          isExpanded: false,
                          items: OrderStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status.name,
                              child: Text(status.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: orderProvider.isLoading
                              ? null
                              : (value) async {
                                  if (value == null) return;

                                  final status =
                                      _parseOrderStatus(value);

                                  await orderProvider.updateOrderStatus(
                                orderId: order.id,
                                   status: status,
                                            );
                                },
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // =========================
  // 🔹 HELPERS
  // =========================

  OrderStatus _parseOrderStatus(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTile(CartItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: item.image.isNotEmpty
            ? Image.network(item.image,
                width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image),

        title: Text(item.name),
        subtitle: Text("Qty: ${item.quantity}"),
        trailing: Text(
          "₹${item.total.toStringAsFixed(0)}",
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "confirmed":
        return Colors.purple;
      case "shipped":
        return Colors.blue;
      case "delivered":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}