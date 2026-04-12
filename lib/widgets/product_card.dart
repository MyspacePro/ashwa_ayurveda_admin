import 'package:admin_control/core/routes/app_routes.dart';
import 'package:admin_control/core/routes/navigation_service.dart';
import 'package:admin_control/models/product_model.dart';
import 'package:admin_control/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isAdmin;

  const ProductCard({
    super.key,
    required this.product,
    required this.isAdmin,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final categoryProvider = context.watch<CategoryProvider>();

    final category =
        categoryProvider.getCategoryById(product.categoryId);
    final subCategory =
        categoryProvider.getSubCategoryById(product.subCategoryId);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _goToEdit(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildImage(product),

              const SizedBox(width: 12),

              Expanded(
                child: _buildContent(
                  product,
                  category?.name,
                  subCategory?.name,
                ),
              ),

              if (widget.isAdmin) _buildActions(context, product),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // IMAGE
  // =========================
  Widget _buildImage(ProductModel product) {
    final image = product.primaryImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image.isNotEmpty
          ? Image.network(
              image,
              width: 75,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 75,
      height: 75,
      color: Colors.grey.withOpacity(0.15),
      child: const Icon(Icons.image, color: Colors.white24),
    );
  }

  // =========================
  // CONTENT
  // =========================
  Widget _buildContent(
    ProductModel product,
    String? categoryName,
    String? subCategoryName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 4),

        /// CATEGORY + SUBCATEGORY
        Text(
          "${categoryName ?? 'Unknown'}"
          "${subCategoryName != null ? " • $subCategoryName" : ""}",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),

        const SizedBox(height: 8),

        _buildPriceRow(product),

        const SizedBox(height: 6),

        _buildMetaRow(product),

        const SizedBox(height: 6),

        _buildStatusRow(product),
      ],
    );
  }

  // =========================
  // PRICE
  // =========================
  Widget _buildPriceRow(ProductModel product) {
    return Row(
      children: [
        Text(
          product.formattedPrice,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 6),

        if (product.hasDiscount && product.originalPrice != null)
          Text(
            "₹${product.originalPrice}",
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.white38,
              fontSize: 12,
            ),
          ),

        if (product.hasDiscount)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              "-${product.discount}%",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // =========================
  // META (RATING + STOCK)
  // =========================
  Widget _buildMetaRow(ProductModel product) {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          product.safeRating.toString(),
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),

        const SizedBox(width: 10),

        /// 🔥 STOCK BADGE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: product.inStock
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            product.stockStatus,
            style: TextStyle(
              fontSize: 10,
              color: product.inStock ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // STATUS BADGES
  // =========================
  Widget _buildStatusRow(ProductModel product) {
    return Row(
      children: [
        if (product.isFeatured)
          _badge("Featured", Colors.orange),

        if (!product.isActive)
          _badge("Inactive", Colors.red),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================
  // ACTIONS
  // =========================
  Widget _buildActions(BuildContext context, ProductModel product) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.amber),
          onPressed: () => _goToEdit(context),
        ),
        _isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
      ],
    );
  }

  // =========================
  // NAVIGATION
  // =========================
  void _goToEdit(BuildContext context) {
    NavigationService.navigateTo(
      AppRoutes.editProduct,
      arguments: widget.product,
    );
  }

  // =========================
  // DELETE
  // =========================
  Future<void> _confirmDelete(BuildContext context) async {
    final product = widget.product;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Delete '${product.name}'?"),
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

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isDeleting = true);

    try {
      await context.read<ProductProvider>().deleteProduct(product.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted")),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete product")),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}