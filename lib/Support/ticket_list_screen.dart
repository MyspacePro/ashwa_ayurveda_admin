import 'package:flutter/material.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.support_agent_outlined),
            title: Text('No open tickets'),
            subtitle: Text('Customer support queue will appear here'),
          ),
        ),
      ],
    );
  }
}
