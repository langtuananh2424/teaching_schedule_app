import 'package:flutter/material.dart';
import 'package:frontend_app/models/schedule.dart';
import 'package:frontend_app/services/api_service.dart';
import 'package:frontend_app/models/session.dart';

import '../../utils/app_utils.dart';
import '../schedule_screen.dart';

// MÀN HÌNH ĐIỂM DANH (ĐÃ DI CHUYỂN)
class AttendanceScreen extends StatefulWidget {
  final Schedule schedule;
  const AttendanceScreen({Key? key, required this.schedule}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<Student>> futureStudents;
  List<Student> students = [];
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Gọi API để lấy danh sách sinh viên
    futureStudents = apiService.fetchStudentsForClass(widget.schedule.room);
  }

  // Hàm thay đổi trạng thái điểm danh
  void _updateAttendance(int index) {
    setState(() {
      final currentStatus = students[index].attendanceStatus;
      switch (currentStatus) {
        case AttendanceStatus.present:
          students[index].attendanceStatus = AttendanceStatus.absent;
          break;
        case AttendanceStatus.absent:
          students[index].attendanceStatus = AttendanceStatus.late;
          break;
        case AttendanceStatus.late:
          students[index].attendanceStatus = AttendanceStatus.excused;
          break;
        case AttendanceStatus.excused:
          students[index].attendanceStatus = AttendanceStatus.present;
          break;
      }
    });
  }

  // Widget AppBar chung
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const Text('Quay lại'),
          const Spacer(),
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            radius: 18,
            child: const Icon(Icons.person, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // Widget thông tin buổi học
  Widget _buildLessonInfoBlock() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Điểm danh sinh viên',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Môn học:', widget.schedule.subject),
          _buildInfoRow('Lớp:', widget.schedule.room),
          _buildInfoRow('Ngày:', widget.schedule.date),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildLessonInfoBlock(),
          Expanded(
            // Dùng FutureBuilder để xử lý việc tải danh sách sinh viên
            child: FutureBuilder<List<Student>>(
              future: futureSchedules,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải danh sách sinh viên: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có sinh viên trong lớp.'));
                }

                // Khi dữ liệu sẵn sàng, gán vào biến state
                if (students.isEmpty) {
                  students = snapshot.data!;
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _AttendanceItem(
                      student: students[index],
                      onStatusTap: () => _updateAttendance(index),
                    );
                  },
                );
              },
            ),
          ),
          // Nút Lưu điểm danh
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu kết quả điểm danh')),
                  );
                },
                child: const Text('Lưu điểm danh'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget con cho từng mục Sinh viên
class _AttendanceItem extends StatelessWidget {
  final Student student;
  final VoidCallback onStatusTap;

  const _AttendanceItem({
    Key? key,
    required this.student,
    required this.onStatusTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusText = getStatusString(student.attendanceStatus);
    final statusColor = getStatusColor(student.attendanceStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            radius: 20,
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  student.studentId,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Nút trạng thái (có thể nhấn)
          InkWell(
            onTap: onStatusTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(
                statusText,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
