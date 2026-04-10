import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/staff_model.dart';
import '../../providers/staff_provider.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StaffProvider>().listenToStaff());
  }

  Future<void> _openAddDialog() async {
    final name = TextEditingController();
    final email = TextEditingController();
    StaffRole role = StaffRole.manager;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Staff'),
        content: StatefulBuilder(builder: (_, setLocal) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            DropdownButton<StaffRole>(value: role, onChanged: (v)=>setLocal(()=>role=v ?? StaffRole.manager), items: StaffRole.values.map((e)=>DropdownMenuItem(value:e, child: Text(e.name.toUpperCase()))).toList()),
          ],
        )),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            await context.read<StaffProvider>().upsertStaff(StaffModel(id: '', name: name.text.trim(), email: email.text.trim(), role: role, permissions: [role.name]));
            if (mounted) Navigator.pop(context);
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StaffProvider>(builder: (_, provider, __) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _openAddDialog, icon: const Icon(Icons.person_add_alt_1), label: const Text('Add Staff'))),
          const SizedBox(height: 12),
          ...provider.staff.map((s) => ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(s.name),
                subtitle: Text('${s.email} • ${s.role.name.toUpperCase()}'),
                trailing: Text(s.permissions.join(', ')),
              )),
        ],
      );
    });
  }
}
