import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/semester.dart';

class LecturerActivityReportScreen extends StatefulWidget {
  const LecturerActivityReportScreen({super.key});

  @override
  State<LecturerActivityReportScreen> createState() =>
      _LecturerActivityReportScreenState();
}

class _LecturerActivityReportScreenState
    extends State<LecturerActivityReportScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isGenerating = false;

  List<Semester> _semesters = [];
  List<FilterItem> _lecturers = [];

  int? _selectedSemesterId;
  int? _selectedLecturerId;

  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _apiService.getSemesters(token),
        _apiService.getLecturers(token),
      ]);

      setState(() {
        _semesters = results[0] as List<Semester>;
        _lecturers = results[1] as List<FilterItem>;
        _isLoading = false;
      });

      print(
        '✅ Loaded ${_semesters.length} semesters, ${_lecturers.length} lecturers',
      );
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  Future<void> _generateReport() async {
    if (_selectedSemesterId == null || _selectedLecturerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn Học kỳ và Giảng viên!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;

    setState(() => _isGenerating = true);

    try {
      // Gọi API báo cáo
      final response = await _apiService.get(
        'api/reports/lecturer-activity?semesterId=$_selectedSemesterId&lecturerId=$_selectedLecturerId',
        token: token,
      );

      setState(() {
        _reportData = response as Map<String, dynamic>;
        _isGenerating = false;
      });

      print('✅ Report generated successfully');
    } catch (e) {
      print('❌ Error generating report: $e');
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo báo cáo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải dữ liệu...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo hoạt động giảng viên')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tùy chọn báo cáo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dropdown Học kỳ
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Học kỳ',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                hintText: _semesters.isEmpty
                    ? 'Không có dữ liệu'
                    : 'Chọn học kỳ',
              ),
              value: _selectedSemesterId,
              items: _semesters.isEmpty
                  ? null
                  : _semesters.map((semester) {
                      return DropdownMenuItem(
                        value: semester.semesterId,
                        child: Text(semester.semesterName),
                      );
                    }).toList(),
              onChanged: _semesters.isEmpty
                  ? null
                  : (value) => setState(() => _selectedSemesterId = value),
            ),
            const SizedBox(height: 12),

            // Dropdown Giảng viên
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Giảng viên',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                hintText: _lecturers.isEmpty
                    ? 'Không có dữ liệu'
                    : 'Chọn giảng viên',
              ),
              value: _selectedLecturerId,
              items: _lecturers.isEmpty
                  ? null
                  : _lecturers.map((lecturer) {
                      return DropdownMenuItem(
                        value: lecturer.id,
                        child: Text(lecturer.name),
                      );
                    }).toList(),
              onChanged: _lecturers.isEmpty
                  ? null
                  : (value) => setState(() => _selectedLecturerId = value),
            ),
            const SizedBox(height: 20),

            // Nút tạo báo cáo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateReport,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.assessment),
                label: Text(
                  _isGenerating ? 'Đang tạo báo cáo...' : 'Tạo báo cáo',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            // Hiển thị báo cáo
            if (_reportData != null) ...[
              const SizedBox(height: 24),
              _buildReportContent(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    if (_reportData == null) return const SizedBox.shrink();

    final lecturerName = _reportData!['lecturerName'] ?? 'N/A';
    final subjectName = _reportData!['subjectName'] ?? 'N/A';
    final className = _reportData!['className'] ?? 'N/A';
    final semesterName = _reportData!['semesterName'] ?? 'N/A';
    final academicYear = _reportData!['academicYear'] ?? 'N/A';

    final plannedPeriods =
        _reportData!['plannedPeriods'] as Map<String, dynamic>?;
    final taughtPeriods =
        _reportData!['taughtPeriods'] as Map<String, dynamic>?;

    final plannedTotal = plannedPeriods?['total'] ?? 0;
    final taughtTotal = taughtPeriods?['total'] ?? 0;
    final completionRate = plannedTotal > 0
        ? (taughtTotal / plannedTotal * 100).toStringAsFixed(1)
        : '0.0';

    final studentReports =
        _reportData!['studentAttendanceReports'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thông tin chung
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin chung',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildInfoRow('Giảng viên:', lecturerName),
                _buildInfoRow('Môn học:', subjectName),
                _buildInfoRow('Lớp:', className),
                _buildInfoRow('Học kỳ:', '$semesterName ($academicYear)'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Thống kê giảng dạy
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thống kê giảng dạy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildPeriodStats('Kế hoạch:', plannedPeriods),
                const SizedBox(height: 8),
                _buildPeriodStats('Đã thực hiện:', taughtPeriods),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tỷ lệ hoàn thành:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$completionRate%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Điểm danh sinh viên
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Điểm danh sinh viên',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tổng: ${studentReports.length} SV',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Divider(),
                if (studentReports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Không có dữ liệu điểm danh')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: studentReports.length,
                    itemBuilder: (context, index) {
                      final student = studentReports[index];
                      return _buildStudentAttendanceCard(student);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodStats(String label, Map<String, dynamic>? periods) {
    if (periods == null) return const SizedBox.shrink();

    final total = periods['total'] ?? 0;
    final theory = periods['theory'] ?? 0;
    final practice = periods['practice'] ?? 0;
    final regularTaught = periods['regularTaught'] ?? 0;
    final makeupTaught = periods['makeupTaught'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Tổng: $total tiết', style: const TextStyle(fontSize: 14)),
              Text(
                '• Lý thuyết: $theory tiết',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '• Thực hành: $practice tiết',
                style: const TextStyle(fontSize: 14),
              ),
              if (regularTaught > 0 || makeupTaught > 0) ...[
                Text(
                  '• Dạy thường: $regularTaught tiết',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '• Dạy bù: $makeupTaught tiết',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentAttendanceCard(Map<String, dynamic> student) {
    final studentCode = student['studentCode'] ?? 'N/A';
    final studentName = student['studentName'] ?? 'N/A';
    final totalSessions = student['totalSessions'] ?? 0;
    final attendedSessions = student['attendedSessions'] ?? 0;
    final absencePercentage = (student['absencePercentage'] ?? 0.0).toDouble();

    Color percentageColor;
    if (absencePercentage < 20) {
      percentageColor = Colors.green;
    } else if (absencePercentage < 50) {
      percentageColor = Colors.orange;
    } else {
      percentageColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'MSSV: $studentCode',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Có mặt: $attendedSessions/$totalSessions buổi',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: percentageColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Vắng: ${absencePercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: percentageColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
