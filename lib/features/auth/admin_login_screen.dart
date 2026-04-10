import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:admin_control/admin/admin_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;

  // =========================
  // 🔥 DUMMY LOGIN (TEMP)
  // =========================
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1)); // fake loading

    final email = emailController.text.trim();
    final password = passController.text.trim();

    // =========================
    // 🔐 DUMMY CREDENTIALS
    // =========================
    const dummyAdminEmail = "admin@demo.com";
    const dummyAdminPassword = "123456";

    const dummyStaffEmail = "staff@demo.com";
    const dummyStaffPassword = "123456";

    String role;

    if (email == dummyAdminEmail && password == dummyAdminPassword) {
      role = "admin";
    } else if (email == dummyStaffEmail && password == dummyStaffPassword) {
      role = "staff";
    } else {
      _showSnack("Invalid credentials");
      setState(() => isLoading = false);
      return;
    }

    // =========================
    // 🔥 SET ROLE
    // =========================
    final adminProvider =
        Provider.of<AdminProvider>(context, listen: false);

    adminProvider.setRole(UserRole.admin);

    // =========================
    // 🚀 NAVIGATION
    // =========================
    if (!mounted) return;

    if (role == "admin") {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/staffDashboard');
    }

    setState(() => isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 340,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Admin Login (Demo)",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 📧 Email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter email" : null,
                    ),

                    const SizedBox(height: 12),

                    // 🔑 Password
                    TextFormField(
                      controller: passController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter password" : null,
                    ),

                    const SizedBox(height: 20),

                    // 🔘 LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🔥 HINT TEXT
                    const Text(
                      "Demo Logins:\n"
                      "Admin → admin@demo.com / 123456\n"
                      "Staff → staff@demo.com / 123456",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}