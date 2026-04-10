import 'package:admin_control/models/category_model.dart';
import 'package:admin_control/services/firebase/firebase_service.dart';
import 'package:flutter/material.dart';

class CategoryListScreen extends StatefulWidget {
  final FirestoreService firestoreService;

  const CategoryListScreen({
    super.key,
    required this.firestoreService,
  });

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  bool _isDeleting = false;

  // =========================
  // ❌ DELETE CATEGORY
  // =========================
  Future<void> _deleteCategory(String id) async {
    try {
      setState(() => _isDeleting = true);

      await widget.firestoreService.deleteCategory(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category deleted successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // =========================
  // ⚠️ CONFIRM DELETE
  // =========================
  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Category"),
        content: const Text("Are you sure you want to delete this category?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        centerTitle: true,
      ),

      // =========================
      // 📡 REALTIME STREAM
      // =========================
      body: StreamBuilder<List<Category>>(
        stream: widget.firestoreService.streamCategories(),
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final categories = snapshot.data ?? [];

          // 📭 Empty State
          if (categories.isEmpty) {
            return const Center(
              child: Text(
                "No categories found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // 📋 LIST
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      category.name.isNotEmpty
                          ? category.name[0].toUpperCase()
                          : '?',
                    ),
                  ),

                  title: Text(
                    category.name.isEmpty ? 'No Name' : category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    category.icon.isEmpty ? 'No icon' : category.icon,
                  ),

                  trailing: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(category.id),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}