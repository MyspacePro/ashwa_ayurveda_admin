import 'package:flutter/material.dart';
import 'package:admin_control/models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleBlock;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleBlock,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = user.isBlocked;
    final isAdmin = user.isAdmin;
    final isActive = (user.isActive) && !isBlocked;

    final contact = (user.email?.isNotEmpty == true)
        ? user.email
        : (user.phone?.isNotEmpty == true)
            ? user.phone
            : "No contact info";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // =========================
              // 👤 AVATAR
              // =========================
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blue.shade50,
                backgroundImage: (user.profileImage != null &&
                        user.profileImage!.isNotEmpty)
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: (user.profileImage == null ||
                        user.profileImage!.isEmpty)
                    ? Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // =========================
              // 📄 USER INFO
              // =========================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + badges
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        if (isAdmin)
                          _badge("Admin", Colors.purple),

                        if (isBlocked)
                          _badge("Blocked", Colors.red)
                        else if (isActive)
                          _badge("Active", Colors.green),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Contact info
                    Text(
                      contact,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Role chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // =========================
              // ⚙️ ACTIONS
              // =========================
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'block':
                      onToggleBlock();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text("Edit User"),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Text(isBlocked ? "Unblock User" : "Block User"),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      "Delete User",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // 🏷 BADGE WIDGET
  // =========================
  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}