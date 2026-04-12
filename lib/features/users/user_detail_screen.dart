import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_control/core/routes/app_routes.dart';
import 'package:admin_control/core/routes/navigation_service.dart';
import 'package:admin_control/models/user_model.dart';
import 'package:admin_control/providers/user_provider.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final UserModel? user = provider.getUserById(userId);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not found")),
      );
    }

    final isBlocked = user.isBlocked;
    final isAdmin = user.isAdmin;
    final isActive = user.isActive && !isBlocked;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              NavigationService.navigateTo(
                AppRoutes.editUser,
                arguments: user,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // 👤 PROFILE CARD
            // =========================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: user.profileImage != null &&
                            user.profileImage!.isNotEmpty
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null ||
                            user.profileImage!.isEmpty
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    user.email ?? user.phone ?? "No contact info",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _badge("Role: ${user.role}", Colors.blue),
                      if (isAdmin) _badge("Admin", Colors.purple),
                      if (isBlocked)
                        _badge("Blocked", Colors.red)
                      else if (isActive)
                        _badge("Active", Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // 📊 INFO SECTION
            // =========================
            _infoTile(Icons.person, "User ID", user.id),
            _infoTile(Icons.email, "Email", user.email ?? "-"),
            _infoTile(Icons.phone, "Phone", user.phone ?? "-"),
            _infoTile(Icons.security, "Role", user.role),
            _infoTile(
              Icons.verified,
              "Status",
              isBlocked ? "Blocked" : "Active",
            ),

            const SizedBox(height: 20),

            // =========================
            // ⚙️ ACTION BUTTONS
            // =========================
            _actionButtons(context, provider, user),
          ],
        ),
      ),
    );
  }

  // =========================
  // 🧾 INFO TILE
  // =========================
  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🎯 ACTION BUTTONS
  // =========================
  Widget _actionButtons(
    BuildContext context,
    UserProvider provider,
    UserModel user,
  ) {
    final isBlocked = user.isBlocked;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(isBlocked ? Icons.lock_open : Icons.block),
            label: Text(isBlocked ? "Unblock User" : "Block User"),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isBlocked ? Colors.green : Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              provider.toggleBlockUser(user);
            },
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text("Delete User"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              _confirmDelete(context, provider, user);
            },
          ),
        ),
      ],
    );
  }

  // =========================
  // 🏷 BADGE
  // =========================
  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // =========================
  // 🗑 DELETE CONFIRMATION
  // =========================
  void _confirmDelete(
    BuildContext context,
    UserProvider provider,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              Navigator.pop(context); // back to list
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}