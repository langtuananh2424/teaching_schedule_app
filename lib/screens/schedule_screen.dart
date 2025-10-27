import 'package:flutter/material.dart';

// --- 1. DATA MODEL (LỚP MÔ HÌNH DỮ LIỆU) ---
class Schedule {
  final String time;
  final String subject;
  final String room;
  final String status;
  final String date; // Đã thêm ngày cho màn hình điểm danh

  Schedule({
    required this.time,
    required this.subject,
    required this.room,
    required this.status,
    required this.date,
  });
}

// Model cho Sinh viên
class Student {
  final String name;
  final String studentId;
  AttendanceStatus attendanceStatus; // Trạng thái điểm danh hiện tại

  Student({
    required this.name,
    required this.studentId,
    this.attendanceStatus = AttendanceStatus.present,
  });
}

// Enum để quản lý các trạng thái điểm danh
enum AttendanceStatus {
  present, // Có mặt (Màu xanh lá)
  absent, // Vắng (Màu đỏ)
  late, // Muộn (Màu vàng)
  excused // Có phép (Màu xanh dương)
}

// Hàm tiện ích để chuyển Enum sang String tiếng Việt
String getStatusString(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'Có mặt';
    case AttendanceStatus.absent:
      return 'Vắng';
    case AttendanceStatus.late:
      return 'Muộn';
    case AttendanceStatus.excused:
      return 'Có phép';
  }
}

// Hàm tiện ích để lấy màu cho trạng thái
Color getStatusColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return Colors.green.shade600;
    case AttendanceStatus.absent:
      return Colors.red.shade600;
    case AttendanceStatus.late:
      return Colors.amber.shade600;
    case AttendanceStatus.excused:
      return Colors.blue.shade600;
  }
}

// --- 2. DỮ LIỆU MÔ PHỎNG (SỬ DỤNG LỚP Schedule) ---
final List<Schedule> scheduleData = [
  Schedule(
    time: '7:00',
    subject: 'Mạng máy tính, 64KTPM3',
    room: '329-A2',
    status: 'Hoàn thành',
    date: '20/09/2025',
  ),
  Schedule(
    time: '9:45',
    subject: 'Mạng máy tính, 64KTPM5',
    room: '327-A2',
    status: 'Sắp diễn ra',
    date: '20/09/2025',
  ),
  Schedule(
    time: '12:55',
    subject: 'Quản trị mạng và hệ thống phân tán, 64HTTT1',
    room: '325-A2',
    status: 'Dạy bù', // ĐÃ CẬP NHẬT: Đổi 'Đầy đủ' thành 'Dạy bù'
    date: '20/09/2025',
  ),
  Schedule(
    time: '13:45',
    subject: 'Quản trị mạng, 64HTTT3',
    room: '327-A2',
    status: 'Nghỉ',
    date: '20/09/2025',
  ),
];

// Dữ liệu sinh viên mô phỏng cho màn hình điểm danh
final List<Student> mockStudentList = [
  Student(name: 'Nguyễn Văn A', studentId: '2251112345', attendanceStatus: AttendanceStatus.present),
  Student(name: 'Nguyễn Văn B', studentId: '2251112345', attendanceStatus: AttendanceStatus.absent),
  Student(name: 'Nguyễn Văn C', studentId: '2251112345', attendanceStatus: AttendanceStatus.late),
  Student(name: 'Nguyễn Văn D', studentId: '2251112345', attendanceStatus: AttendanceStatus.excused),
  Student(name: 'Nguyễn Văn E', studentId: '2251112345', attendanceStatus: AttendanceStatus.present),
  Student(name: 'Nguyễn Văn F', studentId: '2251112345', attendanceStatus: AttendanceStatus.present),
  Student(name: 'Nguyễn Văn G', studentId: '2251112345', attendanceStatus: AttendanceStatus.present),
  Student(name: 'Nguyễn Văn H', studentId: '2251112345', attendanceStatus: AttendanceStatus.present),
];


// --- 3. MAIN APPLICATION ---
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lịch Giảng Dạy',
      theme: ThemeData(fontFamily: 'Roboto'),
      home: ScheduleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- 4. MÀN HÌNH DANH SÁCH LỊCH DẠY (SCHEDULE SCREEN) ---
class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Thêm hành động quay lại, ví dụ: Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const Text('Quay lại', style: TextStyle(color: Colors.white)),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Lịch tuần được đặt trên cùng
          buildWeekCalendar(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              itemCount: scheduleData.length,
              itemBuilder: (context, index) {
                final item = scheduleData[index];
                return ScheduleItem(schedule: item); // Truyền đối tượng Schedule
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng phần lịch tuần
  Widget buildWeekCalendar() {
    final List<String> daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final List<String> dates = ['19', '20', '21', '22', '23', '24', '25'];

    return Container(
      color: Colors.blue.shade800,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          const Text(
            'Tháng 9, năm 2025',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(daysOfWeek.length, (index) {
              bool isSelected = index == 1; // Ví dụ: chọn T3/20
              Color dayColor = isSelected ? Colors.red : Colors.white;

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      daysOfWeek[index],
                      style: TextStyle(color: dayColor, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dates[index],
                      style: TextStyle(
                        color: dayColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// --- 5. WIDGET MỤC LỊCH DẠY (SCHEDULE ITEM) ---
class ScheduleItem extends StatelessWidget {
  final Schedule schedule;

  ScheduleItem({required this.schedule});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (schedule.status) {
      case 'Hoàn thành':
        statusColor = Colors.green.shade600;
        break;
      case 'Sắp diễn ra':
        statusColor = Colors.blue.shade700; // ĐÃ HOÁN ĐỔI MÀU: Sắp diễn ra là Xanh
        break;
      case 'Dạy bù':
        statusColor = Colors.orange.shade700; // ĐÃ HOÁN ĐỔI MÀU: Dạy bù là Cam
        break;
      case 'Nghỉ':
        statusColor = Colors.red.shade700;
        break;
      default:
        statusColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          // **HÀNH ĐỘNG ĐIỀU HƯỚNG MỚI**
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleDetailScreen(schedule: schedule),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            // **ĐÃ CẬP NHẬT MÀU NỀN THEO YÊU CẦU**
            backgroundColor: const Color(0xFFAEE4FF), // Sử dụng màu AEE4FF nguyên gốc (không có opacity)
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            elevation: 2,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Thời gian
                Center(
                  child: Text(
                    schedule.time,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(width: 16),
                // Tên môn học và phòng học
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        schedule.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        softWrap: true,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        schedule.room,
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Trạng thái
                Center(
                  child: Text(
                    'Trạng thái: ',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ),
                Text(
                  schedule.status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- 6. MÀN HÌNH CHI TIẾT LỊCH DẠY (DETAIL SCREEN) ---
class ScheduleDetailScreen extends StatelessWidget {
  final Schedule schedule;

  ScheduleDetailScreen({required this.schedule});

  @override
  Widget build(BuildContext context) {
    // Logic điều hướng có điều kiện
    final bool isRest = schedule.status == 'Nghỉ';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Quay lại', style: TextStyle(color: Colors.white)),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Lịch tuần (giữ nguyên giao diện)
          _buildDetailWeekCalendar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: isRest
                  ? _buildRestLayout(context) // Giao diện cho trạng thái Nghỉ
                  : _buildActiveLayout(context), // Giao diện cho trạng thái Hoạt động/Sắp diễn ra
            ),
          ),
        ],
      ),
    );
  }

  // Widget Lịch Tuần cho màn hình chi tiết
  Widget _buildDetailWeekCalendar() {
    // ... (logic Calendar tương tự như trên)
    return Container(
      color: Colors.blue.shade800,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          const Text(
            'Tháng 9, năm 2025',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(7, (index) {
              final List<String> daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
              final List<String> dates = ['19', '20', '21', '22', '23', '24', '25'];
              bool isSelected = index == 1;
              Color dayColor = isSelected ? Colors.red : Colors.white;

              return Expanded(
                child: Column(
                  children: [
                    Text(daysOfWeek[index], style: TextStyle(color: dayColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(dates[index], style: TextStyle(color: dayColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget chung cho cả hai trạng thái
  Widget _buildLessonInfo(BuildContext context) {
    Color statusColor;
    switch (schedule.status) {
      case 'Hoàn thành':
        statusColor = Colors.green.shade600;
        break;
      case 'Sắp diễn ra':
        statusColor = Colors.blue.shade700; // ĐÃ HOÁN ĐỔI MÀU: Sắp diễn ra là Xanh
        break;
      case 'Dạy bù':
        statusColor = Colors.orange.shade700; // ĐÃ HOÁN ĐỔI MÀU: Dạy bù là Cam
        break;
      case 'Nghỉ':
        statusColor = Colors.red.shade700;
        break;
      default:
        statusColor = Colors.black;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // **ĐÃ CẬP NHẬT MÀU NỀN CHO KHỐI CHI TIẾT**
        color: const Color(0xFFAEE4FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.time,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.room,
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Trạng thái: ',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
              Text(
                schedule.status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Nội dung buổi học:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              contentPadding: EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }


  // Giao diện khi trạng thái KHÔNG phải là Nghỉ (Hoạt động/Sắp diễn ra/Dạy bù)
  Widget _buildActiveLayout(BuildContext context) {
    // Vô hiệu hóa nút "Đăng ký dạy bù" nếu trạng thái là "Sắp diễn ra"
    final bool disableRegisterSubstitute = schedule.status == 'Sắp diễn ra';

    return Column(
      children: [
        _buildLessonInfo(context),
        const SizedBox(height: 20),

        _buildActionButton(context, 'Lưu nội dung', Colors.blue.shade700),
        const SizedBox(height: 10),

        _buildActionButton(
            context,
            'Điểm danh sinh viên',
            Colors.blueGrey.shade600,
            onPressed: () {
              // ĐIỀU HƯỚNG TỚI MÀN HÌNH ĐIỂM DANH
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(schedule: schedule),
                ),
              );
            }
        ),
        const SizedBox(height: 20),

        // Hàng chứa Hoàn thành và Đăng ký nghỉ
        Row(
          children: [
            Expanded(child: _buildActionButton(context, 'Hoàn thành', Colors.green.shade600)),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                  context,
                  'Đăng ký nghỉ',
                  Colors.orange.shade700,
                  onPressed: () {
                    // Điều hướng đến màn hình Đăng ký Nghỉ
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AbsenceRegistrationScreen(schedule: schedule),
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildActionButton(
            context,
            'Đăng ký dạy bù',
            Colors.blue.shade700,
            isDisabled: disableRegisterSubstitute, // Áp dụng logic vô hiệu hóa
            onPressed: () {
              // ĐIỀU HƯỚNG TỚI MÀN HÌNH ĐĂNG KÝ DẠY BÙ
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubstituteRegistrationScreen(schedule: schedule),
                ),
              );
            }
        ),
      ],
    );
  }

  // Giao diện khi trạng thái là Nghỉ (Simplified Layout)
  Widget _buildRestLayout(BuildContext context) {
    // Khi trạng thái là 'Nghỉ', chỉ có nút 'Đăng ký dạy bù' được kích hoạt
    final bool enableRegisterSubstitute = schedule.status == 'Nghỉ';

    return Column(
      children: [
        _buildLessonInfo(context),
        const SizedBox(height: 20),

        // Các nút khác ngoài "Đăng ký dạy bù" đều bị vô hiệu hóa
        _buildActionButton(context, 'Lưu nội dung', Colors.blue.shade700, isDisabled: true),
        const SizedBox(height: 10),

        _buildActionButton(context, 'Điểm danh sinh viên', Colors.blueGrey.shade600, isDisabled: true),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildActionButton(context, 'Hoàn thành', Colors.green.shade600, isDisabled: true)),
            const SizedBox(width: 10),
            // Nút "Đăng ký nghỉ" phải vô hiệu hóa ở đây
            Expanded(child: _buildActionButton(context, 'Đăng ký nghỉ', Colors.orange.shade700, isDisabled: true)),
          ],
        ),
        const SizedBox(height: 20),

        _buildActionButton(
            context,
            'Đăng ký dạy bù',
            Colors.blue.shade700,
            isDisabled: !enableRegisterSubstitute ? true : false,
            onPressed: () {
              // ĐIỀU HƯỚNG TỚI MÀN HÌNH ĐĂNG KÝ DẠY BÙ
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubstituteRegistrationScreen(schedule: schedule),
                ),
              );
            }
        ),
      ],
    );
  }


  // Widget tùy chỉnh cho các nút hành động
  Widget _buildActionButton(BuildContext context, String text, Color color, {bool isDisabled = false, VoidCallback? onPressed}) {
    Color buttonColor = isDisabled ? Colors.grey.shade400 : color;
    Color textColor = isDisabled ? Colors.grey.shade600 : Colors.white;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null // Vô hiệu hóa nút nếu isDisabled là true
            : onPressed ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hành động: $text')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// --- 7. MÀN HÌNH ĐĂNG KÝ NGHỈ (ABSENCE REGISTRATION SCREEN) ---
class AbsenceRegistrationScreen extends StatelessWidget {
  final Schedule schedule;

  AbsenceRegistrationScreen({required this.schedule});

  // Widget Lịch Tuần cho màn hình chi tiết (sao chép từ ScheduleDetailScreen)
  Widget _buildDetailWeekCalendar(BuildContext context) {
    return Container(
      color: Colors.blue.shade800,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          const Text(
            'Tháng 9, năm 2025',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(7, (index) {
              final List<String> daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
              final List<String> dates = ['19', '20', '21', '22', '23', '24', '25'];
              bool isSelected = index == 1; // Giả định ngày 20 (T3) được chọn
              Color dayColor = isSelected ? Colors.red : Colors.white;

              return Expanded(
                child: Column(
                  children: [
                    Text(daysOfWeek[index], style: TextStyle(color: dayColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(dates[index], style: TextStyle(color: dayColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin buổi học trong container màu xanh
  Widget _buildLessonInfoBlock() {
    Color statusColor;
    switch (schedule.status) {
      case 'Hoàn thành':
        statusColor = Colors.green.shade600;
        break;
      case 'Sắp diễn ra':
        statusColor = Colors.blue.shade700; // ĐÃ HOÁN ĐỔI MÀU
        break;
      case 'Dạy bù':
        statusColor = Colors.orange.shade700; // ĐÃ HOÁN ĐỔI MÀU
        break;
      case 'Nghỉ':
        statusColor = Colors.red.shade700;
        break;
      default:
        statusColor = Colors.black;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFAEE4FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.time,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.room,
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Trạng thái: ',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
              Text(
                schedule.status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Quay lại', style: TextStyle(color: Colors.white)),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildDetailWeekCalendar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLessonInfoBlock(),
                  const SizedBox(height: 20),

                  const Text('Lý do nghỉ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Minh chứng (Tùy chọn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  // Ô input cho Minh chứng/Browse
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Chọn file...', style: TextStyle(color: Colors.grey.shade700)),
                        ElevatedButton(
                          onPressed: () {
                            // Logic chọn file
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mở trình duyệt file để chọn minh chứng')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          ),
                          child: const Text('browse'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nút Gửi yêu cầu và Quay lại
                  Row(
                    children: [
                      Expanded(
                        child: _buildSubmitButton(
                            'Gửi yêu cầu',
                            Colors.orange.shade700,
                            onPressed: () {
                              // Logic gửi yêu cầu
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã gửi yêu cầu đăng ký nghỉ')),
                              );
                            }
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildSubmitButton(
                            'Quay lại',
                            Colors.blue.shade700,
                            onPressed: () => Navigator.pop(context) // Quay lại màn hình chi tiết
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget nút tùy chỉnh cho màn hình Đăng ký Nghỉ
  Widget _buildSubmitButton(String text, Color color, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// --- 8. MÀN HÌNH ĐĂNG KÝ DẠY BÙ (SUBSTITUTE REGISTRATION SCREEN) ---
class SubstituteRegistrationScreen extends StatefulWidget {
  final Schedule schedule;
  SubstituteRegistrationScreen({required this.schedule});

  @override
  _SubstituteRegistrationScreenState createState() => _SubstituteRegistrationScreenState();
}

class _SubstituteRegistrationScreenState extends State<SubstituteRegistrationScreen> {
  // Dữ liệu cho Dropdown Ca
  final List<String> lessonShifts = [
    'Tiết 1-3 ( 7:00-9:40 )',
    'Tiết 4-6 ( 9:45-12:20)',
    'Tiết 7-9 ( 12:55-15:35 )',
    'Tiết 10-12 ( 15:40-18:20 )'
  ];

  // Dữ liệu cho Dropdown Toà
  final List<String> buildings = ['A2', 'B5'];

  // Dữ liệu cho Dropdown Phòng (Phòng A2 và B5)
  final Map<String, List<String>> roomsByBuilding = {
    'A2': ['329', '327', '325', '323', '321', '429', '427', '425', '421'],
    'B5': ['301', '302', '303', '304', '305'],
  };

  String? selectedShift;
  String? selectedBuilding;
  String? selectedRoom;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị mặc định cho Toà và Phòng
    selectedBuilding = buildings.first;
    selectedRoom = roomsByBuilding[selectedBuilding!]!.first;
  }

  // Widget Lịch Tuần (Sao chép từ màn hình Chi tiết)
  Widget _buildDetailWeekCalendar(BuildContext context) {
    return Container(
      color: Colors.blue.shade800,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          const Text(
            'Tháng 9, năm 2025',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(7, (index) {
              final List<String> daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
              final List<String> dates = ['19', '20', '21', '22', '23', '24', '25'];
              bool isSelected = index == 1; // Giả định ngày 20 (T3) được chọn
              Color dayColor = isSelected ? Colors.red : Colors.white;

              return Expanded(
                child: Column(
                  children: [
                    Text(daysOfWeek[index], style: TextStyle(color: dayColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(dates[index], style: TextStyle(color: dayColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin buổi học đã nghỉ/cần bù
  Widget _buildRestInfoBlock() {
    // Giả định ngày nghỉ/bù (lấy từ dữ liệu thực tế nếu có)
    String dateInfo = '13:45, thứ 3, 20/09/2025';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFAEE4FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buổi đã nghỉ: ${widget.schedule.subject}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
          ),
          const SizedBox(height: 4),
          Text(
            'Ngày nghỉ: $dateInfo',
            style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  // Widget chung cho Dropdown và TextField
  Widget _buildInputRow({
    required String label,
    Widget? inputWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 80, // Chiều rộng cố định cho nhãn
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: inputWidget,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentRooms = roomsByBuilding[selectedBuilding!]!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Quay lại', style: TextStyle(color: Colors.white)),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildDetailWeekCalendar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đăng ký dạy bù',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),

                  _buildRestInfoBlock(),
                  const SizedBox(height: 20),

                  const Text(
                    'Chọn lịch dạy bù:',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // 1. Ngày
                  _buildInputRow(
                    label: 'Ngày',
                    inputWidget: const TextField(
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yy',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),

                  // 2. Ca (Dropdown)
                  _buildInputRow(
                    label: 'Ca',
                    inputWidget: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedShift ?? lessonShifts.first,
                        items: lessonShifts.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedShift = newValue;
                          });
                        },
                        style: TextStyle(color: Colors.black),
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),

                  // 3. Toà (Dropdown)
                  _buildInputRow(
                    label: 'Toà',
                    inputWidget: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedBuilding,
                        items: buildings.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBuilding = newValue;
                            // Reset phòng khi toà nhà thay đổi
                            selectedRoom = roomsByBuilding[newValue!]!.first;
                          });
                        },
                        style: TextStyle(color: Colors.black),
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),

                  // 4. Phòng (Dropdown động)
                  _buildInputRow(
                    label: 'Phòng',
                    inputWidget: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedRoom,
                        items: currentRooms.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRoom = newValue;
                          });
                        },
                        style: TextStyle(color: Colors.black),
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Nút Gửi yêu cầu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã gửi yêu cầu dạy bù cho Ca: $selectedShift, Toà: $selectedBuilding, Phòng: $selectedRoom')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Gửi yêu cầu',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 9. MÀN HÌNH ĐIỂM DANH (ATTENDANCE SCREEN) ---
// (PHẦN NÀY ĐÃ BỊ THIẾU TRƯỚC ĐÓ GÂY RA LỖI)

class AttendanceScreen extends StatefulWidget {
  final Schedule schedule;
  const AttendanceScreen({Key? key, required this.schedule}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late List<Student> students;

  @override
  void initState() {
    super.initState();
    // Tạo bản sao của danh sách mock để tránh thay đổi dữ liệu gốc
    students = mockStudentList.map((s) => Student(
        name: s.name,
        studentId: s.studentId,
        attendanceStatus: s.attendanceStatus
    )).toList();
  }

  // Hàm thay đổi trạng thái điểm danh (chuyển đổi vòng tròn)
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
          const Text('Quay lại', style: TextStyle(color: Colors.white)),
          const Spacer(),
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            radius: 18,
            child: const Icon(Icons.person, color: Colors.blue),
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade800,
      elevation: 2,
    );
  }

  // Widget thông tin buổi học
  Widget _buildLessonInfoBlock() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFAEE4FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điểm danh sinh viên',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Môn học:', widget.schedule.subject),
          _buildInfoRow('Lớp:', widget.schedule.room), // Giả định room là Lớp
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return _AttendanceItem(
                  student: students[index],
                  onStatusTap: () => _updateAttendance(index),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Lưu điểm danh',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget con cho từng mục Sinh viên trong màn hình Điểm danh
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