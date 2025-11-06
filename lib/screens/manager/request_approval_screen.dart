import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/absence_request.dart';
import '../../models/makeup_session.dart';
import 'package:intl/intl.dart';

enum RequestType { absence, makeup }

class RequestApprovalScreen extends StatefulWidget {
  final RequestType initialTab;

  const RequestApprovalScreen({super.key, required this.initialTab});

  @override
  State<RequestApprovalScreen> createState() => _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends State<RequestApprovalScreen> {
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTab == RequestType.absence ? 0 : 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phê duyệt yêu cầu'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Yêu cầu nghỉ'),
              Tab(text: 'Yêu cầu dạy bù'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildAbsenceApprovalList(), _buildMakeupApprovalList()],
        ),
      ),
    );
  }

  Widget _buildAbsenceApprovalList() {
    final authService = Provider.of<AuthService>(context);
    final token = authService.token;

    if (token == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    final userRole = authService.userRole;
    final lecturerId = authService.userId;

    // Lấy TẤT CẢ requests và filter theo role + department
    return FutureBuilder<List<AbsenceRequest>>(
      future:
          Future.wait([
            _apiService.getAbsenceRequests(token),
            if (userRole == 'ROLE_MANAGER' && lecturerId != null)
              _apiService
                  .get('api/lecturers/$lecturerId', token: token)
                  .then((data) => data as Map<String, dynamic>)
            else
              Future.value(null),
          ]).then((results) async {
            final allRequests = results[0] as List<AbsenceRequest>;
            final managerProfile = results[1] as Map<String, dynamic>?;

            print(
              '🔍 All absence requests from backend: ${allRequests.length}',
            );

            // Debug: In chi tiết từng request
            if (allRequests.isNotEmpty) {
              print('📝 Sample requests:');
              for (var i = 0; i < allRequests.length && i < 3; i++) {
                final r = allRequests[i];
                print(
                  '   - Request ${r.id}: Lecturer=${r.lecturerName}, Subject=${r.subjectName}, managerStatus=${r.managerStatus}, academicStatus=${r.academicAffairsStatus}',
                );
              }
            }

            // Lấy department của Manager
            String? managerDepartment;
            if (userRole == 'ROLE_MANAGER' && managerProfile != null) {
              managerDepartment = managerProfile['departmentName'];
              print('👔 Manager department: $managerDepartment');
            }

            // Filter theo role + department:
            // - MANAGER chỉ thấy requests của giảng viên trong khoa VÀ managerStatus = PENDING
            // - ADMIN thấy tất cả requests có academicAffairsStatus = PENDING
            List<AbsenceRequest> filteredRequests;

            if (userRole == 'ROLE_MANAGER') {
              // Lấy danh sách lecturers trong khoa
              Set<int> departmentLecturerIds = {};
              if (managerDepartment != null) {
                try {
                  final allLecturers =
                      await _apiService.get('api/lecturers', token: token)
                          as List;
                  for (var lecturer in allLecturers) {
                    final deptName =
                        lecturer['departmentName'] ??
                        lecturer['department_name'];
                    if (deptName == managerDepartment) {
                      final lecturerId =
                          lecturer['lecturerId'] ?? lecturer['lecturer_id'];
                      if (lecturerId != null) {
                        departmentLecturerIds.add(
                          lecturerId is int
                              ? lecturerId
                              : int.parse(lecturerId.toString()),
                        );
                      }
                    }
                  }
                  print(
                    '📊 Department lecturer IDs: ${departmentLecturerIds.length}',
                  );
                } catch (e) {
                  print('⚠️ Could not load department lecturers: $e');
                }
              }

              filteredRequests = allRequests.where((r) {
                final isInDepartment =
                    managerDepartment == null ||
                    departmentLecturerIds.contains(r.lecturerId);
                final isPending = r.managerStatus == 'PENDING';
                return isInDepartment && isPending;
              }).toList();

              print(
                '👔 Manager filtered (department + PENDING): ${filteredRequests.length}',
              );
            } else if (userRole == 'ROLE_ADMIN') {
              filteredRequests = allRequests
                  .where((r) => r.academicAffairsStatus == 'PENDING')
                  .toList();
              print(
                '👨‍💼 Admin filtered (academicAffairsStatus=PENDING): ${filteredRequests.length}',
              );
            } else {
              filteredRequests = [];
              print('⚠️ Unknown role: $userRole');
            }

            return filteredRequests;
          }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('Không có yêu cầu nghỉ chờ duyệt'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[Nghỉ dạy] GV: ${request.lecturerName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Môn: ${request.subjectName} - ${request.className}'),
                    Text(
                      'Ngày: ${DateFormat('dd/MM/yyyy').format(request.sessionDate)}',
                    ),
                    Text('Phòng: ${request.classroom ?? "N/A"}'),
                    Text('Lý do: ${request.reason}'),
                    if (request.makeupDate != null) ...[
                      const Divider(),
                      const Text(
                        'Đề xuất dạy bù:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Ngày: ${DateFormat('dd/MM/yyyy').format(request.makeupDate!)}',
                      ),
                      Text('Phòng: ${request.makeupClassroom ?? "N/A"}'),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => _approveRequest(request.id, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Duyệt'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _approveRequest(request.id, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Từ chối'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMakeupApprovalList() {
    final authService = Provider.of<AuthService>(context);
    final token = authService.token;

    if (token == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    final userRole = authService.userRole;
    final lecturerId = authService.userId;

    return FutureBuilder<List<MakeupSession>>(
      future:
          Future.wait([
            _apiService.getMakeupSessions(token, status: 'PENDING'),
            if (userRole == 'ROLE_MANAGER' && lecturerId != null)
              _apiService
                  .get('api/lecturers/$lecturerId', token: token)
                  .then((data) => data as Map<String, dynamic>)
            else
              Future.value(null),
          ]).then((results) async {
            final allSessions = results[0] as List<MakeupSession>;
            final managerProfile = results[1] as Map<String, dynamic>?;

            print('🔍 Manager - TẤT CẢ makeup sessions: ${allSessions.length}');

            // Lấy department của Manager
            String? managerDepartment;
            if (userRole == 'ROLE_MANAGER' && managerProfile != null) {
              managerDepartment = managerProfile['departmentName'];
              print('👔 Manager department: $managerDepartment');
            }

            // Filter theo department cho Manager
            List<MakeupSession> filteredSessions;

            if (userRole == 'ROLE_MANAGER') {
              // Lấy danh sách lecturer names trong khoa
              Set<String> departmentLecturerNames = {};
              if (managerDepartment != null) {
                try {
                  final allLecturers =
                      await _apiService.get('api/lecturers', token: token)
                          as List;
                  for (var lecturer in allLecturers) {
                    final deptName =
                        lecturer['departmentName'] ??
                        lecturer['department_name'];
                    if (deptName == managerDepartment) {
                      final lecturerName =
                          lecturer['fullName'] ?? lecturer['full_name'];
                      if (lecturerName != null) {
                        departmentLecturerNames.add(lecturerName.toString());
                      }
                    }
                  }
                  print(
                    '📊 Department lecturer names: ${departmentLecturerNames.length}',
                  );
                } catch (e) {
                  print('⚠️ Could not load department lecturers: $e');
                }
              }

              filteredSessions = allSessions.where((session) {
                return managerDepartment == null ||
                    departmentLecturerNames.contains(session.lecturerName);
              }).toList();

              print(
                '👔 Manager filtered makeup sessions: ${filteredSessions.length}',
              );
            } else {
              // Admin thấy tất cả
              filteredSessions = allSessions;
            }

            return filteredSessions;
          }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final sessions = snapshot.data ?? [];

        if (sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('Không có yêu cầu dạy bù chờ duyệt'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[Dạy bù] GV: ${session.lecturerName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Môn: ${session.subjectName} - ${session.className}'),
                    Text(
                      'Ngày: ${DateFormat('dd/MM/yyyy').format(session.makeupDate)}',
                    ),
                    Text('Phòng: ${session.classroom}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _approveMakeupSession(session.id, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Duyệt'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _approveMakeupSession(session.id, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Từ chối'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveRequest(int requestId, bool approve) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final userRole = authService.userRole;

    if (token == null) return;

    try {
      final newStatus = approve ? 'APPROVED' : 'REJECTED';

      // Admin dùng academic-affairs-approval
      // Manager dùng manager-approval
      if (userRole == 'ROLE_ADMIN') {
        print('👨‍💼 Admin approving with academic-affairs-approval');
        await _apiService.approveAbsenceRequestByAcademicAffairs(
          token,
          requestId: requestId,
          newStatus: newStatus,
        );
      } else if (userRole == 'ROLE_MANAGER') {
        print('👔 Manager approving with manager-approval');
        await _apiService.approveAbsenceRequestByManager(
          token,
          requestId: requestId,
          newStatus: newStatus,
        );
      } else {
        throw Exception('Unauthorized: Role $userRole cannot approve requests');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Đã duyệt yêu cầu' : 'Đã từ chối yêu cầu'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
        setState(() {}); // Reload data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _approveMakeupSession(int makeupSessionId, bool approve) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final userRole = authService.userRole;

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
      return;
    }

    try {
      final newStatus = approve ? 'APPROVED' : 'REJECTED';

      // Admin dùng academic-affairs-approval
      // Manager dùng manager-approval
      if (userRole == 'ROLE_ADMIN') {
        print(
          '👨‍💼 Admin approving makeup session with academic-affairs-approval',
        );
        await _apiService.approveMakeupSessionByAcademicAffairs(
          token,
          makeupSessionId: makeupSessionId,
          newStatus: newStatus,
        );
      } else if (userRole == 'ROLE_MANAGER') {
        print('👔 Manager approving makeup session with manager-approval');
        await _apiService.approveMakeupSessionByManager(
          token,
          makeupSessionId: makeupSessionId,
          newStatus: newStatus,
        );
      } else {
        throw Exception(
          'Unauthorized: Role $userRole cannot approve makeup sessions',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? 'Đã duyệt buổi dạy bù' : 'Đã từ chối buổi dạy bù',
            ),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
        setState(() {}); // Reload data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
