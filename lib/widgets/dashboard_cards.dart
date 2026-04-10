import 'package:flutter/material.dart';

class DashboardCards extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;
  final int pending;
  final int delivered;

  const DashboardCards({
    super.key,
    required this.totalRevenue,
    required this.totalOrders,
    required this.pending,
    required this.delivered,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            DashboardCard(
              title: "Revenue",
              value: "₹${totalRevenue.toStringAsFixed(0)}",
              icon: Icons.currency_rupee,
              color: Colors.green,
              width: isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 2) - 12,
            ),
            DashboardCard(
              title: "Orders",
              value: totalOrders.toString(),
              icon: Icons.shopping_cart,
              color: Colors.blue,
              width: isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 2) - 12,
            ),
            DashboardCard(
              title: "Pending",
              value: pending.toString(),
              icon: Icons.hourglass_bottom,
              color: Colors.orange,
              width: isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 2) - 12,
            ),
            DashboardCard(
              title: "Delivered",
              value: delivered.toString(),
              icon: Icons.check_circle,
              color: Colors.purple,
              width: isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth / 2) - 12,
            ),
          ],
        );
      },
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}