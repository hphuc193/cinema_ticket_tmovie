import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Giao diện tối'),
            subtitle: Text('Chuyển đổi giữa sáng và tối'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                // Gợi ý: nếu app có provider themeMode, hãy switch ở đây
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chưa hỗ trợ đổi giao diện trực tiếp')),
                );
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Thông báo'),
            subtitle: Text('Quản lý cài đặt thông báo'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đang phát triển...')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Ngôn ngữ'),
            subtitle: Text('Tiếng Việt'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tính năng thay đổi ngôn ngữ sẽ sớm có mặt')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Thông tin ứng dụng'),
            subtitle: Text('Phiên bản 1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
