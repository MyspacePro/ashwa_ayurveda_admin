import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  @override
  void initState(){super.initState();_name=TextEditingController(text: widget.product?.name??'');_price=TextEditingController(text:(widget.product?.price??0).toString());}
  @override
  void dispose(){_name.dispose();_price.dispose();super.dispose();}
  @override
  Widget build(BuildContext context) {
    return Form(key: _key, child: Column(children: [
      TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Product Name'), validator: (v)=>v==null||v.isEmpty?'Required':null),
      TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      FilledButton(onPressed: () async {
        if(!_key.currentState!.validate()) return;
        final p = (widget.product ?? ProductModel(id: '', name: '', price: 0, description: '', images: const [], categoryId: '')).copyWith(name: _name.text.trim(), price: double.tryParse(_price.text) ?? 0);
        if (widget.product == null) {
          await context.read<ProductProvider>().addProduct(p);
        } else {
          await context.read<ProductProvider>().updateProduct(p);
        }
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product saved')));
      }, child: Text(widget.product == null ? 'Add Product' : 'Update Product'))
    ]));
  }
}
