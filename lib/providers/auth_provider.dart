// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  final AuthService _authService = AuthService();

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  // Sửa lại method register để truyền selectedRole vào AuthService
  Future<bool> register(String email, String password, String fullName, String selectedRole) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Truyền selectedRole vào signUp
      final user = await _authService.signUp(email, password, fullName, selectedRole);
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      _user = user;
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
    }
  }

  // Thêm method để cập nhật user sau khi chỉnh sửa profile
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}