import 'package:flutter/material.dart';
import '../services/seed_data_service.dart';

class SeedButton extends StatefulWidget {
  const SeedButton({super.key});

  @override
  State<SeedButton> createState() => _SeedButtonState();
}

class _SeedButtonState extends State<SeedButton> {
  bool _isLoading = false;

  Future<void> _seedData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await SeedDataService().seedAll();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Data Seeded Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.cloud_upload),
      label: Text(_isLoading ? "Seeding..." : "Seed Data"),
      onPressed: _isLoading ? null : _seedData,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}