import 'package:flutter/material.dart';

class SessionDetailsScreen extends StatelessWidget {
  const SessionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Thông tin chi tiết buổi học sẽ được truyền vào
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết buổi học'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nội dung buổi học',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Lưu nội dung'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Điểm danh sinh viên'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Đăng ký nghỉ'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: null, // Vô hiệu hóa nếu chưa nghỉ
                    child: const Text('Đăng ký dạy bù'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Môn học: Mạng máy tính', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Lớp: 64KTPM5', style: Theme.of(context).textTheme.bodyLarge),
            Text('Phòng: 327-A2', style: Theme.of(context).textTheme.bodyLarge),
            Text('Thời gian: 9:45 - 12:20, 19/09/2025', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}