import 'dart:typed_data';

import 'package:admin_control/models/category_model.dart' as category_model;
import 'package:admin_control/models/product_model.dart';
import 'package:admin_control/models/subcategory_model.dart';
import 'package:admin_control/providers/category_provider.dart';
import 'package:admin_control/screens/image_upload_service.dart';
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
      provider.listenToCategories();
      provider.listenToSubCategories();
    });
  }

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

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {
      _snack('Please select product image');
      return;
    }
    if (_categoryId == null || _categoryId!.isEmpty) {
      _snack('Please select category');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final imageUrl = await _imageUploadService.uploadProductImage(
        _imageBytes!,
        'products',
      );

      final product = ProductModel(
        id: '',
        name: _name.text.trim(),
        price: double.tryParse(_price.text.trim()) ?? 0,
        description: _description.text.trim(),
        images: [imageUrl],
        categoryId: _categoryId!,
        subCategoryId: _subCategoryId ?? '',
        stock: int.tryParse(_stock.text.trim()) ?? 0,
        isFeatured: _isFeatured,
        isActive: _isActive,
      );

      await context.read<ProductProvider>().addProduct(product);

      if (!mounted) return;
      _snack('Product added successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
        ? <SubCategory>[]
        : categoryProvider.subCategoriesByCategory(_categoryId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_name, 'Product Name'),
                _field(_price, 'Price', isNumber: true),
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (category_model.Category c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _categoryId = value;
                            _subCategoryId = null;
                          });
                          context
                              .read<CategoryProvider>()
                              .listenToSubCategories(categoryId: value);
                        },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _subCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory',
                    border: OutlineInputBorder(),
                  ),
                  items: subCategories
                      .map(
                        (s) => DropdownMenuItem<String>(
                          value: s.id,
                          child: Text(s.name),
                        ),
                      )
                      .toList(),
                  onChanged: _isLoading ? null : (value) => setState(() => _subCategoryId = value),
                ),
                const SizedBox(height: 12),
                _field(_stock, 'Stock', isNumber: true),
                _field(_description, 'Description', maxLines: 3),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Select Image'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_imageName ?? 'No image selected'),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Featured'),
                  value: _isFeatured,
                  onChanged: _isLoading ? null : (v) => setState(() => _isFeatured = v),
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: _isLoading ? null : (v) => setState(() => _isActive = v),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addProduct,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Add Product'),
                  ),
                ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        enabled: !_isLoading,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Enter $label';
          if (isNumber && (num.tryParse(v.trim()) == null)) {
            return 'Enter valid number';
          }
          return null;
        },
      ),
    );
  }
}
