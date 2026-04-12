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

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _description = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  String? _categoryId;
  String? _subCategoryId;

  bool _isFeatured = false;
  bool _isActive = true;
  bool _isLoading = false;

  final _imageUploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<CategoryProvider>();
provider.init();
    });
  }

  // =========================
  // 📸 IMAGE PICKER
  // =========================
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (!mounted) return;

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _imageName = result.files.single.name;
      });
    }
  }

  // =========================
  // ➕ ADD PRODUCT
  // =========================
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      _snack('Please upload product image');
      return;
    }

    if (_categoryId == null || _categoryId!.isEmpty) {
      _snack('Please select category');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // 🔥 Upload image
      final imageUrl = await _imageUploadService.uploadProductImage(
        _imageBytes!,
        'products',
      );

      // 🔥 Create product
      final product = ProductModel(
        id: '',
        name: _name.text.trim(),
        price: double.parse(_price.text.trim()),
        description: _description.text.trim(),
        images: [imageUrl],
        categoryId: _categoryId!,
        subCategoryId: _subCategoryId ?? '',
        stock: int.parse(_stock.text.trim()),
        isFeatured: _isFeatured,
        isActive: _isActive,
      );

      await context.read<ProductProvider>().addProduct(product);

      if (!mounted) return;

      _snack('Product added successfully');
      Navigator.pop(context);
    } catch (e) {
      _snack('Failed to add product');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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

    final List<category_model.CategoryModel> categories =
        categoryProvider.categories;

    final List<SubCategory> subCategories =
        (_categoryId == null)
            ? []
            : categoryProvider.subCategoriesByCategory(_categoryId!);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Stack(
        children: [
          _buildForm(categories, subCategories),

          /// 🔥 LOADING OVERLAY
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Product",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: _field(_name, "Product Name")),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_price, "Price", isNumber: true)),
                  ],
                ),

                const SizedBox(height: 16),

                _field(_description, "Description", maxLines: 3),

                const SizedBox(height: 16),

                /// CATEGORY
                Row(
                  children: [
                    Expanded(
                      child: _dropdown(
                        value: _categoryId,
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdown(
                        value: _subCategoryId,
                        hint: "Sub Category",
                        items: subCategories.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          );
                        }).toList(),
                        onChanged: (_categoryId == null)
                            ? null
                            : (v) => setState(() => _subCategoryId = v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _field(_stock, "Stock", isNumber: true),

                const SizedBox(height: 16),

                /// IMAGE
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              _imageName ?? "Upload Image",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text("Featured",
                      style: TextStyle(color: Colors.white)),
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                ),

                SwitchListTile(
                  title: const Text("Active",
                      style: TextStyle(color: Colors.white)),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _addProduct,
                      child: const Text("Add Product"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // 🔧 INPUT FIELD
  // =========================
  Widget _field(
    TextEditingController c,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: c,
      enabled: !_isLoading,
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
          return 'Enter valid number';
        }
        return null;
      },
    );
  }

  // =========================
  // 🔧 DROPDOWN
  // =========================
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: items,
    );
  }
}