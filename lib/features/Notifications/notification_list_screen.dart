import 'package:flutter/material.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.notifications_active_outlined),
            title: Text('Send notification'),
            subtitle: Text('Push an announcement to app users'),
          ),
        ),
      ],
    );
  }
}
