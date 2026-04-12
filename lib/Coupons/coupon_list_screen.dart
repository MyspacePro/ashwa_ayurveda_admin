import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/coupon_provider.dart';
import '../models/coupon_model.dart';

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});

  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CouponProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CouponProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Coupons"),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(CouponProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.coupons.isEmpty) {
      return const Center(child: Text("No Coupons Found"));
    }

    return RefreshIndicator(
      onRefresh: () async => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.coupons.length,
        itemBuilder: (_, i) {
          final coupon = provider.coupons[i];
          return _couponCard(provider, coupon);
        },
      ),
    );
  }

  // =========================
  // 🎴 COUPON CARD
  // =========================
  Widget _couponCard(CouponProvider provider, CouponModel coupon) {
    final isExpired = coupon.expiryDate.isBefore(DateTime.now());

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
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                coupon.code,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _statusBadge(isExpired, coupon.isActive),
                  const SizedBox(width: 8),
                  Switch(
                    value: coupon.isActive,
                    onChanged: (_) => provider.toggleStatus(coupon),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// DISCOUNT
          Text(
            _discountText(coupon),
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 4),

          /// MIN ORDER
          Text(
            "Min Order: ₹${coupon.minOrderAmount}",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),

          /// MAX DISCOUNT
          if (coupon.maxDiscount > 0)
            Text(
              "Max Discount: ₹${coupon.maxDiscount}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),

          const SizedBox(height: 6),

          /// USAGE COUNT
          Row(
            children: [
              const Icon(Icons.people, size: 14, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                "${coupon.usageCount} users claimed",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// EXPIRY
          Text(
            "Expires: ${_formatDate(coupon.expiryDate)}",
            style: TextStyle(
              color: isExpired ? Colors.red : Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 10),

          /// ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCoupon(provider, coupon),
              ),
            ],
          )
        ],
      ),
    );
  }

  // =========================
  // 🎨 STATUS BADGE
  // =========================
  Widget _statusBadge(bool isExpired, bool isActive) {
    String text;
    Color color;

    if (isExpired) {
      text = "EXPIRED";
      color = Colors.red;
    } else if (!isActive) {
      text = "INACTIVE";
      color = Colors.grey;
    } else {
      text = "ACTIVE";
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================
  // 💰 DISCOUNT TEXT (FIXED)
  // =========================
  String _discountText(CouponModel coupon) {
    if (coupon.discountType == CouponType.percentage) {
      return "${coupon.discountValue}% OFF";
    } else {
      return "₹${coupon.discountValue} OFF";
    }
  }

  // =========================
  // 📅 DATE FORMAT
  // =========================
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // =========================
  // ❌ DELETE
  // =========================
  void _deleteCoupon(CouponProvider provider, CouponModel coupon) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Coupon"),
        content: Text("Delete '${coupon.code}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.deleteCoupon(coupon.id);
    }
  }
}