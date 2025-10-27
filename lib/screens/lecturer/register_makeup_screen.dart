import 'package:flutter/material.dart';
import 'package:frontend_app/models/schedule.dart';

import '../../utils/app_utils.dart';
import '../schedule_screen.dart';

// ĐỔI TÊN: SubstituteRegistrationScreen -> RegisterMakeupScreen
class RegisterMakeupScreen extends StatefulWidget {
  final Schedule schedule;
  RegisterMakeupScreen({required this.schedule});

  @override
  _RegisterMakeupScreenState createState() => _RegisterMakeupScreenState();
}

class _RegisterMakeupScreenState extends State<RegisterMakeupScreen> {
  // Dữ liệu cho Dropdown
  final List<String> lessonShifts = [
    'Tiết 1-3 ( 7:00-9:40 )',
    'Tiết 4-6 ( 9:45-12:20)',
    'Tiết 7-9 ( 12:55-15:35 )',
    'Tiết 10-12 ( 15:40-18:20 )'
  ];
  final List<String> buildings = ['A2', 'B5'];
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
    selectedShift = lessonShifts.first;
    selectedBuilding = buildings.first;
    selectedRoom = roomsByBuilding[selectedBuilding!]!.first;
  }

  // Widget Lịch Tuần
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

  // Widget thông tin buổi học đã nghỉ
  Widget _buildRestInfoBlock() {
    String dateInfo = '13:45, thứ 3, ${widget.schedule.date}';

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
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
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
                        value: selectedShift,
                        items: lessonShifts.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)), // Giảm size chữ
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
                          SnackBar(content: Text('Đã gửi yêu cầu dạy bù')),
                        );
                      },
                      child: const Text('Gửi yêu cầu'),
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
