import 'package:flutter/material.dart';

enum RequestType { absence, makeup }

class RequestApprovalScreen extends StatelessWidget {
  final RequestType initialTab;

  const RequestApprovalScreen({super.key, required this.initialTab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTab == RequestType.absence ? 0 : 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phê duyệt yêu cầu'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Yêu cầu nghỉ'),
              Tab(text: 'Yêu cầu dạy bù'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildApprovalList(context, isMakeup: false),
            _buildApprovalList(context, isMakeup: true),
          ],
        ),
        // Footer giống màn hình Dashboard
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Báo cáo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Tài khoản',
            ),
          ],
          onTap: (index) {
            // Logic điều hướng footer nếu cần
          },
        ),
      ),
    );
  }

  Widget _buildApprovalList(BuildContext context, {bool isMakeup = false}) {
    final requests = isMakeup
        ? [
      {'gv': 'Trần Văn An', 'mon': 'Mạng máy tính', 'ngay': '20/09/2025'},
      {'gv': 'Nguyễn Văn A', 'mon': 'Lập trình nâng cao', 'ngay': '21/09/2025'},
    ]
        : [
      {'gv': 'Trần Văn An', 'mon': 'Mạng máy tính', 'ngay': '20/09/2025'},
      {'gv': 'Trần Quang D', 'mon': 'CTDL&GT', 'ngay': '22/09/2025'},
    ];
    final type = isMakeup ? '[Dạy bù]' : '[Nghỉ dạy]';

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$type GV: ${req['gv']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Môn: ${req['mon']}'),
                Text('Ngày: ${req['ngay']}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Duyệt'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Từ chối'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}