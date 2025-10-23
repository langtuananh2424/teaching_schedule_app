import 'package:flutter/material.dart';

class RequestAbsenceScreen extends StatelessWidget {
  const RequestAbsenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Thông tin buổi học sẽ được truyền vào
    const sessionInfo = 'Mạng máy tính, 64KTPM5\n327-A2\nTrạng thái: Sắp diễn ra';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký nghỉ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sessionInfo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Lý do nghỉ',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            const Text('Minh chứng (Tùy chọn):'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Chọn tệp...'),
              onPressed: () {
                // Logic chọn file
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logic gửi yêu cầu
                },
                child: const Text('Gửi yêu cầu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}