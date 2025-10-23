import 'package:flutter/material.dart';

class MyRequestScreen extends StatelessWidget {
  const MyRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Yêu cầu'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Yêu cầu nghỉ'),
              Tab(text: 'Yêu cầu dạy bù'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsList(RequestType.absence),
            _buildRequestsList(RequestType.makeup),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(RequestType type) {
    // Dữ liệu mẫu - bạn sẽ thay thế bằng việc gọi API
    final items = type == RequestType.absence
        ? [
      {'title': 'Nghỉ dạy môn Mạng máy tính', 'date': '20/09/2025', 'status': 'Đã duyệt'},
      {'title': 'Nghỉ dạy môn Lập trình nâng cao', 'date': '15/10/2025', 'status': 'Chờ duyệt'},
      {'title': 'Nghỉ dạy môn CTDL&GT', 'date': '01/11/2025', 'status': 'Từ chối'},
    ]
        : [
      {'title': 'Bù môn Quản trị mạng', 'date': '25/09/2025', 'status': 'Đã duyệt'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            title: Text(item['title']!),
            subtitle: Text('Ngày: ${item['date']}'),
            trailing: Chip(
              label: Text(
                item['status']!,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: _getStatusColor(item['status']!),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
        return Colors.green;
      case 'Chờ duyệt':
        return Colors.orange;
      case 'Từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

enum RequestType { absence, makeup }