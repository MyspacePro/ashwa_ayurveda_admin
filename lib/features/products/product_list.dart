import 'package:admin_control/admin/admin_provider.dart';
import 'package:admin_control/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    /// 🔥 SAFE INIT (NO BUILD CONTEXT ISSUE)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().init();
    });
  }

  // =========================
  // 🧱 UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final adminProvider = context.watch<AdminProvider>();

    final isAdmin = adminProvider.isAdmin;
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: "Add Product",
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/add-product');
              },
            ),
        ],
      ),

      body: _buildBody(productProvider, products, isAdmin),
    );
  }

  // =========================
  // 🔥 BODY HANDLER
  // =========================
  Widget _buildBody(
    ProductProvider provider,
    List products,
    bool isAdmin,
  ) {
    // 🔄 LOADING
    if (provider.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // ❌ ERROR
    if (provider.error != null && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                provider.refresh();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    // 📭 EMPTY STATE
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "No Products Found",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (isAdmin)
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Product"),
                onPressed: () {
                  Navigator.pushNamed(context, '/add-product');
                },
              ),
          ],
        ),
      );
    }

    // =========================
    // 📦 PRODUCT LIST
    // =========================
    return RefreshIndicator(
      onRefresh: () async {
        await provider.refresh();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final product = products[i];

          return ProductCard(
            product: product,
            isAdmin: isAdmin,
          );
        },
      ),
    );
  }
}