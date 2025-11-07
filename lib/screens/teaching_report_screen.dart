import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/teaching_report.dart';
// import '../services/api_service.dart'; // TODO: Use when implementing getTeachingReports
import '../services/auth_service.dart';
// import '../services/teaching_report_service.dart'; // TODO: Create this service
import '../utils/excel_exporter.dart';
import 'package:intl/intl.dart';

class TeachingReportScreen extends StatefulWidget {
  const TeachingReportScreen({super.key});

  @override
  State<TeachingReportScreen> createState() => _TeachingReportScreenState();
}

class _TeachingReportScreenState extends State<TeachingReportScreen> {
  late Future<List<TeachingReport>> _reportsFuture;
  // final ApiService _apiService = ApiService(); // TODO: Use when implementing getTeachingReports
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final token = context.read<AuthService>().token;
    if (token != null) {
      // TODO: Implement getTeachingReports in ApiService
      // _reportsFuture = _apiService.getTeachingReports(token);
      _reportsFuture = Future.value([]); // Temporary empty list
    }
  }

  Widget _buildAbsencesList(List<AbsenceDetail> absences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: absences.map((absence) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(absence.subject),
          subtitle: Text(
            '${_dateFormat.format(absence.date)} (Tiết ${absence.startPeriod}-${absence.endPeriod})\n'
            'Lý do: ${absence.reason}',
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: absence.isMadeUp ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              absence.isMadeUp ? 'Đã dạy bù' : 'Chưa dạy bù',
              style: TextStyle(
                color: absence.isMadeUp
                    ? Colors.green[800]
                    : Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Báo Cáo Giờ Giảng',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              FutureBuilder<List<TeachingReport>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.file_download),
                    label: const Text('Xuất Excel'),
                    onPressed: snapshot.hasData
                        ? () => ExcelExporter.exportTeachingReports(
                            snapshot.data!,
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<TeachingReport>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final report = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(report.lecturerName),
                        subtitle: Text(
                          'Giờ dạy: ${report.totalActualHours}/${report.totalRegisteredHours} tiết',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Danh sách buổi nghỉ:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                _buildAbsencesList(report.absences),
                                if (report.makeups.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Danh sách dạy bù:',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    children: report.makeups.map((makeup) {
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(makeup.subject),
                                        subtitle: Text(
                                          '${_dateFormat.format(makeup.date)} '
                                          '(Tiết ${makeup.startPeriod}-${makeup.endPeriod})',
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
