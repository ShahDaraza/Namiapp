import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload user profile image
  Future<String> uploadUserProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload user image error: $e');
      rethrow;
    }
  }

  // Upload provider profile image
  Future<String> uploadProviderProfileImage(String providerId, File imageFile) async {
    try {
      final ref = _storage.ref().child('providers/$providerId/profile.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload provider image error: $e');
      rethrow;
    }
  }

  // Upload review images
  Future<List<String>> uploadReviewImages(String bookingId, List<File> imageFiles) async {
    try {
      List<String> urls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        final ref = _storage.ref().child('reviews/$bookingId/image_$i.jpg');
        await ref.putFile(imageFiles[i]);
        final url = await ref.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      print('Upload review images error: $e');
      rethrow;
    }
  }

  // Delete file
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      print('Delete file error: $e');
      rethrow;
    }
  }
}
