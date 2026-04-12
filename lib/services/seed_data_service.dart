import 'package:cloud_firestore/cloud_firestore.dart';

class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // 📂 CATEGORIES
  // =========================
  Future<void> seedCategories() async {
    final categories = [
      {"id": "hair_care", "name": "Hair Care"},
      {"id": "skin_care", "name": "Skin Care"},
      {"id": "body_care", "name": "Body Care"},
      {"id": "immunity", "name": "Immunity Booster"},
      {"id": "digestive", "name": "Digestive Health"},
      {"id": "weight_loss", "name": "Weight Loss"},
      {"id": "stress_relief", "name": "Stress Relief"},
      {"id": "baby_care", "name": "Baby Care"},
      {"id": "joint_care", "name": "Joint & Bone Care"},
      {"id": "respiratory", "name": "Respiratory Care"},
      {"id": "men_women", "name": "Men & Women Wellness"},
    ];

    for (var cat in categories) {
      final doc = _firestore.collection('categories').doc(cat['id']);

      final exists = await doc.get();

      if (!exists.exists) {
        await doc.set({
          'name': cat['name'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // =========================
  // 📂 SUBCATEGORIES
  // =========================
  Future<void> seedSubCategories() async {
    final subcategories = [
      {"name": "Hair Oil", "categoryId": "hair_care"},
      {"name": "Shampoo", "categoryId": "hair_care"},
      {"name": "Hair Serum", "categoryId": "hair_care"},
      {"name": "Face Wash", "categoryId": "skin_care"},
      {"name": "Acne Care", "categoryId": "skin_care"},
      {"name": "Moisturizer", "categoryId": "skin_care"},
      {"name": "Body Lotion", "categoryId": "body_care"},
      {"name": "Soap", "categoryId": "body_care"},
      {"name": "Immunity Syrup", "categoryId": "immunity"},
      {"name": "Chyawanprash", "categoryId": "immunity"},
      {"name": "Digestive Powder", "categoryId": "digestive"},
      {"name": "Gas Relief", "categoryId": "digestive"},
      {"name": "Fat Burner", "categoryId": "weight_loss"},
      {"name": "Detox Tea", "categoryId": "weight_loss"},
      {"name": "Ashwagandha", "categoryId": "stress_relief"},
      {"name": "Baby Oil", "categoryId": "baby_care"},
      {"name": "Joint Pain Oil", "categoryId": "joint_care"},
      {"name": "Calcium", "categoryId": "joint_care"},
      {"name": "Cough Syrup", "categoryId": "respiratory"},
      {"name": "Multivitamins", "categoryId": "men_women"},
    ];

    for (var sub in subcategories) {
      await _firestore.collection('subcategories').add({
        'name': sub['name'],
        'categoryId': sub['categoryId'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // =========================
  // 🚀 ALL DATA
  // =========================
  Future<void> seedAll() async {
    await seedCategories();
    await seedSubCategories();
  }
}