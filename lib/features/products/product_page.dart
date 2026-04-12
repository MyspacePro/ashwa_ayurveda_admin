import 'package:admin_control/admin/admin_provider.dart';
import 'package:admin_control/providers/product_provider.dart';
import 'package:admin_control/widgets/product_card.dart';
import 'package:admin_control/core/routes/app_routes.dart';
import 'package:admin_control/core/routes/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().init();
    });
  }

  Future<void> _refresh() async {
    await context.read<ProductProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final adminProvider = context.watch<AdminProvider>();

    final isAdmin = adminProvider.isAdmin;
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
      ),

      // =========================
      // ADD BUTTON (ADMIN ONLY)
      // =========================
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                NavigationService.navigateTo(AppRoutes.addProduct);
              },
              child: const Icon(Icons.add),
            )
          : null,

      // =========================
      // BODY
      // =========================
      body: _buildBody(productProvider, products, isAdmin),
    );
  }

  Widget _buildBody(
    ProductProvider provider,
    List products,
    bool isAdmin,
  ) {
    // 🔄 LOADING
    if (provider.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // ❌ ERROR STATE
    if (provider.error != null && products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: provider.refresh,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // 📭 EMPTY STATE
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 50),
            const SizedBox(height: 10),
            const Text(
              "No Products Found",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

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
      );
    }

    // =========================
    // PRODUCT LIST
    // =========================
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = products[index];

          return ProductCard(
            product: product,
            isAdmin: isAdmin,
          );
        },
      ),
    );
  }
}