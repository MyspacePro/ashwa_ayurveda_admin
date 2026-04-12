import 'package:admin_control/core/routes/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final CategoryModel? category;
  final String? parentId;

  const CategoryFormScreen({
    super.key,
    this.category,
    this.parentId,
  });

  @override
  State<CategoryFormScreen> createState() =>
      _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  bool _isLoading = false;

  bool get isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.category?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // =========================
  // 💾 SAVE CATEGORY
  // =========================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<CategoryProvider>();

      if (isEdit) {
        await provider.updateCategory(
          CategoryModel(
            id: widget.category!.id,
            name: _nameController.text.trim(),
            icon: widget.category!.icon,
          ),
        );
      } else {
        await provider.addCategory(
          CategoryModel(
            id: '',
            name: _nameController.text.trim(),
            icon: '',
          ),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Category updated successfully"
                : "Category added successfully",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Category' : 'Add Category',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // 🏷 NAME FIELD
              // =========================
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Required'
                        : null,
              ),

              const SizedBox(height: 12),

              // =========================
              // 📁 PARENT INFO
              // =========================
              if (widget.parentId != null)
                Text(
                  'Parent Category ID: ${widget.parentId}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

              const SizedBox(height: 24),

              // =========================
              // 💾 SUBMIT BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEdit
                              ? 'Update Category'
                              : 'Add Category',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}