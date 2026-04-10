import 'package:admin_control/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';

class EditProduct extends StatefulWidget {
  final ProductModel product;

  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _stockController;
  late TextEditingController _subCategoryController;
  late TextEditingController _descriptionController;

  bool _isFeatured = false;
  bool _isActive = true;
  bool _isLoading = false;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    _nameController = TextEditingController(text: p.name);
    _priceController = TextEditingController(text: p.price.toString());
    _categoryController =
    TextEditingController(text: p.categoryId);
    _stockController = TextEditingController(text: p.stock.toString());
    _subCategoryController = TextEditingController(text: p.subCategoryId);
    _descriptionController = TextEditingController(text: p.description);

    _isFeatured = p.isFeatured;
    _isActive = p.isActive;

    _addListeners();
  }

  void _addListeners() {
    for (final c in [
      _nameController,
      _priceController,
      _categoryController,
      _stockController,
      _subCategoryController,
      _descriptionController,
    ]) {
      c.addListener(() {
        if (!_hasChanges) {
          setState(() => _hasChanges = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _subCategoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // =========================
  // 🔥 UPDATE PRODUCT
  // =========================
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No changes detected")),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final updatedProduct = widget.product.copyWith(
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        categoryId: _categoryController.text.trim(),
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
        subCategoryId: _subCategoryController.text.trim(),
        description: _descriptionController.text.trim(),
        isFeatured: _isFeatured,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      await context.read<ProductProvider>().updateProduct(updatedProduct);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully")),
      );

      Navigator.pop(context, updatedProduct);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================
  // 🧱 UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Product"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Basic Info"),
                  _field(_nameController, "Product Name"),
                  _field(_priceController, "Price", isNumber: true),

                  const SizedBox(height: 10),

                  _sectionTitle("Category & Stock"),
                  _field(_categoryController, "Category"),
                  _field(_stockController, "Stock", isNumber: true),
                  _field(_subCategoryController, "Subcategory ID"),

                  const SizedBox(height: 10),

                  _sectionTitle("Description"),
                  _field(
                    _descriptionController,
                    "Description",
                    maxLines: 3,
                  ),

                  const SizedBox(height: 10),

                  _sectionTitle("Settings"),
                  SwitchListTile(
                    title: const Text("Featured"),
                    value: _isFeatured,
                    onChanged: _isLoading
                        ? null
                        : (val) {
                            setState(() {
                              _isFeatured = val;
                              _hasChanges = true;
                            });
                          },
                  ),

                  SwitchListTile(
                    title: const Text("Active"),
                    value: _isActive,
                    onChanged: _isLoading
                        ? null
                        : (val) {
                            setState(() {
                              _isActive = val;
                              _hasChanges = true;
                            });
                          },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProduct,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Update Product"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // 🧩 FIELD
  // =========================
  Widget _field(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: !_isLoading,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Enter $label";
          }

          if (isNumber) {
            final parsed = num.tryParse(value.trim());
            if (parsed == null || parsed < 0) {
              return "Enter valid number";
            }
          }

          return null;
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}