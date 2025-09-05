import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class UserDetailScreen extends StatefulWidget {
  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
      _selectedDate = user.dateOfBirth;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user!;

      String? avatarUrl = currentUser.avatarUrl;

      if (_selectedImage != null) {
        avatarUrl = await _userService.uploadAvatar(currentUser.uid, _selectedImage!);
        if (avatarUrl == null) {
          throw Exception('Không thể tải lên avatar');
        }
      }

      final updatedUser = currentUser.copyWith(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        dateOfBirth: _selectedDate,
        avatarUrl: avatarUrl,
      );
      bool success = await _userService.updateUser(updatedUser);

      if (success) {
        authProvider.updateUser(updatedUser);
        setState(() {
          _isEditing = false;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Không thể cập nhật thông tin');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Thông tin cá nhân')),
            body: const Center(child: Text('Không tìm thấy thông tin người dùng')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Thông tin cá nhân'),
            backgroundColor: colorScheme.primary,
            elevation: 1,
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: Icon(Icons.edit, color: colorScheme.onPrimary),
                  onPressed: () => setState(() => _isEditing = true),
                ),
              if (_isEditing) ...[
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onPrimary),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _selectedImage = null;
                    });
                    _loadUserData();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.save, color: colorScheme.onPrimary),
                  onPressed: _isLoading ? null : _saveChanges,
                ),
              ]
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar section
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 16,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 62,
                            backgroundColor: colorScheme.secondary,
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: Colors.grey[100],
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (user.avatarUrl != null
                                  ? CachedNetworkImageProvider(user.avatarUrl!) as ImageProvider
                                  : null),
                              child: (user.avatarUrl == null && _selectedImage == null)
                                  ? Icon(Icons.person, size: 64, color: colorScheme.primary)
                                  : null,
                            ),
                          ),
                        ),
                        if (_isEditing) ...[
                          Positioned(
                            child: Material(
                              color: colorScheme.primary,
                              shape: const CircleBorder(),
                              elevation: 4,
                              child: InkWell(
                                onTap: _pickImage,
                                customBorder: const CircleBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    elevation: 3,
                    shadowColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _fullNameController,
                            label: 'Họ và tên',
                            icon: Icons.person,
                            enabled: _isEditing,
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) {
                                return 'Vui lòng nhập họ tên';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: TextEditingController(text: user.email),
                            label: 'Email',
                            icon: Icons.email,
                            enabled: false,
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Số điện thoại',
                            icon: Icons.phone_rounded,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: _addressController,
                            label: 'Địa chỉ',
                            icon: Icons.map,
                            enabled: _isEditing,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 18),
                          // Birthday field
                          InkWell(
                            onTap: _isEditing ? _selectDate : null,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Ngày sinh',
                                prefixIcon: const Icon(Icons.cake),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                                enabled: _isEditing,
                              ),
                              child: Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Chưa cập nhật',
                                style: TextStyle(
                                  color: _selectedDate != null ? Colors.black : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: TextEditingController(
                                text: user.role == 'admin' ? 'Quản trị viên' : 'Người dùng'
                            ),
                            label: 'Vai trò',
                            icon: Icons.verified_user_outlined,
                            enabled: false,
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: TextEditingController(
                                text: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                            ),
                            label: 'Ngày tham gia',
                            icon: Icons.calendar_today,
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
          fontWeight: enabled ? FontWeight.w500 : FontWeight.normal,
          color: enabled ? Colors.black : Colors.grey[800]
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
