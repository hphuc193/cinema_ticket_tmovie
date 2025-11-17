// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Hồ Sơ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeader(context, authProvider, isDarkMode),

                  SizedBox(height: 24),

                  // Menu Items
                  _buildMenuSection(context, authProvider, isDarkMode),

                  SizedBox(height: 24),

                  // Logout Button
                  _buildLogoutButton(context, authProvider, isDarkMode),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleNavigation(index);
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/user-detail');
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: authProvider.user?.avatarUrl != null
                        ? CachedNetworkImageProvider(authProvider.user!.avatarUrl!)
                        : null,
                    child: authProvider.user?.avatarUrl == null
                        ? Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.user?.fullName ?? 'Người dùng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    authProvider.user?.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Nhấn để chỉnh sửa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    return Container(
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
        children: [
          _buildMenuItem(
            context: context,
            icon: Icons.confirmation_number_rounded,
            title: 'Lịch sử đặt vé',
            subtitle: 'Xem vé đã đặt',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.pushNamed(context, '/tickets');
            },
          ),
          _buildDivider(isDarkMode),
          _buildMenuItem(
            context: context,
            icon: Icons.star_rounded,
            title: 'Đánh giá của tôi',
            subtitle: 'Quản lý đánh giá',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.pushNamed(context, '/my-reviews');
            },
          ),
          _buildDivider(isDarkMode),
          _buildMenuItem(
            context: context,
            icon: Icons.settings_rounded,
            title: 'Cài đặt',
            subtitle: 'Tùy chỉnh ứng dụng',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          _buildDivider(isDarkMode),
          _buildMenuItem(
            context: context,
            icon: Icons.help_rounded,
            title: 'Trợ giúp',
            subtitle: 'Hỗ trợ & FAQ',
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
          if (authProvider.user?.role == 'admin') ...[
            _buildDivider(isDarkMode),
            _buildMenuItem(
              context: context,
              icon: Icons.admin_panel_settings_rounded,
              title: 'Quản trị',
              subtitle: 'Bảng điều khiển',
              isDarkMode: isDarkMode,
              isAdmin: true,
              onTap: () {
                Navigator.pushNamed(context, '/admin_dashboard');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool isAdmin = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isAdmin
                      ? LinearGradient(
                    colors: [Colors.purple, Colors.purple.withOpacity(0.7)],
                  )
                      : LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isAdmin ? Colors.white : Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog(context, authProvider, isDarkMode);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Đăng xuất',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        content: Text(
          'Bạn có chắc muốn đăng xuất?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/tickets');
        break;
      case 2:
      // Đã ở trang profile
        break;
    }
  }
}