import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_control/providers/user_provider.dart';
import 'package:admin_control/widgets/user_card.dart';
import 'package:admin_control/models/user_model.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  void initState() {
    super.initState();

    // Start listening once screen loads
    Future.microtask(() {
      context.read<UserProvider>().listenToUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.users.isEmpty) {
          return Center(
            child: Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (provider.users.isEmpty) {
          return const Center(
            child: Text("No users found"),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            provider.listenToUsers();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: provider.users.length,
            itemBuilder: (context, index) {
              final UserModel user = provider.users[index];

              return UserCard(
                user: user,

                onTap: () {
                  // 👉 Open user detail page (future upgrade)
                },

                onEdit: () {
                  // 👉 Open edit bottom sheet / dialog
                },

                onToggleBlock: () {
                  provider.toggleBlockUser(user);
                },

                onDelete: () {
                  _confirmDelete(context, provider, user);
                },
              );
            },
          ),
        );
      },
    );
  }

  // =========================
  // 🗑 DELETE CONFIRM DIALOG
  // =========================
  void _confirmDelete(
    BuildContext context,
    UserProvider provider,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: Text(
            "Are you sure you want to delete ${user.name}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                provider.deleteUser(user.id);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}