import 'package:flutter/material.dart';

class AdminNavModel {
  final String title;
  final IconData icon;
  final String route;
  final List<AdminNavModel>? children;

  AdminNavModel({
    required this.title,
    required this.icon,
    required this.route,
    this.children,
  });
}