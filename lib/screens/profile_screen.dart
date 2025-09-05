// lib/screens/profile_screen.dart - Alternative fix
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header với avatar có thể nhấn vào
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/user-detail');
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).primaryColor,
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
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.user?.fullName ?? 'Người dùng',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            authProvider.user?.email ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Nhấn để xem chi tiết',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Menu items
            _buildMenuItem(
              icon: Icons.history,
              title: 'Lịch sử đặt vé',
              onTap: () {
                Navigator.pushNamed(context, '/tickets');
              },
            ),

            _buildMenuItem(
              icon: Icons.star,
              title: 'Đánh giá của tôi',
              onTap: () {
                Navigator.pushNamed(context, '/my-reviews');
              },
            ),

            _buildMenuItem(
              icon: Icons.settings,
              title: 'Cài đặt',
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),

            _buildMenuItem(
              icon: Icons.help,
              title: 'Trợ giúp',
              onTap: () {
                Navigator.pushNamed(context, '/help');
              },
            ),

            if (authProvider.user?.role == 'admin')
              _buildMenuItem(
                icon: Icons.admin_panel_settings,
                title: 'Quản trị',
                onTap: () {
                  Navigator.pushNamed(context, '/admin_dashboard'); // ✅ SỬA: Đổi từ '/admin' thành '/admin_dashboard'
                },
              ),

            SizedBox(height: 30),

            // Logout button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context, authProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đăng xuất'),
        content: Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}