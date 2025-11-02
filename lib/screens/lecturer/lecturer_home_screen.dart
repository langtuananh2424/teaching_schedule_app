import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/session.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'session_details_screen.dart';

class LecturerHomeScreen extends StatefulWidget {
  const LecturerHomeScreen({super.key});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  late Future<List<Session>> _sessionsFuture;
  final ApiService _apiService = ApiService();
  DateTime _selectedDate = DateTime.now();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto-refresh mỗi 1 phút để cập nhật trạng thái thời gian thực
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild để cập nhật trạng thái
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _fetchData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final email = authService.userEmail;

    print('🔍 DEBUG - Fetching sessions for email: $email');

    if (token != null && email != null) {
      setState(() {
        _sessionsFuture = _apiService.getSessions(token, email).then((
          sessions,
        ) {
          print('📅 DEBUG - Received ${sessions.length} sessions from API');
          for (var session in sessions) {
            print(
              '   Session: ${session.subjectName} - Date: ${DateFormat('dd/MM/yyyy').format(session.sessionDate)}',
            );
          }
          return sessions;
        });
      });
    } else {
      print('❌ DEBUG - Token or email is null');
      setState(() {
        _sessionsFuture = Future.error('Không tìm thấy token hoặc email.');
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchData();
  }

  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
    _fetchData();
  }

  void _goToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userName = authService.userName ?? 'Giảng viên';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chào, $userName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              /* Điều hướng đến trang hồ sơ */
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Không có lịch dạy cho ngày ${DateFormat('dd/MM').format(_selectedDate)}.',
                    ),
                  );
                }

                // LỌC sessions theo ngày được chọn
                final allSessions = snapshot.data!;
                print('📊 DEBUG - Total sessions: ${allSessions.length}');
                print(
                  '📅 DEBUG - Selected date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                );

                final sessions = allSessions.where((session) {
                  final sessionDate = session.sessionDate;
                  return sessionDate.year == _selectedDate.year &&
                      sessionDate.month == _selectedDate.month &&
                      sessionDate.day == _selectedDate.day;
                }).toList();

                print(
                  '✅ DEBUG - Filtered sessions for selected date: ${sessions.length}',
                );

                // Nếu không có lịch cho ngày này
                if (sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Không có lịch dạy cho ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)}.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    return _buildSessionCard(sessions[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // CẬP NHẬT LẠI WIDGET NÀY
  Widget _buildCalendarHeader() {
    final today = DateTime.now();
    DateTime startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousWeek,
              ),
              Expanded(
                child: Text(
                  'Tháng ${DateFormat.M('vi_VN').format(_selectedDate)}, năm ${DateFormat.y('vi_VN').format(_selectedDate)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextWeek,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Session>>(
            future: _sessionsFuture,
            builder: (context, snapshot) {
              final allSessions = snapshot.data ?? [];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (index) {
                  // Bỏ Chủ nhật (index 0-5 = Thứ 2 đến Thứ 7)
                  final date = startOfWeek.add(Duration(days: index));
                  final dayOfWeek = DateFormat.E('vi_VN').format(date);
                  final dayOfMonth = DateFormat.d('vi_VN').format(date);

                  final isToday =
                      date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;

                  final isSelected =
                      date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  // Kiểm tra ngày thuộc tháng khác
                  final isDifferentMonth = date.month != _selectedDate.month;

                  // Kiểm tra ngày này có lịch không
                  final hasSchedule = allSessions.any(
                    (session) =>
                        session.sessionDate.year == date.year &&
                        session.sessionDate.month == date.month &&
                        session.sessionDate.day == date.day,
                  );

                  return GestureDetector(
                    onTap: () => _onDateSelected(date),
                    child: Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            )
                          : null,
                      child: Column(
                        children: [
                          Text(
                            dayOfWeek,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDifferentMonth
                                  ? Colors.grey.shade400
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayOfMonth,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isToday
                                  ? Colors.red
                                  : isDifferentMonth
                                  ? Colors.grey.shade400
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Chấm xanh nếu có lịch
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: hasSchedule
                                  ? Colors.green
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Session session) {
    final statusDisplay = session.statusDisplay;

    // Lấy giờ bắt đầu
    const periodStartMap = {
      1: "7:00",
      2: "7:50",
      3: "8:40",
      4: "9:45",
      5: "10:35",
      6: "11:25",
      7: "12:55",
      8: "13:45",
      9: "14:35",
      10: "15:40",
      11: "16:30",
      12: "17:20",
    };
    final startTimeStr = periodStartMap[session.startPeriod] ?? '--:--';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SessionDetailsScreen(session: session),
              ),
            ).then((value) {
              if (value == true) _fetchData(); // Reload if changed
            }),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: statusDisplay.color.withOpacity(0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Giờ học (hiển thị lớn bên trái)
                  Text(
                    startTimeStr,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: statusDisplay.color,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Thông tin môn học và phòng
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.subjectName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.classroom,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Trạng thái
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusDisplay.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Trạng thái: ${statusDisplay.text}',
                  style: TextStyle(
                    color: statusDisplay.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
