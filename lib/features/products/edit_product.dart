import 'dart:typed_data';

import 'package:admin_control/models/category_model.dart' as category_model;
import 'package:admin_control/models/product_model.dart';
import 'package:admin_control/models/subcategory_model.dart';
import 'package:admin_control/providers/category_provider.dart';
import 'package:admin_control/services/firebase/image_upload_service.dart';
import 'package:file_picker/file_picker.dart';
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

  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _description = TextEditingController();

  String? _categoryId;
  String? _subCategoryId;

  Uint8List? _newImage;
  String? _currentImage;

  bool _isFeatured = false;
  bool _isActive = true;
  bool _isLoading = false;

  final _imageService = ImageUploadService();

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    _name.text = p.name;
    _price.text = p.price.toString();
    _stock.text = p.stock.toString();
    _description.text = p.description;

    _categoryId = p.categoryId;
    _subCategoryId = p.subCategoryId;
    _currentImage = p.primaryImage;

    _isFeatured = p.isFeatured;
    _isActive = p.isActive;

    Future.microtask(() {
      final provider = context.read<CategoryProvider>();
provider.init();
    });
  }

  // =========================
  // 📸 PICK IMAGE
  // =========================
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (!mounted) return;

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _newImage = result.files.single.bytes;
      });
    }
  }

  // =========================
  // 🔄 UPDATE
  // =========================
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoryId == null || _categoryId!.isEmpty) {
      _snack("Select category");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _currentImage ?? '';

      /// 🔥 Upload new image if changed
      if (_newImage != null) {
        imageUrl = await _imageService.uploadProductImage(
          _newImage!,
          'products',
        );
      }

      final updated = widget.product.copyWith(
        name: _name.text.trim(),
        price: double.parse(_price.text.trim()),
        stock: int.parse(_stock.text.trim()),
        description: _description.text.trim(),
        categoryId: _categoryId!,
        subCategoryId: _subCategoryId ?? '',
        images: [imageUrl],
        isFeatured: _isFeatured,
        isActive: _isActive,
      );

      await context.read<ProductProvider>().updateProduct(updated);

      if (!mounted) return;

      _snack("Product updated");
      Navigator.pop(context);
    } catch (e) {
      _snack("Update failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    final categories = categoryProvider.categories;

    final subCategories = (_categoryId == null)
        ? []
        : categoryProvider.subCategoriesByCategory(_categoryId!);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Stack(
        children: [
          _buildForm(
  categories,
  subCategories.cast<SubCategory>(),
),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }

  Widget _buildForm(
    List<category_model.CategoryModel> categories,
    List<SubCategory> subCategories,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text("Edit Product",
                    style: TextStyle(color: Colors.white, fontSize: 22)),

                const SizedBox(height: 20),

                _field(_name, "Name"),
                _field(_price, "Price", isNumber: true),
                _field(_stock, "Stock", isNumber: true),
                _field(_description, "Description", maxLines: 3),

                const SizedBox(height: 10),

                /// CATEGORY
                _dropdown(
                  value: categories.any((c) => c.id == _categoryId)
                     ? _categoryId
                        : null,
                  hint: "Category",
                  items: categories.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _categoryId = v;
                      _subCategoryId = null;
                    });
                  },
                ),

                const SizedBox(height: 10),

                _dropdown(
                  value: subCategories.any((s) => s.id == _subCategoryId)
                ? _subCategoryId
                   : null,
                  hint: "SubCategory",
                  items: subCategories.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _subCategoryId = v),
                ),

                const SizedBox(height: 16),

                /// IMAGE PREVIEW
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _newImage != null
                        ? Image.memory(_newImage!, fit: BoxFit.cover)
                        : (_currentImage != null &&
                                _currentImage!.isNotEmpty)
                            ? Image.network(_currentImage!,
                                fit: BoxFit.cover)
                            : const Center(
                                child: Text("Upload Image",
                                    style:
                                        TextStyle(color: Colors.white70)),
                              ),
                  ),
                ),

                const SizedBox(height: 10),

                SwitchListTile(
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                  title: const Text("Featured",
                      style: TextStyle(color: Colors.white)),
                ),

                SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text("Active",
                      style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProduct,
                  child: const Text("Update Product"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Enter $label';
          if (isNumber && num.tryParse(v) == null) {
            return 'Invalid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF1F2937),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF1F2937),
      ),
      items: items,
    );
  }
}