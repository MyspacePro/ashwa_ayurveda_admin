import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseConfig {
  static Future<void> init() async {
    try {
      /// 🔥 Already initialized check (important for web hot reload)
      if (Firebase.apps.isNotEmpty) {
        print("⚡ Firebase already initialized");
        return;
      }

      /// 🔥 Initialize Firebase (auto platform detection)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      print("🔥 Firebase Initialized Successfully");
    } catch (e) {
      print("❌ Firebase Init Error: $e");
    }
  }
}