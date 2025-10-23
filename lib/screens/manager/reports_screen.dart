import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _showSummary = false;
  final ApiService _apiService = ApiService();

  // Các biến để lưu dữ liệu và trạng thái tải
  late Future<List<List<FilterItem>>> _filtersFuture;
  List<FilterItem> _semesters = [];
  List<FilterItem> _lecturers = [];
  List<FilterItem> _classes = [];

  // Các biến để lưu giá trị được chọn
  int? _selectedSemesterId;
  int? _selectedLecturerId;
  int? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _fetchFilterData();
  }

  void _fetchFilterData() {
    final token = Provider.of<AuthService>(context, listen: false).token!;
    // Gọi cả 3 API cùng lúc
    _filtersFuture = Future.wait([
      _apiService.getSemesters(token),
      _apiService.getLecturers(token),
      _apiService.getClasses(token),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildFilterCard(context),
        const SizedBox(height: 20),
        if (_showSummary) _buildSummaryCard(context),
      ],
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<List<FilterItem>>>(
          future: _filtersFuture,
          builder: (context, snapshot) {
            // Hiển thị vòng xoay trong khi tải dữ liệu
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Hiển thị lỗi nếu có
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi tải dữ liệu bộ lọc: ${snapshot.error}'));
            }

            // Gán dữ liệu sau khi tải thành công
            if (snapshot.hasData) {
              _semesters = snapshot.data![0];
              _lecturers = snapshot.data![1];
              _classes = snapshot.data![2];
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tùy chọn báo cáo', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                // Dropdown Học kỳ (đã động)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Học kỳ'),
                  value: _selectedSemesterId,
                  items: _semesters.map((item) {
                    return DropdownMenuItem<int>(value: item.id, child: Text(item.name));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedSemesterId = value),
                ),
                const SizedBox(height: 10),

                // Dropdown Giảng viên (đã động)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Giảng viên'),
                  value: _selectedLecturerId,
                  items: _lecturers.map((item) {
                    return DropdownMenuItem<int>(value: item.id, child: Text(item.name));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedLecturerId = value),
                ),
                const SizedBox(height: 10),

                // Dropdown Lớp (đã động)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Lớp'),
                  value: _selectedClassId,
                  items: _classes.map((item) {
                    return DropdownMenuItem<int>(value: item.id, child: Text(item.name));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedClassId = value),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Gọi API để lấy dữ liệu báo cáo dựa trên các bộ lọc đã chọn
                    setState(() => _showSummary = true);
                  },
                  child: const Text('Xem báo cáo'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Hàm _buildSummaryCard không thay đổi
  Widget _buildSummaryRow(IconData icon, Color color, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kết quả tổng hợp', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSummaryRow(Icons.check_circle, Colors.green, 'Giờ giảng hoàn thành', '27 giờ'),
            _buildSummaryRow(Icons.remove_circle, Colors.orange, 'Giờ giảng đã nghỉ', '3 giờ'),
            _buildSummaryRow(Icons.sync, Colors.blue, 'Giờ giảng đã bù', '3 giờ'),
            _buildSummaryRow(Icons.star, Colors.purple, 'Chuyên cần lớp', '95.8%'),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportDetailScreen(
                        completedHours: 27,
                        plannedHours: 30,
                      ),
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
}