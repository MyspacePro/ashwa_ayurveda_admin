import 'package:flutter/material.dart';

class BannerListScreen extends StatelessWidget {
  const BannerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.image_outlined),
            title: Text('Homepage Hero Banner'),
            subtitle: Text('Manage banner image and CTA'),
          ),
        ),
      ],
    );
  }
}
