import 'dart:io';
import 'package:admin_control/services/firebase/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:admin_control/core/routes/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';


class CategoryAddEditScreen extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryAddEditScreen({
    super.key,
    this.category,
  });

  @override
  State<CategoryAddEditScreen> createState() =>
      _CategoryAddEditScreenState();
}

class _CategoryAddEditScreenState extends State<CategoryAddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _imageFile;
  String? _existingImageUrl;

  bool _isLoading = false;

  bool get isEdit => widget.category != null;

  // =========================
  // 🔥 FIRESTORE SERVICE (PROVIDER)
  // =========================
  FirestoreService get firestore =>
      context.read<FirestoreService>();

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _nameController.text = widget.category!['name'] ?? '';
      _descController.text = widget.category!['description'] ?? '';
      _existingImageUrl = widget.category!['imageUrl'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // =========================
  // 🖼 PICK IMAGE
  // =========================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  // =========================
  // ☁️ UPLOAD IMAGE (MOVE TO SERVICE LATER RECOMMENDED)
  // =========================
  Future<String?> _uploadImage(File file) async {
    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance
    .ref()
    .child('category_images/$fileName.jpg');

      final uploadTask = await ref.putFile(file);

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  // =========================
  // 💾 SAVE CATEGORY
  // =========================
  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;

      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      final data = {
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "imageUrl": imageUrl ?? "",
      };

      if (isEdit) {
        await firestore.updateCategory(
          widget.category!['id'],
          data,
        );
      } else {
        await firestore.addCategory(data);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? "Category updated" : "Category added",
          ),
        ),
      );

      NavigationService.goBack();
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
  // 🖼 IMAGE PREVIEW
  // =========================
  Widget _imagePreview() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    if (_existingImageUrl != null &&
        _existingImageUrl!.isNotEmpty) {
      return Image.network(
        _existingImageUrl!,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    return Container(
      height: 120,
      color: Colors.grey.shade200,
      child: const Center(child: Text("No Image Selected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title:
            Text(isEdit ? "Edit Category" : "Add Category"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _imagePreview(),
                ),
              ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pick Category Image"),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Category Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? "Enter category name"
                    : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _saveCategory,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(isEdit
                          ? "Update Category"
                          : "Add Category"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}