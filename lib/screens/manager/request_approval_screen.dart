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

    return FutureBuilder<List<AbsenceRequest>>(
      future: _apiService.getAbsenceRequests(token, status: 'PENDING'),
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

    return FutureBuilder<List<MakeupSession>>(
      future: _apiService.getMakeupSessions(token, status: 'PENDING'),
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
                          onPressed: () {
                            // TODO: Implement makeup session approval
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chức năng đang phát triển'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Duyệt'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement makeup session rejection
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chức năng đang phát triển'),
                              ),
                            );
                          },
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

    if (token == null) return;

    try {
      // TODO: Lấy approverId từ AuthService
      final approverId = 1; // Tạm thời hardcode

      await _apiService.approveAbsenceRequest(
        token,
        requestId: requestId,
        approverId: approverId,
        newStatus: approve ? 'APPROVED' : 'REJECTED',
      );

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
}