import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_proposal.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ScheduleProposalScreen extends StatefulWidget {
  const ScheduleProposalScreen({super.key});

  @override
  State<ScheduleProposalScreen> createState() => _ScheduleProposalScreenState();
}

class _ScheduleProposalScreenState extends State<ScheduleProposalScreen> {
  late Future<List<ScheduleProposal>> _proposalsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    try {
      final token = context.read<AuthService>().token;
      if (token == null) {
        setState(() {
          _proposalsFuture = Future.error('Không có token xác thực');
        });
        return;
      }

      setState(() {
        _proposalsFuture = _apiService.getScheduleProposals(token);
      });
    } catch (e) {
      setState(() {
        _proposalsFuture = Future.error('Lỗi tải danh sách đề xuất: $e');
      });
    }
  }

  Future<void> _handleApproval(
    ScheduleProposal proposal,
    bool isDepartment,
  ) async {
    try {
      final token = context.read<AuthService>().token;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Không có token xác thực'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Xác thực trạng thái trước khi gửi request
      if (isDepartment && proposal.departmentStatus == 'Đã duyệt') {
        throw Exception('Đề xuất đã được khoa duyệt');
      }
      if (!isDepartment && proposal.academicStatus == 'Đã duyệt') {
        throw Exception('Đề xuất đã được phòng đào tạo duyệt');
      }
      if (!isDepartment && proposal.departmentStatus != 'Đã duyệt') {
        throw Exception('Khoa chưa duyệt đề xuất này');
      }

      if (isDepartment) {
        await _apiService.approveProposalByDepartment(token, proposal.id);
      } else {
        await _apiService.approveProposalByAcademicAffairs(token, proposal.id);
      }

      // Refresh data after approval
      await _loadProposals();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phê duyệt thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatusCell(bool isDepartmentApproved, bool isAcademicApproved) {
    if (!isDepartmentApproved) {
      return const Text('Chưa duyệt', style: TextStyle(color: Colors.orange));
    }
    if (!isAcademicApproved) {
      return const Text('Khoa đã duyệt', style: TextStyle(color: Colors.blue));
    }
    return const Text('Hoàn tất', style: TextStyle(color: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý Đề xuất Lịch học',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<ScheduleProposal>>(
              future: _proposalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có đề xuất nào'));
                }

                return Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('STT')),
                        DataColumn(label: Text('Tên lớp')),
                        DataColumn(label: Text('Môn học')),
                        DataColumn(label: Text('Thời gian học')),
                        DataColumn(label: Text('TG đăng ký')),
                        DataColumn(label: Text('Phòng đề xuất')),
                        DataColumn(label: Text('Cán bộ đề xuất')),
                        DataColumn(label: Text('TG đề xuất')),
                        DataColumn(label: Text('Loại đề xuất')),
                        DataColumn(label: Text('Trạng thái')),
                        DataColumn(label: Text('PGV/PTN duyệt')),
                        DataColumn(label: Text('Thao tác')),
                      ],
                      rows: List<DataRow>.generate(snapshot.data!.length, (
                        index,
                      ) {
                        final proposal = snapshot.data![index];
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(
                              Text(
                                '${proposal.classCode} - ${proposal.className}',
                              ),
                            ),
                            DataCell(
                              Text(
                                '${proposal.subjectCode} - ${proposal.subjectName}',
                              ),
                            ),
                            DataCell(Text(proposal.studyTime)),
                            DataCell(Text(proposal.registerTime)),
                            DataCell(
                              Text(
                                '${proposal.roomCode} - ${proposal.roomName}',
                              ),
                            ),
                            DataCell(Text(proposal.proposalTime)),
                            DataCell(Text(proposal.proposalType)),
                            DataCell(
                              Text(
                                '${proposal.departmentStatus} / ${proposal.academicStatus}',
                              ),
                            ),
                            DataCell(
                              _buildStatusCell(
                                proposal.departmentStatus == 'Đã duyệt',
                                proposal.academicStatus == 'Đã duyệt',
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (proposal.departmentStatus != 'Đã duyệt')
                                    ElevatedButton(
                                      onPressed: () =>
                                          _handleApproval(proposal, true),
                                      child: const Text('Khoa duyệt'),
                                    ),
                                  if (proposal.departmentStatus == 'Đã duyệt' &&
                                      proposal.academicStatus != 'Đã duyệt')
                                    ElevatedButton(
                                      onPressed: () =>
                                          _handleApproval(proposal, false),
                                      child: const Text('P.Đào tạo duyệt'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
