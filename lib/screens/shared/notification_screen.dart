import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu
    final notifications = [
      {'title': 'Yêu cầu nghỉ được phê duyệt', 'body': 'Yêu cầu nghỉ môn Mạng máy tính ngày 20/09/2025 đã được duyệt.', 'read': false},
      {'title': 'Yêu cầu dạy bù bị từ chối', 'body': 'Yêu cầu dạy bù môn CTDL&GT đã bị từ chối.', 'read': false},
      {'title': 'Thông báo chung', 'body': 'Lịch nghỉ lễ 30/4 - 1/5.', 'read': true},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isUnread = !(notification['read'] as bool);
          return Container(
            color: isUnread ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
            child: ListTile(
              leading: Icon(
                isUnread ? Icons.mark_email_unread : Icons.drafts,
                color: isUnread ? Theme.of(context).primaryColor : Colors.grey,
              ),
              title: Text(
                notification['title'] as String,
                style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
              ),
              subtitle: Text(notification['body'] as String),
              onTap: () {
                // Logic đánh dấu đã đọc
              },
            ),
          );
        },
      ),
    );
  }
}