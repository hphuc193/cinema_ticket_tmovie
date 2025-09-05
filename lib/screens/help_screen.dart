import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trợ giúp'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text('Câu hỏi thường gặp'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Câu hỏi thường gặp'),
                  content: Text('Q: Làm sao để đặt vé?\nA: Chọn phim, suất chiếu và làm theo hướng dẫn trên màn hình.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Đóng'))],
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Liên hệ hỗ trợ'),
            subtitle: Text('cinema.support@email.com'),
            onTap: () {
              // Chỗ này bạn có thể tích hợp gửi email nếu cần
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gửi email: cinema.support@email.com')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.facebook),
            title: Text('Trang Facebook'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mở Fanpage Facebook...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
