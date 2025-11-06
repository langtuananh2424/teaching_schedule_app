import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/absence_request.dart';
import '../../models/makeup_session.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'absence_history_screen.dart';
import 'makeup_history_screen.dart';
import 'reports_screen.dart';
import 'request_approval_screen.dart';
import 'profile_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const DashboardContent(), // Nội dung chính của dashboard
    const ReportsScreen(),
    const ProfileScreen(), // Tab tài khoản
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthService>(context, listen: false).userName;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chào, ${userName ?? 'Quản lý'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthService>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Chuyển DashboardContent thành StatefulWidget để gọi API
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Future<DashboardSummary> _summaryFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    print('🚀 _fetchData() called');
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final userRole = authService.userRole;

    print('🔑 Token exists: ${token != null}');
    print('👤 User role: $userRole');

    if (token != null) {
      print('📡 Starting API calls...');
      // Lấy summary và filter theo role
      _summaryFuture = _apiService
          .getDashboardSummary(token)
          .then((summary) async {
            print(
              '✅ getDashboardSummary() returned: ${summary.recentRequests.length} recent requests',
            );
            // Manager: đếm requests có managerStatus=PENDING
            // Admin: đếm requests có academicAffairsStatus=PENDING
            return _apiService.getAbsenceRequests(token).then((
              allRequests,
            ) async {
              print(
                '📊 Dashboard: Received ${allRequests.length} absence requests',
              );
              print('👤 User role: $userRole');

              // ✅ SIMPLIFIED: Đếm đơn giản theo status, không filter department (tạm thời để test)
              int pendingAbsenceCount;
              if (userRole == 'ROLE_MANAGER') {
                // Đếm requests có managerStatus = PENDING
                print('🔍 Checking ROLE_MANAGER...');
                final pendingRequests = allRequests.where((r) {
                  print(
                    '  Checking request: ${r.reason} - managerStatus: ${r.managerStatus}',
                  );
                  return r.managerStatus == 'PENDING';
                }).toList();
                pendingAbsenceCount = pendingRequests.length;
                print('📋 Manager PENDING requests: $pendingAbsenceCount');
                if (pendingRequests.isNotEmpty) {
                  print('   Sample: ${pendingRequests.first.reason}');
                }
              } else if (userRole == 'ROLE_ADMIN') {
                print('🔍 Checking ROLE_ADMIN...');
                final pendingRequests = allRequests.where((r) {
                  print(
                    '  Checking request: ${r.reason} - academicAffairsStatus: ${r.academicAffairsStatus}',
                  );
                  return r.academicAffairsStatus == 'PENDING';
                }).toList();
                pendingAbsenceCount = pendingRequests.length;
                print('📋 Admin PENDING requests: $pendingAbsenceCount');
                if (pendingRequests.isNotEmpty) {
                  print(
                    '   Sample: ${pendingRequests.first.reason} - Status: ${pendingRequests.first.academicAffairsStatus}',
                  );
                }
              } else {
                pendingAbsenceCount = 0;
              }

              // Lấy makeup sessions và filter tương tự
              return _apiService.getMakeupSessions(token, status: 'PENDING').then((
                makeupSessions,
              ) async {
                int pendingMakeupCount = 0;

                if (userRole == 'ROLE_MANAGER') {
                  // Filter makeup sessions theo department
                  final email = authService.userEmail;
                  if (email != null) {
                    try {
                      final allLecturersData =
                          await _apiService.get('api/lecturers', token: token)
                              as List;
                      final managerData = allLecturersData
                          .where((l) => l['email'] == email)
                          .toList();

                      if (managerData.isNotEmpty) {
                        final managerDepartment =
                            managerData.first['departmentName'];

                        final departmentLecturerNames = allLecturersData
                            .where(
                              (l) => l['departmentName'] == managerDepartment,
                            )
                            .map((l) => l['fullName']?.toString() ?? '')
                            .where((name) => name.isNotEmpty)
                            .toSet();

                        // Filter makeup sessions by lecturer name
                        final filteredMakeupSessions = makeupSessions
                            .where(
                              (m) => departmentLecturerNames.contains(
                                m.lecturerName,
                              ),
                            )
                            .toList();

                        pendingMakeupCount = filteredMakeupSessions.length;
                        print(
                          '📋 Manager PENDING makeup sessions (filtered): $pendingMakeupCount',
                        );
                      }
                    } catch (e) {
                      print('⚠️ Error filtering makeup sessions: $e');
                      pendingMakeupCount = 0;
                    }
                  } else {
                    pendingMakeupCount = 0;
                  }
                } else if (userRole == 'ROLE_ADMIN') {
                  pendingMakeupCount = makeupSessions.length;
                  print(
                    '📋 Admin PENDING makeup sessions: $pendingMakeupCount',
                  );
                } else {
                  pendingMakeupCount = 0;
                }

                return DashboardSummary(
                  pendingAbsenceCount: pendingAbsenceCount,
                  pendingMakeupCount: pendingMakeupCount,
                  recentRequests: summary.recentRequests,
                );
              });
            });
          })
          .catchError((error) {
            print('⚠️ Dashboard API error: $error');
            // Nếu API lỗi, trả về dữ liệu mẫu
            return DashboardSummary(
              pendingAbsenceCount: 0,
              pendingMakeupCount: 0,
              recentRequests: [],
            );
          });
    } else {
      _summaryFuture = Future.error('Không tìm thấy token xác thực.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
          );
        }
        if (snapshot.hasData) {
          return _buildDashboardUI(snapshot.data!);
        }
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Không có dữ liệu.'),
        );
      },
    );
  }

  // Giao diện chính của dashboard, giờ sẽ nhận dữ liệu động
  Widget _buildDashboardUI(DashboardSummary summary) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _fetchData();
        });
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng quan nhanh',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDashboardCard(
                      summary.pendingAbsenceCount.toString(),
                      'Yêu cầu nghỉ chờ duyệt',
                      context,
                      RequestType.absence,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDashboardCard(
                      summary.pendingMakeupCount.toString(),
                      'Yêu cầu dạy bù chờ duyệt',
                      context,
                      RequestType.makeup,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Buttons to history screens
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AbsenceHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text(
                        'Lịch sử yêu cầu nghỉ',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MakeupHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.event_note, size: 18),
                      label: const Text(
                        'Lịch sử dạy bù',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              // Chỉ hiển thị nếu có yêu cầu
              if (summary.recentRequests.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Cần phê duyệt gần đây',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Vòng lặp để hiển thị các yêu cầu gần đây từ API
                    ...summary.recentRequests.map((request) {
                      if (request is AbsenceRequest) {
                        return _buildRequestCard(
                          '[Nghỉ dạy] GV: ${request.lecturerName}',
                          'Môn: ${request.subjectName}\n${DateFormat('dd/MM/yyyy').format(request.sessionDate)}',
                          context,
                        );
                      }
                      if (request is MakeupSession) {
                        return _buildRequestCard(
                          '[Dạy bù] GV: ${request.lecturerName}',
                          'Môn: ${request.subjectName}\n${DateFormat('dd/MM/yyyy').format(request.makeupDate)}',
                          context,
                        );
                      }
                      return const SizedBox.shrink(); // Trả về widget rỗng nếu không khớp
                    }).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Các hàm helper giữ nguyên
  Widget _buildDashboardCard(
    String count,
    String label,
    BuildContext context,
    RequestType type,
  ) {
    // Chọn màu theo loại yêu cầu
    final cardColor = type == RequestType.absence ? Colors.blue : Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestApprovalScreen(initialTab: type),
          ),
        ).then(
          (_) => setState(() => _fetchData()),
        ); // Tải lại dữ liệu khi quay về
      },
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    String title,
    String subtitle,
    BuildContext context,
  ) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Điều hướng đến màn hình chi tiết yêu cầu
        },
      ),
    );
  }
}
