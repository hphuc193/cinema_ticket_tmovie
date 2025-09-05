// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email', // Cần thiết để lấy email
      'https://www.googleapis.com/auth/userinfo.profile', // Cần thiết để lấy thông tin hồ sơ
    ],
  );

  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return User.fromJson(userDoc.data()!);
      }
    }
    return null;
  }

  Future<User> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      return User.fromJson(userDoc.data()!);
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  // Sửa lại method signUp để nhận thêm tham số role
  Future<User> signUp(String email, String password, String fullName, String role) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = User(
        uid: credential.user!.uid,
        email: email,
        fullName: fullName,
        role: role, // Sử dụng role được truyền vào thay vì hardcode 'user'
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(user.toJson());
      return user;
    } catch (e) {
      throw Exception('Đăng ký thất bại: ${e.toString()}');
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      // Bắt đầu quá trình đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Đăng nhập Google bị hủy');
      }

      // Lấy thông tin xác thực từ Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Tạo credential cho Firebase
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // Đúng cú pháp
        idToken: googleAuth.idToken, // Đúng cú pháp
      );

      // Đăng nhập vào Firebase với credential
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      // Kiểm tra xem người dùng đã tồn tại trong Firestore chưa
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // Tạo tài liệu người dùng mới với role mặc định là 'user' cho Google Sign In
        final user = User(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          fullName: firebaseUser.displayName ?? '',
          role: 'user', // Google Sign In luôn tạo user với role 'user'
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson());
        return user;
      } else {
        return User.fromJson(userDoc.data()!);
      }
    } catch (e) {
      throw Exception('Đăng nhập Google thất bại: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}