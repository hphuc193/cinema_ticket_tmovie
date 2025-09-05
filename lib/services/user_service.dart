// lib/services/user_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Lấy thông tin user
  Future<User?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Cập nhật thông tin user
  Future<bool> updateUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toJson());
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Upload avatar
  Future<String?> uploadAvatar(String uid, File imageFile) async {
    try {
      // Tạo reference cho file trong storage
      Reference ref = _storage
          .ref()
          .child('avatars')
          .child('$uid.jpg');

      // Upload file
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Lấy URL download
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  // Xóa avatar cũ
  Future<void> deleteAvatar(String uid) async {
    try {
      Reference ref = _storage
          .ref()
          .child('avatars')
          .child('$uid.jpg');
      await ref.delete();
    } catch (e) {
      print('Error deleting avatar: $e');
    }
  }

  // Cập nhật avatar
  Future<bool> updateAvatar(String uid, File imageFile) async {
    try {
      // Upload avatar mới
      String? avatarUrl = await uploadAvatar(uid, imageFile);
      if (avatarUrl != null) {
        // Cập nhật URL trong Firestore
        await _firestore
            .collection('users')
            .doc(uid)
            .update({'avatarUrl': avatarUrl});
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating avatar: $e');
      return false;
    }
  }
}