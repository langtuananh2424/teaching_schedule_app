import 'package:flutter/material.dart';
import 'package:frontend_app/models/schedule.dart';
import 'package:frontend_app/services/api_service.dart'; // Import service
import 'package:frontend_app/screens/lecturer/session_details_screen.dart'; // Import màn hình chi tiết
import 'package:frontend_app/models/session.dart';

import '../../utils/app_utils.dart';
import '../schedule_screen.dart'; // Import màu

// ĐỔI TÊN: ScheduleScreen -> LecturerScheduleScreen
class LecturerScheduleScreen extends StatefulWidget {
  @override
  _LecturerScheduleScreenState createState() => _LecturerScheduleScreenState();
}

class _LecturerScheduleScreenState extends State<LecturerScheduleScreen> {
  // Sử dụng FutureBuilder để gọi API
  late Future<List<Schedule>> futureSchedules;
  final ApiService apiService = ApiService(); // Khởi tạo service

  @override
  void initState() {
    super.initState();
    // Gọi API khi màn hình được khởi tạo
    futureSchedules = apiService.fetchTeachingSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
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
        // AppBar color được quản lý bởi theme
      ),
      body: Column(
        children: [
          buildWeekCalendar(),

          // Sử dụng FutureBuilder để hiển thị dữ liệu
          Expanded(
            child: FutureBuilder<List<Schedule>>(
              future: futureSchedules,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có lịch dạy nào.'));
                }

                // Dữ liệu đã sẵn sàng
                final schedules = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final item = schedules[index];
                    return ScheduleItem(schedule: item); // Truyền đối tượng Schedule
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget xây dựng phần lịch tuần (Giữ nguyên)
  Widget buildWeekCalendar() {
    final List<String> daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final List<String> dates = ['19', '20', '21', '22', '23', '24', '25'];

    return Container(
      color: Theme.of(context).primaryColor,
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

class ApiService {
}

// WIDGET MỤC LỊCH DẠY (Giữ nguyên)
class ScheduleItem extends StatelessWidget {
  final Schedule schedule;

  ScheduleItem({required this.schedule});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (schedule.status) {
      case 'Hoàn thành':
        statusColor = AppColors.statusCompleted;
        break;
      case 'Sắp diễn ra':
        statusColor = AppColors.statusUpcoming;
        break;
      case 'Dạy bù':
        statusColor = AppColors.statusMakeup;
        break;
      case 'Nghỉ':
        statusColor = AppColors.statusCancelled;
        break;
      default:
        statusColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // Đổi sang SessionDetailScreen
                builder: (context) => SessionDetailScreen(schedule: schedule),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightBlueBackground,
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
                Center(
                  child: Text(
                    schedule.time,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(width: 16),
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
