import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // =========================
  // ⚙️ CONFIG
  // =========================
  static const int maxFileSize = 2 * 1024 * 1024; // 2MB
  static const int maxRetries = 2;

  // =========================
  // 🖼 SINGLE IMAGE UPLOAD (SAFE + RETRY)
  // =========================
  Future<String> uploadProductImage(
    Uint8List fileBytes,
    String folderName,
  ) async {
    if (fileBytes.isEmpty) {
      throw Exception("Image file is empty");
    }

    if (fileBytes.length > maxFileSize) {
      throw Exception("Image size should be less than 2MB");
    }

    int attempt = 0;

    while (attempt <= maxRetries) {
      try {
        final fileName = _uuid.v4();

        final ref = _storage
            .ref()
            .child(folderName)
            .child('$fileName.jpg');

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=31536000',
        );

        final uploadTask = ref.putData(fileBytes, metadata);

        final snapshot = await uploadTask;

        final url = await snapshot.ref.getDownloadURL();

        return url;
      } on FirebaseException catch (e) {
        attempt++;

        if (attempt > maxRetries) {
          throw Exception(
              "Upload failed after retries: ${e.message ?? e.code}");
        }

        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        throw Exception("Image upload failed: ${e.toString()}");
      }
    }

    throw Exception("Unexpected upload error");
  }

  // =========================
  // 🖼 MULTIPLE IMAGE UPLOAD (PARALLEL 🚀)
  // =========================
  Future<List<String>> uploadMultipleImages(
    List<Uint8List> files,
    String folderName,
  ) async {
    if (files.isEmpty) return [];

    try {
      final futures = files.map(
        (file) => uploadProductImage(file, folderName),
      );

      return await Future.wait(futures);
    } catch (e) {
      throw Exception("Multiple image upload failed: ${e.toString()}");
    }
  }

  // =========================
  // ❌ DELETE IMAGE (SAFE)
  // =========================
  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception("Delete failed: ${e.message ?? e.code}");
    } catch (e) {
      throw Exception("Image delete failed: ${e.toString()}");
    }
  }
}