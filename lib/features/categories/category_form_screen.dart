import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;
  final String? parentId;
  const CategoryFormScreen({super.key, this.category, this.parentId});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  @override
  void initState(){super.initState();_name=TextEditingController(text: widget.category?.name ?? '');}
  @override
  void dispose(){_name.dispose();super.dispose();}

  @override
  Widget build(BuildContext context) {
    return Form(key: _key, child: Column(children: [
      TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Category Name'), validator:(v)=>v==null||v.isEmpty?'Required':null),
      if (widget.parentId != null) Text('Parent Category ID: ${widget.parentId}'),
      const SizedBox(height: 12),
      FilledButton(onPressed: () async {
        if(!_key.currentState!.validate()) return;
        final provider = context.read<CategoryProvider>();
        if (widget.category == null) {
          await provider.addCategory(Category(id: '', name: _name.text.trim(), icon: ''));
        } else {
          await provider.updateCategory(Category(id: widget.category!.id, name: _name.text.trim(), icon: widget.category!.icon));
        }
      }, child: Text(widget.category == null ? 'Add Category' : 'Update Category')),
    ]));
  }
}
