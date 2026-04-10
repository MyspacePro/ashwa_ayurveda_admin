import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _wallet;
  late String _kyc;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user?.name ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
    _phone = TextEditingController(text: widget.user?.phone ?? '');
    _wallet = TextEditingController(text: (widget.user?.walletBalance ?? 0).toString());
    _kyc = widget.user?.kycStatus ?? 'PENDING';
  }

  @override
  void dispose() {
    _name.dispose();_email.dispose();_phone.dispose();_wallet.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<UserProvider>();
    if (isEdit) {
      await provider.updateUser(userId: widget.user!.id, data: {
        'name': _name.text.trim(), 'email': _email.text.trim(), 'phone': _phone.text.trim(),
        'walletBalance': double.tryParse(_wallet.text.trim()) ?? 0, 'kycStatus': _kyc,
      });
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await provider.createUser(UserModel(
        id: id,name: _name.text.trim(),email: _email.text.trim(),phone: _phone.text.trim(),
        walletBalance: double.tryParse(_wallet.text.trim()) ?? 0,kycStatus: _kyc,
      ));
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit User' : 'Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v)=>v==null||v.isEmpty?'Required':null),
            TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v)=>v!=null&&v.contains('@')?null:'Valid email required'),
            TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'), validator: (v)=>v==null||v.length<8?'Valid phone required':null),
            TextFormField(controller: _wallet, decoration: const InputDecoration(labelText: 'Wallet Balance'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(value: _kyc, items: const ['PENDING','VERIFIED','REJECTED'].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_kyc=v ?? 'PENDING'), decoration: const InputDecoration(labelText: 'KYC Status')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Update User' : 'Create User')),
          ]),
        ),
      ),
    );
  }
}
