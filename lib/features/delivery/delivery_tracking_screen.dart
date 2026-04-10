import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/delivery_model.dart';
import '../../providers/delivery_provider.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DeliveryProvider>().listenToDeliveries());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(builder: (_, provider, __) {
      if (provider.isLoading && provider.deliveries.isEmpty) return const Center(child: CircularProgressIndicator());
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.deliveries.length,
        itemBuilder: (_, i) {
          final d = provider.deliveries[i];
          return Card(
            child: ListTile(
              title: Text('Order ${d.orderId}'),
              subtitle: Text('Partner: ${d.deliveryPartner.isEmpty ? '-' : d.deliveryPartner} | Tracking: ${d.trackingId.isEmpty ? '-' : d.trackingId}'),
              trailing: DropdownButton<DeliveryStatus>(
                value: d.deliveryStatus,
                onChanged: (value) async {
                  if (value == null) return;
                  await provider.updateDelivery(orderId: d.orderId, status: value, partner: d.deliveryPartner, trackingId: d.trackingId);
                },
                items: DeliveryStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
              ),
            ),
          );
        },
      );
    });
  }
}
