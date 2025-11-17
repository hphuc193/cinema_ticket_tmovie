// lib/screens/user_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
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
      builder: (BuildContext context, Widget? child) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        final isDarkMode = themeProvider.isDarkMode;
        return Theme(
          data: isDarkMode
              ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Color(0xFF1A1A1A),
          )
              : ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey[900]!,
            ),
          ),
          child: child!,
        );
      },
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) {
          return Scaffold(
            backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Color(0xFFF5F5F5),
            appBar: AppBar(
              title: const Text('Thông tin cá nhân'),
              backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Colors.white,
            ),
            body: const Center(child: Text('Không tìm thấy thông tin người dùng')),
          );
        }

        return Scaffold(
          backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text(
              'Thông tin cá nhân',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
            backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  onPressed: () => setState(() => _isEditing = true),
                ),
              if (_isEditing) ...[
                IconButton(
                  icon: Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _selectedImage = null;
                    });
                    _loadUserData();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.check_rounded),
                  onPressed: _isLoading ? null : _saveChanges,
                ),
              ],
              SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Section
                  _buildAvatarSection(user, isDarkMode),

                  SizedBox(height: 32),

                  // Info Cards
                  _buildInfoCard(
                    isDarkMode: isDarkMode,
                    children: [
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Họ và tên',
                        icon: Icons.person_rounded,
                        enabled: _isEditing,
                        isDarkMode: isDarkMode,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: TextEditingController(text: user.email),
                        label: 'Email',
                        icon: Icons.email_rounded,
                        enabled: false,
                        isDarkMode: isDarkMode,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Số điện thoại',
                        icon: Icons.phone_rounded,
                        enabled: _isEditing,
                        isDarkMode: isDarkMode,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  _buildInfoCard(
                    isDarkMode: isDarkMode,
                    children: [
                      _buildTextField(
                        controller: _addressController,
                        label: 'Địa chỉ',
                        icon: Icons.location_on_rounded,
                        enabled: _isEditing,
                        isDarkMode: isDarkMode,
                        maxLines: 2,
                      ),
                      SizedBox(height: 16),
                      _buildDateField(isDarkMode),
                    ],
                  ),

                  SizedBox(height: 16),

                  _buildInfoCard(
                    isDarkMode: isDarkMode,
                    children: [
                      _buildTextField(
                        controller: TextEditingController(
                            text: user.role == 'admin' ? 'Quản trị viên' : 'Người dùng'
                        ),
                        label: 'Vai trò',
                        icon: Icons.verified_user_rounded,
                        enabled: false,
                        isDarkMode: isDarkMode,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: TextEditingController(
                            text: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                        ),
                        label: 'Ngày tham gia',
                        icon: Icons.calendar_today_rounded,
                        enabled: false,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),

                  if (_isLoading) ...[
                    SizedBox(height: 32),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(user, bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Decorative circle
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.3),
                Theme.of(context).primaryColor.withOpacity(0.1),
              ],
            ),
          ),
        ),
        // Avatar
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Colors.grey[100],
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (user.avatarUrl != null
                    ? CachedNetworkImageProvider(user.avatarUrl!) as ImageProvider
                    : null),
                child: (user.avatarUrl == null && _selectedImage == null)
                    ? Icon(
                  Icons.person_rounded,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required bool isDarkMode, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required bool isDarkMode,
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
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: isDarkMode ? Colors.white : Colors.grey[900],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: enabled
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: enabled
                ? Theme.of(context).primaryColor
                : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
            size: 20,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: enabled
            ? (isDarkMode ? Color(0xFF0A0A0A) : Colors.grey[50])
            : (isDarkMode ? Colors.grey[900] : Colors.grey[100]),
      ),
    );
  }

  Widget _buildDateField(bool isDarkMode) {
    return InkWell(
      onTap: _isEditing ? _selectDate : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: _isEditing
              ? (isDarkMode ? Color(0xFF0A0A0A) : Colors.grey[50])
              : (isDarkMode ? Colors.grey[900] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(14),
          border: _isEditing
              ? Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isEditing
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.cake_rounded,
                color: _isEditing
                    ? Theme.of(context).primaryColor
                    : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngày sinh',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Chưa cập nhật',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _selectedDate != null
                          ? (isDarkMode ? Colors.white : Colors.grey[900])
                          : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
            if (_isEditing)
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
          ],
        ),
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