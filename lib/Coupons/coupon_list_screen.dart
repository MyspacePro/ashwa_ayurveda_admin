import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/coupon_provider.dart';

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});

  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CouponProvider>().listenCoupons());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.coupons.isEmpty) {
          return const Center(child: Text('No coupons found.'));
        }
        return ListView.builder(
          itemCount: provider.coupons.length,
          itemBuilder: (_, i) {
            final coupon = provider.coupons[i];
            return ListTile(
              title: Text(coupon.code),
              subtitle: Text('Discount: ${coupon.discountValue}'),
              trailing: Switch(
                value: coupon.isActive,
                onChanged: (_) => provider.toggleStatus(coupon),
              ),
            );
          },
        );
      },
    );
  }
}
