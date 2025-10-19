import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

// --- Models Dữ liệu (Để dễ quản lý, bạn có thể tách ra file riêng) ---

// Enum để quản lý các trạng thái điểm danh một cách rõ ràng
enum AttendanceStatus {
  present, // Có mặt
  absent, // Vắng
  late, // Muộn
  permittedAbsence, // Có phép
}

// Lớp đại diện cho dữ liệu của một sinh viên trong màn hình điểm danh
class StudentForAttendance {
  final String id;
  final String name;
  final String code;
  AttendanceStatus status; // Trạng thái điểm danh hiện tại

  StudentForAttendance({
    required this.id,
    required this.name,
    required this.code,
    this.status = AttendanceStatus.present, // Mặc định là 'Có mặt'
  });
}

// --- Giao diện Màn hình ---

class AttendanceScreen extends StatefulWidget {
  // final int sessionId; // Nhận sessionId thực tế để gọi API

  const AttendanceScreen({
    super.key,
    /* required this.sessionId */
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Dữ liệu mẫu - TODO: Thay thế bằng lệnh gọi API để lấy danh sách sinh viên
  late List<StudentForAttendance> _students;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    // Đây là nơi bạn sẽ gọi API để lấy danh sách sinh viên của buổi học
    // Ví dụ: _students = await ApiService().getStudentsForSession(widget.sessionId);
    setState(() {
      _students = [
        StudentForAttendance(id: '1', name: 'Nguyễn Văn A', code: '2251112345'),
        StudentForAttendance(
          id: '2',
          name: 'Nguyễn Văn B',
          code: '2251112345',
          status: AttendanceStatus.absent,
        ),
        StudentForAttendance(
          id: '3',
          name: 'Nguyễn Văn C',
          code: '2251112345',
          status: AttendanceStatus.late,
        ),
        StudentForAttendance(
          id: '4',
          name: 'Nguyễn Văn D',
          code: '2251112345',
          status: AttendanceStatus.permittedAbsence,
        ),
        StudentForAttendance(id: '5', name: 'Nguyễn Văn E', code: '2251112345'),
        StudentForAttendance(id: '6', name: 'Nguyễn Văn F', code: '2251112345'),
        StudentForAttendance(id: '7', name: 'Nguyễn Văn G', code: '2251112345'),
        StudentForAttendance(id: '8', name: 'Nguyễn Văn H', code: '2251112345'),
      ];
    });
  }

  void _submitAttendance() {
    // TODO: Triển khai logic gửi dữ liệu điểm danh lên server
    // 1. Thu thập dữ liệu: lặp qua _students và tạo payload
    // 2. Gọi API service để gửi payload
    // 3. Hiển thị thông báo thành công hoặc thất bại
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu kết quả điểm danh!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm danh sinh viên'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person, size: 20),
            ),
            onPressed: () {
              // TODO: Điều hướng đến trang cá nhân
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Thẻ thông tin buổi học
          _buildSessionInfoCard(),

          // Danh sách sinh viên
          Expanded(
            child: _students.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      return _buildStudentItem(_students[index]);
                    },
                  ),
          ),
        ],
      ),
      // Nút Lưu nổi ở dưới
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: FloatingActionButton.extended(
          onPressed: _submitAttendance,
          label: const Text('Lưu điểm danh'),
          icon: const Icon(Icons.save),
        ),
      ),
    );
  }

  // Widget cho thẻ thông tin buổi học
  Widget _buildSessionInfoCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
      child: Card(
        color: AppTheme.lightBlueBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Môn học:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Mạng máy tính'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lớp:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('64KTPM5'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ngày:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('20/09/2025'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget cho mỗi mục sinh viên trong danh sách
  Widget _buildStudentItem(StudentForAttendance student) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    student.code,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Widget cho các nút trạng thái
            StatusToggleButtons(
              currentStatus: student.status,
              onStatusChanged: (newStatus) {
                if (newStatus != null) {
                  setState(() {
                    student.status = newStatus;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget riêng cho các nút chuyển đổi trạng thái điểm danh
class StatusToggleButtons extends StatelessWidget {
  final AttendanceStatus currentStatus;
  final ValueChanged<AttendanceStatus?> onStatusChanged;

  const StatusToggleButtons({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  // Helper để lấy màu nền cho nút được chọn
  Color _getSelectedColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppTheme.presentColor;
      case AttendanceStatus.absent:
        return AppTheme.absentColor;
      case AttendanceStatus.late:
        return AppTheme.lateColor;
      case AttendanceStatus.permittedAbsence:
        return AppTheme.permittedAbsenceColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: AttendanceStatus.values
          .map((status) => status == currentStatus)
          .toList(),
      onPressed: (int index) {
        onStatusChanged(AttendanceStatus.values[index]);
      },
      borderRadius: BorderRadius.circular(20),
      selectedColor: Colors.white,
      fillColor: _getSelectedColor(currentStatus),
      color: Colors.black87,
      constraints: const BoxConstraints(minHeight: 32.0, minWidth: 55.0),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      // Cấu hình viền
      borderColor: Colors.grey.shade300,
      selectedBorderColor: Colors.transparent,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('Có mặt'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('Vắng'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('Muộn'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('Có phép'),
        ),
      ],
    );
  }
}
