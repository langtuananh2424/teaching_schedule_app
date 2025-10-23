import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  // Nhận dữ liệu để tính toán thanh tiến trình
  final int completedHours;
  final int plannedHours;

  const ReportDetailScreen({
    super.key,
    required this.completedHours,
    required this.plannedHours
  });

  @override
  Widget build(BuildContext context) {
    // Tính toán phần trăm hoàn thành
    final double completionPercentage = (plannedHours > 0) ? (completedHours / plannedHours) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết báo cáo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTeacherInfo(),
            const SizedBox(height: 24),

            // THAY ĐỔI TẠI ĐÂY: Chỉ hiển thị nếu có dữ liệu
            if (plannedHours > 0)
              _buildCourseOverview(completionPercentage),

            const SizedBox(height: 24),
            _buildAttendanceDetails(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Logic xuất ra Excel
              },
              child: const Text('Xuất ra excel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nguyễn Văn A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Khoa: Công nghệ thông tin'),
        Text('Lớp: 64KTPM3 - Phát triển ứng dụng thiết bị di động'),
        Text('Học kỳ: HK_1 2025 - 2026'),
      ],
    );
  }

  Widget _buildCourseOverview(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TỔNG QUAN LỚP HỌC PHẦN', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hoàn thành: $completedHours/$plannedHours giờ'),
                  const SizedBox(height: 4),
                  // Thanh tiến trình màu vàng
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[300],
                      color: Colors.amber,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text('${(percentage * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Giờ nghỉ: 3 giờ'),
            Text('Giờ bù: 3 giờ'),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Chuyên cần trung bình: 95.8%'),
      ],
    );
  }

  Widget _buildAttendanceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CHI TIẾT CHUYÊN CẦN (60 Sinh viên)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Dùng ListView.builder để hiệu quả hơn khi danh sách dài
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 7, // Số lượng sinh viên mẫu
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildStudentAttendanceCard();
          },
        ),
      ],
    );
  }

  Widget _buildStudentAttendanceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hoàng Văn A - 2251172xxx'),
                Text('Có mặt: 26 | Vắng: 1 (1P, 0 KP)', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Text('96,1%', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
