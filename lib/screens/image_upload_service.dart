import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // =========================
  // 🖼 SINGLE IMAGE UPLOAD (CROSS PLATFORM)
  // =========================

  Future<String> uploadProductImage(
    Uint8List fileBytes,
    String folderName,
  ) async {
    try {
      final fileName = _uuid.v4();

      final ref = _storage
          .ref()
          .child(folderName)
          .child('$fileName.jpg');

      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  // =========================
  // 🖼 MULTIPLE IMAGE UPLOAD
  // =========================

  Future<List<String>> uploadMultipleImages(
    List<Uint8List> files,
    String folderName,
  ) async {
    List<String> urls = [];

    for (final file in files) {
      final url = await uploadProductImage(file, folderName);
      urls.add(url);
    }

    return urls;
  }

  // =========================
  // ❌ DELETE IMAGE
  // =========================

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception("Image delete failed: $e");
    }
  }
}