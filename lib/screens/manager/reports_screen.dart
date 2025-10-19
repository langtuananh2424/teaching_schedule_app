import 'package:flutter/material.dart';
import 'reports_details_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedSemester;
  String? _selectedLecturer;
  String? _selectedClass;
  bool _showSummary = false;

  // Dữ liệu mẫu - Thay thế bằng dữ liệu từ API
  final List<String> _semesters = ['HK I - 2025-2026', 'HK II - 2025-2026'];
  final List<String> _lecturers = [
    'Nguyễn Văn A',
    'Trần Thị Bích',
    'Kiều Tuấn Dũng',
  ];
  final List<String> _classes = [
    '64KTPM3 - PTUDDPTBĐ',
    '64HTTT1 - An toàn Mạng',
  ];

  void _viewReport() {
    // TODO: Thêm logic kiểm tra và gọi API để lấy dữ liệu tổng hợp
    if (_selectedSemester != null &&
        _selectedLecturer != null &&
        _selectedClass != null) {
      setState(() {
        _showSummary = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ các thông tin.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
        // Xóa nút back vì đây là màn hình gốc trong tab
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Khối tùy chọn báo cáo
            _buildSelectionCard(),
            const SizedBox(height: 20),
            // Khối kết quả tổng hợp (hiện ra sau khi nhấn nút)
            if (_showSummary) _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TÙY CHỌN BÁO CÁO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              items: _semesters,
              value: _selectedSemester,
              hint: 'Học kỳ',
              onChanged: (val) => setState(() => _selectedSemester = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              items: _lecturers,
              value: _selectedLecturer,
              hint: 'Giảng viên',
              onChanged: (val) => setState(() => _selectedLecturer = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              items: _classes,
              value: _selectedClass,
              hint: 'Lớp',
              onChanged: (val) => setState(() => _selectedClass = val),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _viewReport,
                child: const Text('Xem báo cáo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KẾT QUẢ TỔNG HỢP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildSummaryRow(
              Icons.check_circle_outline,
              'Giờ giảng hoàn thành:',
              '27 giờ',
              Colors.green,
            ),
            _buildSummaryRow(
              Icons.error_outline,
              'Giờ giảng đã nghỉ:',
              '3 giờ',
              Colors.orange,
            ),
            _buildSummaryRow(
              Icons.history,
              'Giờ giảng đã bù:',
              '3 giờ',
              Colors.blue,
            ),
            _buildSummaryRow(
              Icons.star_border,
              'Chuyên cần lớp:',
              '95.8%',
              Colors.purple,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportDetailsScreen(),
                    ),
                  );
                },
                child: const Text('Xem chi tiết'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
