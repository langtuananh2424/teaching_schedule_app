import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_app/controllers/session_controller.dart';
import 'package:frontend_app/controllers/auth_controller.dart';
import 'package:frontend_app/models/session.dart';
import 'package:frontend_app/models/schedule_status.dart';
import 'package:intl/intl.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart'; // Import thư viện lịch

class LecturerScheduleScreen extends StatelessWidget {
  const LecturerScheduleScreen({super.key});

  // Tách AppBar ra thành một widget riêng
  PreferredSizeWidget _buildAppBar(AuthController authController) {
    // Màu xanh đậm cho AppBar
    const Color darkBlue = Color(0xFF003366);

    return PreferredSize(
      preferredSize: const Size.fromHeight(56.0), // Chiều cao AppBar chuẩn
      child: Container(
        color: darkBlue,
        child: SafeArea( // Đảm bảo không bị đè lên thanh status
          child: Row(
            children: [
              // Nút Quay lại
              TextButton.icon(
                onPressed: () {
                  // Có thể dùng Get.back() nếu đây là màn hình con
                  // Hoặc không làm gì nếu đây là màn hình chính
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  'Quay lại',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const Spacer(), // Đẩy icon người dùng sang phải

              // Icon Người dùng
              IconButton(
                icon: const Icon(Icons.account_circle, color: Colors.white, size: 30),
                onPressed: () {
                  // Logic mở màn hình profile
                },
              ),

              // Icon Đăng xuất
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () {
                  authController.logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tách phần lịch ra widget riêng
  // Tách phần lịch ra widget riêng
  Widget _buildCalendarSection(SessionController sessionController) {
    const Color darkBlue = Color(0xFF003366); // Màu xanh đậm

    return Container(
      color: darkBlue, // Nền xanh đậm
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Text "Tháng 10, 2025"
          Obx(() {
            String monthYear = DateFormat('MMMM, yyyy', 'vi_VN')
                .format(sessionController.selectedDate.value);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Tháng ${monthYear[0].toUpperCase()}${monthYear.substring(1)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          }),

          // Lịch (Đã sửa cỡ chữ)
          DatePicker(
            DateTime.now().subtract(const Duration(days: 3)),
            height: 90,
            width: 70, // Giữ nguyên chiều rộng
            initialSelectedDate: sessionController.selectedDate.value,
            locale: 'vi_VN',
            onDateChange: (date) {
              sessionController.changeSelectedDate(date);
            },

            selectionColor: Colors.transparent,
            selectedTextColor: Colors.red,

            // === GIẢM CỠ CHỮ ĐỂ KHẮC PHỤC LỖI DẢI ĐỎ ===
            monthTextStyle: const TextStyle(color: Colors.white70, fontSize: 10), // Giảm từ 12 -> 10
            dayTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), // Giảm từ 14 -> 12
            dateTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20, // Giảm từ 22 -> 20
                fontWeight: FontWeight.bold
            ),
            // ===========================================
          ),
        ],
      ),
    );
  }

  // Widget build 1 thẻ buổi học (Đã cập nhật UI)
  Widget _buildSessionItem(BuildContext context, Session session) {
    // Logic màu sắc
    Color statusColor;

    // BIẾN timeColor KHÔNG CÒN CẦN THIẾT NỮA
    // Color timeColor;

    switch (session.status) {
      case ScheduleStatus.TAUGHT:
        statusColor = Colors.green;
        // timeColor = Colors.black;
        break;
      case ScheduleStatus.NOT_TAUGHT:
        statusColor = Colors.blue;
        // timeColor = Colors.black;
        break;
      case ScheduleStatus.ABSENT_APPROVED:
      case ScheduleStatus.ABSENT_UNAPPROVED:
        statusColor = Colors.red;
        // timeColor = Colors.red;
        break;
      case ScheduleStatus.MAKEUP_TAUGHT:
        statusColor = Colors.orange;
        // timeColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    // timeColor = Colors.black;
    }

    // Lấy "Giờ"
    final String time = DateFormat('HH:mm').format(session.sessionDate);

    return InkWell(
      onTap: () {
        Get.toNamed('/session_details', arguments: session);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD), // Màu nền xanh nhạt
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột 1: Giờ (Đã sửa màu)
            SizedBox(
              width: 60,
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // <-- ĐỔI THÀNH MÀU ĐỎ
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Cột 2: Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dữ liệu "Môn học" (Đã sửa)
                  Text(
                    session.assignment.subject.subjectName, // <-- CHỈ LẤY TÊN MÔN HỌC
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Dữ liệu "Phòng học"
                  Text(
                    session.classroom,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  // Dữ liệu "Status"
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                      children: [
                        const TextSpan(text: 'Trạng thái: '),
                        TextSpan(
                          text: session.statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // HÀM BUILD CHÍNH
  @override
  Widget build(BuildContext context) {
    final SessionController sessionController = Get.put(SessionController());
    final AuthController authController = Get.find();
    Intl.defaultLocale = 'vi_VN';

    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng cho danh sách

      // 1. AppBar tùy chỉnh
      appBar: _buildAppBar(authController),

      body: Column(
        children: [
          // 2. Phần lịch
          _buildCalendarSection(sessionController),

          // 3. Phần danh sách
          Expanded(
            child: Obx(() {
              if (sessionController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Sử dụng getter đã lọc
              final sessions = sessionController.filteredSessions;

              if (sessions.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có buổi học nào vào ngày này.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return _buildSessionItem(context, sessions[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}