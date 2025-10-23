import 'package:flutter/material.dart';

class RegisterMakeupScreen extends StatelessWidget {
  const RegisterMakeupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả sử thông tin buổi nghỉ được truyền vào màn hình này
    const absentInfo = 'Buổi đã nghỉ: QTM - 64HTTT3\nNgày nghỉ: 13:45, thứ 3, 20/09/2025';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký dạy bù'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              absentInfo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            const Text(
              'Chọn lịch dạy bù:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Ngày',
                hintText: 'dd/mm/yyyy',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Ca',
                prefixIcon: Icon(Icons.access_time),
              ),
              items: const [
                DropdownMenuItem(value: '1-3', child: Text('Tiết 1-3 (7:00-9:40)')),
                DropdownMenuItem(value: '4-6', child: Text('Tiết 4-6 (9:45-12:20)')),
                DropdownMenuItem(value: '7-9', child: Text('Tiết 7-9 (12:55-15:35)')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Phòng',
                prefixIcon: Icon(Icons.room),
              ),
              items: const [
                DropdownMenuItem(value: 'A2-329', child: Text('A2-329')),
                DropdownMenuItem(value: 'C1-101', child: Text('C1-101')),
              ],
              onChanged: (value) {},
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