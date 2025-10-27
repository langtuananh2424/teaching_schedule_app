import 'package:flutter/material.dart';
import 'package:frontend_app/models/schedule.dart';
// Import các màn hình liên quan
import 'package:frontend_app/screens/lecturer/attendance_screen.dart';
import 'package:frontend_app/screens/lecturer/request_absence_screen.dart';
import 'package:frontend_app/screens/lecturer/register_makeup_screen.dart';

import '../../utils/app_utils.dart';
import '../schedule_screen.dart';


// ĐỔI TÊN: ScheduleDetailScreen -> SessionDetailScreen
class SessionDetailScreen extends StatelessWidget {
  final Schedule schedule;

  SessionDetailScreen({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final bool isRest = schedule.status == 'Nghỉ';

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          _buildDetailWeekCalendar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: isRest
                  ? _buildRestLayout(context) // Giao diện cho trạng thái Nghỉ
                  : _buildActiveLayout(context), // Giao diện cho trạng thái Hoạt động
            ),
          ),
        ],
      ),
    );
  }

  // Widget Lịch Tuần cho màn hình chi tiết
  Widget _buildDetailWeekCalendar(BuildContext context) {
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withOpacity(0.5),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceScreen(schedule: schedule),
                ),
              );
            }
        ),
        const SizedBox(height: 20),

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestAbsenceScreen(schedule: schedule),
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
            isDisabled: disableRegisterSubstitute,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterMakeupScreen(schedule: schedule),
                ),
              );
            }
        ),
      ],
    );
  }

  // Giao diện khi trạng thái là Nghỉ (Simplified Layout)
  Widget _buildRestLayout(BuildContext context) {
    final bool enableRegisterSubstitute = schedule.status == 'Nghỉ';

    return Column(
      children: [
        _buildLessonInfo(context),
        const SizedBox(height: 20),

        _buildActionButton(context, 'Lưu nội dung', Colors.blue.shade700, isDisabled: true),
        const SizedBox(height: 10),

        _buildActionButton(context, 'Điểm danh sinh viên', Colors.blueGrey.shade600, isDisabled: true),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: _buildActionButton(context, 'Hoàn thành', Colors.green.shade600, isDisabled: true)),
            const SizedBox(width: 10),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterMakeupScreen(schedule: schedule),
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
            ? null
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
