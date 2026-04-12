import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/delivery_model.dart';
import '../../providers/delivery_provider.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() =>
      _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState
    extends State<DeliveryTrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeliveryProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Tracking"),
      ),
      body: _buildBody(provider),
    );
  }

  // =========================
  // 🔥 BODY
  // =========================
  Widget _buildBody(DeliveryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (provider.deliveries.isEmpty) {
      return const Center(child: Text("No Deliveries Found"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.init();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.deliveries.length,
        itemBuilder: (_, i) {
          final delivery = provider.deliveries[i];
          return _deliveryCard(provider, delivery);
        },
      ),
    );
  }

  // =========================
  // 🎴 DELIVERY CARD
  // =========================
  Widget _deliveryCard(
      DeliveryProvider provider, DeliveryModel d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 ORDER + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order: ${d.orderId}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              _statusBadge(d.deliveryStatus),
            ],
          ),

          const SizedBox(height: 10),

          /// 🚚 PARTNER
          Row(
            children: [
              const Icon(Icons.local_shipping,
                  size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(
                d.deliveryPartner.isEmpty
                    ? "No Partner Assigned"
                    : d.deliveryPartner,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// 🔗 TRACKING
          Row(
            children: [
              const Icon(Icons.confirmation_number,
                  size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                d.trackingId.isEmpty
                    ? "No Tracking ID"
                    : d.trackingId,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔄 STATUS DROPDOWN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<DeliveryStatus>(
                value: d.deliveryStatus,
                dropdownColor: const Color(0xFF1F2937),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) async {
                  if (value == null) return;

                  await provider.updateDelivery(
                    orderId: d.orderId,
                    status: value,
                    partner: d.deliveryPartner,
                    trackingId: d.trackingId,
                  );
                },
                items: DeliveryStatus.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.name.toUpperCase()),
                  );
                }).toList(),
              ),

              /// ✏️ EDIT BUTTON
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.amber),
                onPressed: () => _editDeliveryDialog(provider, d),
              )
            ],
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
        color = Colors.green;
        break;
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

  // =========================
  // ✏️ EDIT DIALOG
  // =========================
  void _editDeliveryDialog(
      DeliveryProvider provider, DeliveryModel d) {
    final partnerController =
        TextEditingController(text: d.deliveryPartner);
    final trackingController =
        TextEditingController(text: d.trackingId);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Delivery"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: partnerController,
              decoration:
                  const InputDecoration(labelText: "Delivery Partner"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: trackingController,
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
                partner: partnerController.text.trim(),
                trackingId: trackingController.text.trim(),
              );

              if (mounted) Navigator.pop(context);
            },
            child: const Text(
              "Update",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}