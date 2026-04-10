import 'dart:typed_data';
import 'package:admin_control/models/product_model.dart';
// import 'package:admin_control/screens/image_upload_service.dart'; // ❌ NOT USED (commented)
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
  final _category = TextEditingController();
  final _stock = TextEditingController();
  final _description = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  bool _isFeatured = false;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isImageLoading = false;

  // ==================================================
  // 🧪 TEST MODE (ENABLE/DISABLE HERE)
  // ==================================================
  final bool isTestMode = true;

  // ==================================================
  // 🖼 PICK IMAGE (COMMENTED FOR TEST MODE OPTION)
  // ==================================================
  Future<void> _pickImage() async {
    if (isTestMode) {
      _snack("Test Mode: Image upload disabled");
      return;
    }

    if (_isImageLoading) return;

    setState(() => _isImageLoading = true);

    try {
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
    } catch (e) {
      _snack("Image pick failed: $e");
    } finally {
      if (mounted) setState(() => _isImageLoading = false);
    }
  }

  // ==================================================
  // ➕ ADD PRODUCT
  // ==================================================
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // ❌ IMAGE VALIDATION REMOVED FOR TEST MODE
    // if (_imageBytes == null) {
    //   _snack("Please select product image");
    //   return;
    // }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // 🧪 TEST IMAGE URL
      final imageUrl = isTestMode
          ? "https://dummyimage.com/300x300"
          : "https://dummyimage.com/300x300"; // replace with real upload later

      final product = ProductModel(
  id: '',
  name: _name.text.trim(),
  price: double.tryParse(_price.text.trim()) ?? 0,
  description: _description.text.trim(),

  /// 🔥 FIX HERE
  images: [imageUrl], // list banana mandatory hai
  categoryId: _category.text.trim(), // category → categoryId

  stock: int.tryParse(_stock.text.trim()) ?? 0,
  isFeatured: _isFeatured,
  isActive: _isActive,

  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
      await context.read<ProductProvider>().addProduct(product);

      if (!mounted) return;

      _clearForm();
      _snack("Product added successfully");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _snack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==================================================
  // 🧹 CLEAR FORM
  // ==================================================
  void _clearForm() {
    _name.clear();
    _price.clear();
    _category.clear();
    _stock.clear();
    _description.clear();

    setState(() {
      _imageBytes = null;
      _imageName = null;
      _isFeatured = false;
      _isActive = true;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _category.dispose();
    _stock.dispose();
    _description.dispose();
    super.dispose();
  }

  // ==================================================
  // 🧱 UI
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create New Product",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _sectionTitle("Basic Info"),
                    _field(_name, "Product Name"),
                    _field(_price, "Price", isNumber: true),

                    const SizedBox(height: 10),

                    _sectionTitle("Category & Stock"),
                    _field(_category, "Category"),
                    _field(_stock, "Stock", isNumber: true),

                    const SizedBox(height: 10),

                    _sectionTitle("Description"),
                    _field(_description, "Description", maxLines: 3),

                    const SizedBox(height: 10),

                    _sectionTitle("Image"),

                    // ❌ IMAGE UI STILL SHOWN BUT DISABLED IN TEST MODE
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isImageLoading ? null : _pickImage,
                          icon: _isImageLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.image),
                          label: Text(
                            isTestMode ? "Image Disabled" : "Select Image",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isTestMode
                                ? "Test Mode Active"
                                : (_imageName ?? "No image selected"),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SwitchListTile(
                      title: const Text("Featured"),
                      value: _isFeatured,
                      onChanged: _isLoading
                          ? null
                          : (v) => setState(() => _isFeatured = v),
                    ),

                    SwitchListTile(
                      title: const Text("Active"),
                      value: _isActive,
                      onChanged: _isLoading
                          ? null
                          : (v) => setState(() => _isActive = v),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addProduct,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Add Product"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================================================
  // 🧩 FIELD
  // ==================================================
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return "Enter $label";
          }

          if (isNumber) {
            final n = num.tryParse(v.trim());
            if (n == null || n < 0) {
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