import 'package:flutter/material.dart';

class ReportDetailsScreen extends StatelessWidget {
  final String reportTitle;
  const ReportDetailsScreen({super.key, required this.reportTitle});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu - Thay thế bằng dữ liệu thật từ API
    final List<Map<String, String>> data = [
      {
        'MSSV': '2251172xxx',
        'Họ và tên': 'Hoàng Văn A',
        'Có mặt': '26',
        'Vắng': '1 (1P, 0 KP)',
        'Chuyên cần': '96.1%',
      },
      {
        'MSSV': '2251172yyy',
        'Họ và tên': 'Trần Thị B',
        'Có mặt': '27',
        'Vắng': '0',
        'Chuyên cần': '100%',
      },
      {
        'MSSV': '2251172zzz',
        'Họ và tên': 'Lê Thị C',
        'Có mặt': '25',
        'Vắng': '2 (0P, 2 KP)',
        'Chuyên cần': '92.6%',
      },
      // Thêm dữ liệu cho các sinh viên khác ở đây
    ];
    final columns = data.first.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text(reportTitle)),
      body: SingleChildScrollView(
        // Thêm padding dưới để nút nổi không che mất nội dung
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          children: [
            _buildLecturerInfoCard(),
            const SizedBox(height: 20),
            _buildOverallSummaryCard(),
            const SizedBox(height: 20),
            _buildAttendanceDetailsCard(columns, data),
          ],
        ),
      ),
      // Sử dụng FloatingActionButton.extended để có nút dài với icon và text
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width:
        MediaQuery.of(context).size.width *
            0.9, // Chiều rộng bằng 90% màn hình
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Triển khai logic xuất file Excel
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chức năng xuất Excel đang được phát triển.'),
              ),
            );
          },
          label: const Text('Xuất ra excel'),
          icon: const Icon(Icons.download_rounded),
        ),
      ),
    );
  }

  // Card thông tin giảng viên và lớp học phần
  Widget _buildLecturerInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, size: 48, color: Colors.blueAccent),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Khoa: Công nghệ thông tin',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Lớp: 64KTPM3 - Phát triển ứng dụng thiết bị di động'),
            const SizedBox(height: 8),
            const Text('Học kỳ: HK I, 2025 - 2026'),
          ],
        ),
      ),
    );
  }

  // Card tổng quan lớp học phần
  Widget _buildOverallSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TỔNG QUAN LỚP HỌC PHẦN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Text('Hoàn thành: 27/30 giờ'),
                Spacer(),
                Text('90%', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 0.9,
                minHeight: 12,
                backgroundColor: Colors.black12,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Giờ nghỉ: 3 giờ'), Text('Giờ bù: 3 giờ')],
            ),
            const Divider(height: 32),
            const Row(
              children: [
                Text('Chuyên cần trung bình:'),
                Spacer(),
                Text(
                  '95.8%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card chi tiết chuyên cần của sinh viên (dạng ExpansionTile)
  Widget _buildAttendanceDetailsCard(
      List<String> columns,
      List<Map<String, String>> data,
      ) {
    return Card(
      child: ExpansionTile(
        title: const Text(
          'CHI TIẾT CHUYÊN CẦN (60 Sinh viên)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // Mặc định mở sẵn danh sách
        initiallyExpanded: true,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        // Bảng dữ liệu chi tiết
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns
                  .map(
                    (col) => DataColumn(
                  label: Text(
                    col,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
                  .toList(),
              rows: data.map((row) {
                return DataRow(
                  cells: row.values
                      .map((cell) => DataCell(Text(cell)))
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}