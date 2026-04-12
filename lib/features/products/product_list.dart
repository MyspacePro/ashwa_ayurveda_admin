import 'package:admin_control/admin/admin_provider.dart';
import 'package:admin_control/models/product_model.dart';
import 'package:admin_control/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/navigation_service.dart';
import '../../providers/product_provider.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  @override
  void initState() {
    super.initState();

    /// 🔥 SAFE INIT
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final adminProvider = context.watch<AdminProvider>();

    final isAdmin = adminProvider.isAdmin;
    final List<ProductModel> products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: "Add Product",
              icon: const Icon(Icons.add),
              onPressed: () => _goToAddProduct(context),
            ),
        ],
      ),
      body: _buildBody(productProvider, products, isAdmin),
    );
  }

  // =========================
  // 🔥 NAVIGATION
  // =========================
  void _goToAddProduct(BuildContext context) {
    NavigationService.navigateTo(AppRoutes.addProduct);
  }

  // =========================
  // 🔥 BODY HANDLER
  // =========================
  Widget _buildBody(
    ProductProvider provider,
    List<ProductModel> products,
    bool isAdmin,
  ) {
    /// 🔄 FIRST LOAD
    if (provider.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    /// ❌ ERROR STATE
    if (provider.error != null && products.isEmpty) {
      return _ErrorState(
        message: provider.error!,
        onRetry: provider.refresh,
      );
    }

    /// 📭 EMPTY STATE
    if (products.isEmpty) {
      return _EmptyState(isAdmin: isAdmin);
    }

    /// 📦 PRODUCT LIST
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final product = products[i];

          return ProductCard(
            key: ValueKey(product.id), // 🔥 performance boost
            product: product,
            isAdmin: isAdmin,
          );
        },
      ),
    );
  }
}

//
// =========================
// ❌ ERROR UI (REUSABLE)
// =========================
class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}

//
// =========================
// 📭 EMPTY UI (REUSABLE)
// =========================
class _EmptyState extends StatelessWidget {
  final bool isAdmin;

  const _EmptyState({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 50),
            const SizedBox(height: 10),
            const Text(
              "No Products Found",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (isAdmin)
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Product"),
                onPressed: () {
                  NavigationService.navigateTo(AppRoutes.addProduct);
                },
              ),
          ],
        ),
      ),
    );
  }
}