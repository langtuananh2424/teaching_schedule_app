import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/student.dart';

class ReportDetailScreen extends StatefulWidget {
  // Nhận dữ liệu để tính toán và hiển thị (tính theo TIẾT)
  final int completedPeriods;
  final int plannedPeriods;
  final int absentPeriods;
  final int makeupPeriods;
  final int classId;

  // Thông tin hiển thị
  final String lecturerName;
  final String subjectName;
  final String className;
  final String semesterName;
  final String academicYear;

  const ReportDetailScreen({
    super.key,
    required this.completedPeriods,
    required this.plannedPeriods,
    required this.absentPeriods,
    required this.makeupPeriods,
    required this.classId,
    required this.lecturerName,
    required this.subjectName,
    required this.className,
    required this.semesterName,
    required this.academicYear,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ApiService _apiService = ApiService();
  List<Student> _students = [];
  bool _isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final token = Provider.of<AuthService>(context, listen: false).token!;
    try {
      final students = await _apiService.getStudentsByClass(
        token,
        widget.classId,
      );
      setState(() {
        _students = students;
        _isLoadingStudents = false;
      });
    } catch (e) {
      setState(() => _isLoadingStudents = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách sinh viên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán phần trăm hoàn thành
    final double completionPercentage = (widget.plannedPeriods > 0)
        ? (widget.completedPeriods / widget.plannedPeriods)
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết báo cáo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTeacherInfo(),
            const SizedBox(height: 24),

            // THAY ĐỔI TẠI ĐÂY: Chỉ hiển thị nếu có dữ liệu
            if (widget.plannedPeriods > 0)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.lecturerName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Khoa: Công nghệ thông tin'),
        Text('Lớp: ${widget.className} - ${widget.subjectName}'),
        Text('Học kỳ: ${widget.semesterName} ${widget.academicYear}'),
      ],
    );
  }

  Widget _buildCourseOverview(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TỔNG QUAN LỚP HỌC PHẦN',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoàn thành: ${widget.completedPeriods}/${widget.plannedPeriods} tiết',
                  ),
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
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tiết nghỉ: ${widget.absentPeriods} tiết'),
            Text('Tiết bù: ${widget.makeupPeriods} tiết'),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Chuyên cần trung bình: 100.0%',
        ), // TODO: Tính từ API attendance
      ],
    );
  }

  Widget _buildAttendanceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHI TIẾT CHUYÊN CẦN (${_students.length} Sinh viên)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_isLoadingStudents)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_students.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Không có sinh viên trong lớp'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _students.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildStudentAttendanceCard(_students[index]);
            },
          ),
      ],
    );
  }

  Widget _buildStudentAttendanceCard(Student student) {
    // TODO: Tính toán attendance thực tế từ API
    // Hiện tại dùng mock data
    const int totalSessions = 15;
    const int attended = 14;
    const int absent = 1;
    final double attendanceRate = (attended / totalSessions) * 100;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.fullName} - ${student.studentCode}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Có mặt: $attended | Vắng: $absent',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              '${attendanceRate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: attendanceRate >= 80 ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
