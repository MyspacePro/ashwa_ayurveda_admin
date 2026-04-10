import 'package:admin_control/features/products/edit_product.dart';
import 'package:admin_control/models/product_model.dart';
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
    final theme = Theme.of(context);
    final product = widget.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _goToEdit(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildImage(),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(theme, product),
                      const SizedBox(height: 4),
                      _buildCategory(theme, product),
                      const SizedBox(height: 8),
                      _buildPriceRow(product),
                      const SizedBox(height: 6),
                      _buildMetaRow(product),
                    ],
                  ),
                ),

                if (widget.isAdmin) _buildActions(context, product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // IMAGE
  // =========================
  Widget _buildImage() {
    final product = widget.product;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: product.images.isNotEmpty
          ? Image.network(
              product.images as String,
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
      color: Colors.grey.withOpacity(0.2),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  // =========================
  // TITLE
  // =========================
  Widget _buildTitle(ThemeData theme, ProductModel product) {
    return Text(
      product.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // =========================
  // CATEGORY
  // =========================
  Widget _buildCategory(ThemeData theme, ProductModel product) {
    return Text(
      product.categoryId,
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.grey,
      ),
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
          ),
        ),
        const SizedBox(width: 6),

        if (product.hasDiscount)
          Text(
            "₹${product.originalPrice}",
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
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
  // META
  // =========================
  Widget _buildMetaRow(ProductModel product) {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          product.safeRating.toString(),
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(width: 10),
        Text(
          product.stockStatus,
          style: TextStyle(
            fontSize: 12,
            color: product.inStock ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  // =========================
  // ACTIONS (ADMIN)
  // =========================
  Widget _buildActions(BuildContext context, ProductModel product) {
    return _isDeleting
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          );
  }

  // =========================
  // NAVIGATION
  // =========================
  void _goToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProduct(product: widget.product),
      ),
    );
  }

  // =========================
  // DELETE (SAFE)
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}