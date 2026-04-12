import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/delivery_model.dart';
import '../../providers/delivery_provider.dart';

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  String _search = '';
  DeliveryStatus? _filterStatus;

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

    final filtered = provider.deliveries.where((d) {
      final matchSearch = d.orderId
              .toLowerCase()
              .contains(_search.toLowerCase()) ||
          d.trackingId
              .toLowerCase()
              .contains(_search.toLowerCase());

      final matchStatus =
          _filterStatus == null || d.deliveryStatus == _filterStatus;

      return matchSearch && matchStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Management"),
      ),
      body: Column(
        children: [
          _topBar(),
          Expanded(child: _buildBody(provider, filtered)),
        ],
      ),
    );
  }

  // =========================
  // 🔍 SEARCH + FILTER
  // =========================
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _search = val),
            decoration: InputDecoration(
              hintText: "Search Order / Tracking ID",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Text("Filter: "),
              const SizedBox(width: 10),

              DropdownButton<DeliveryStatus?>(
                value: _filterStatus,
                hint: const Text("All"),
                onChanged: (val) {
                  setState(() => _filterStatus = val);
                },
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("All"),
                  ),
                  ...DeliveryStatus.values.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e.name.toUpperCase()),
                    );
                  })
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  // =========================
  // 🔥 BODY
  // =========================
  Widget _buildBody(
      DeliveryProvider provider, List<DeliveryModel> list) {
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

    if (list.isEmpty) {
      return const Center(child: Text("No Deliveries Found"));
    }

    return RefreshIndicator(
      onRefresh: () async => provider.init(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final d = list[i];
          return _deliveryCard(provider, d);
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
          /// ORDER + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order: ${d.orderId}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              _statusBadge(d.deliveryStatus),
            ],
          ),

          const SizedBox(height: 10),

          /// PARTNER
          Text(
            "Partner: ${d.deliveryPartner.isEmpty ? '-' : d.deliveryPartner}",
            style: const TextStyle(color: Colors.white70),
          ),

          /// TRACKING
          Text(
            "Tracking: ${d.trackingId.isEmpty ? '-' : d.trackingId}",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 10),

          /// ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<DeliveryStatus>(
                value: d.deliveryStatus,
                dropdownColor: const Color(0xFF1F2937),
                style: const TextStyle(color: Colors.white),
                onChanged: (val) {
                  if (val == null) return;
                  provider.updateDelivery(
                    orderId: d.orderId,
                    status: val,
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

              IconButton(
                icon: const Icon(Icons.edit, color: Colors.amber),
                onPressed: () => _editDialog(provider, d),
              )
            ],
          )
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
        case DeliveryStatus.failed
        :
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
  void _editDialog(DeliveryProvider provider, DeliveryModel d) {
    final partner = TextEditingController(text: d.deliveryPartner);
    final tracking = TextEditingController(text: d.trackingId);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Delivery"),
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