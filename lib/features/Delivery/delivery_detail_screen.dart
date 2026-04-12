import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/delivery_model.dart';
import '../../providers/delivery_provider.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final DeliveryModel delivery;

  const DeliveryDetailsScreen({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DeliveryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(delivery),
            const SizedBox(height: 16),

            _timeline(delivery.deliveryStatus),
            const SizedBox(height: 16),

            _infoCard(delivery),
            const SizedBox(height: 16),

            _actions(context, provider, delivery),
          ],
        ),
      ),
    );
  }

  // =========================
  // 🧾 HEADER
  // =========================
  Widget _header(DeliveryModel d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Order: ${d.orderId}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          _statusBadge(d.deliveryStatus),
        ],
      ),
    );
  }

  // =========================
  // 📦 TIMELINE
  // =========================
  Widget _timeline(DeliveryStatus status) {
    return Column(
      children: DeliveryStatus.values.map((s) {
        final isActive = s.index <= status.index;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: isActive ? Colors.green : Colors.grey,
                ),
                Container(
                  width: 2,
                  height: 30,
                  color: isActive ? Colors.green : Colors.grey,
                )
              ],
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _statusText(s),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  // =========================
  // 📄 INFO CARD
  // =========================
  Widget _infoCard(DeliveryModel d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row("Delivery Partner", d.deliveryPartner),
          _row("Tracking ID", d.trackingId),
          _row(
            "Last Updated",
            d.updatedAt?.toString().substring(0, 16) ?? "-",
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // =========================
  // ⚙️ ACTIONS
  // =========================
  Widget _actions(BuildContext context,
      DeliveryProvider provider, DeliveryModel d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Update Status",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        DropdownButton<DeliveryStatus>(
          value: d.deliveryStatus,
          isExpanded: true,
          onChanged: (val) async {
            if (val == null) return;

            await provider.updateDelivery(
              orderId: d.orderId,
              status: val,
              partner: d.deliveryPartner,
              trackingId: d.trackingId,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Status updated")),
            );
          },
          items: DeliveryStatus.values.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e.name.toUpperCase()),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit Delivery Info"),
            onPressed: () => _editDialog(context, provider, d),
          ),
        )
      ],
    );
  }

  // =========================
  // ✏️ EDIT DIALOG
  // =========================
  void _editDialog(BuildContext context,
      DeliveryProvider provider, DeliveryModel d) {
    final partner = TextEditingController(text: d.deliveryPartner);
    final tracking = TextEditingController(text: d.trackingId);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Delivery"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: partner,
              decoration:
                  const InputDecoration(labelText: "Partner"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tracking,
              decoration:
                  const InputDecoration(labelText: "Tracking ID"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await provider.updateDelivery(
                orderId: d.orderId,
                status: d.deliveryStatus,
                partner: partner.text.trim(),
                trackingId: tracking.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🎨 STATUS BADGE
  // =========================
  Widget _statusBadge(DeliveryStatus status) {
    Color color;

    switch (status) {
      case DeliveryStatus.pending:
        color = Colors.orange;
        break;
      case DeliveryStatus.shipped:
        color = Colors.blue;
        break;
      case DeliveryStatus.outForDelivery:
        color = Colors.indigo;
        break;
      case DeliveryStatus.delivered:
        color = Colors.green;
        break;
        case DeliveryStatus.failed:
      color = Colors.red;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _statusText(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.pending:
        return "Order Placed";
      case DeliveryStatus.shipped:
        return "Shipped";
      case DeliveryStatus.outForDelivery:
        return "Out for Delivery";
      case DeliveryStatus.delivered:
        return "Delivered";
        case DeliveryStatus.failed:
      return "failed";
    }
  }
}