import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/semester.dart';
import '../../models/absence_request.dart';
import '../../models/makeup_session.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _showSummary = false;
  final ApiService _apiService = ApiService();

  // Các biến để lưu dữ liệu và trạng thái tải
  List<FilterItem> _academicYears = [];
  List<Semester> _semesters = [];
  List<FilterItem> _subjects = [];
  List<FilterItem> _lecturers = [];
  List<FilterItem> _classes = [];
  bool _isLoading = true;
  bool _isLoadingSemesters = false;
  bool _isLoadingSubjects = false;
  bool _isLoadingLecturers = false;
  bool _isLoadingClasses = false;

  // Các biến để lưu giá trị được chọn
  String? _selectedAcademicYear;
  int? _selectedSemesterId;
  int? _selectedSubjectId;
  int? _selectedLecturerId;
  int? _selectedClassId;

  // Dữ liệu báo cáo (tính theo TIẾT)
  int _completedPeriods = 0;
  int _absentPeriods = 0;
  int _makeupPeriods = 0;
  double _completionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchFilterData();
  }

  Future<void> _fetchFilterData() async {
    // final token = Provider.of<AuthService>(context, listen: false).token!;
    try {
      // Load danh sách Năm học
      // TODO: Có thể lấy từ API hoặc tạo động từ semesters

      // ========== MOCK DATA TẠM THỜI ==========
      var academicYears = [
        FilterItem(id: 1, name: "2023-2024"),
        FilterItem(id: 2, name: "2024-2025"),
        FilterItem(id: 3, name: "2025-2026"),
      ];
      // ========== KẾT THÚC MOCK DATA ==========

      setState(() {
        _academicYears = academicYears;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  // Load Kỳ học theo Năm học
  Future<void> _loadSemestersByYear(String academicYear) async {
    setState(() {
      _isLoadingSemesters = true;
      _semesters = [];
      _selectedSemesterId = null;
      _subjects = [];
      _selectedSubjectId = null;
      _lecturers = [];
      _selectedLecturerId = null;
      _classes = [];
      _selectedClassId = null;
      _showSummary = false;
    });

    // final token = Provider.of<AuthService>(context, listen: false).token!;
    try {
      // TODO: Gọi API với filter academicYear
      // var semesters = await _apiService.getSemesters(token, academicYear: academicYear);

      // ========== MOCK DATA TẠM THỜI ==========
      await Future.delayed(const Duration(milliseconds: 500));
      var semesters = <Semester>[];

      if (academicYear == "2024-2025") {
        semesters = [
          Semester(
            semesterId: 1,
            semesterName: "HK1",
            startDate: DateTime(2024, 9, 1),
            endDate: DateTime(2025, 1, 15),
            isActive: false,
          ),
          Semester(
            semesterId: 2,
            semesterName: "HK2",
            startDate: DateTime(2025, 1, 20),
            endDate: DateTime(2025, 6, 30),
            isActive: false,
          ),
        ];
      } else if (academicYear == "2025-2026") {
        semesters = [
          Semester(
            semesterId: 3,
            semesterName: "HK1",
            startDate: DateTime(2025, 9, 1),
            endDate: DateTime(2026, 1, 15),
            isActive: true,
          ),
        ];
      }
      // ========== KẾT THÚC MOCK DATA ==========

      setState(() {
        _semesters = semesters;
        _isLoadingSemesters = false;
      });
    } catch (e) {
      setState(() => _isLoadingSemesters = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải kỳ học: $e')));
      }
    }
  }

  // Load Môn học theo Kỳ học
  Future<void> _loadSubjectsBySemester(int semesterId) async {
    setState(() {
      _isLoadingSubjects = true;
      _subjects = [];
      _selectedSubjectId = null;
      _lecturers = [];
      _selectedLecturerId = null;
      _classes = [];
      _selectedClassId = null;
      _showSummary = false;
    });

    // final token = Provider.of<AuthService>(context, listen: false).token!;
    try {
      // TODO: Gọi API với filter semesterId
      // var subjects = await _apiService.getSubjects(token, semesterId: semesterId);

      // ========== MOCK DATA TẠM THỜI ==========
      await Future.delayed(const Duration(milliseconds: 500));
      var subjects = [
        FilterItem(id: 1, name: "Lập trình Java"),
        FilterItem(id: 2, name: "Cơ sở dữ liệu"),
        FilterItem(id: 3, name: "Mạng máy tính"),
        FilterItem(id: 4, name: "Công nghệ phần mềm"),
      ];
      // ========== KẾT THÚC MOCK DATA ==========

      setState(() {
        _subjects = subjects;
        _isLoadingSubjects = false;
      });
    } catch (e) {
      setState(() => _isLoadingSubjects = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải môn học: $e')));
      }
    }
  }

  // Load Giảng viên theo Môn học + Kỳ học
  Future<void> _loadLecturersBySubject(int subjectId, int semesterId) async {
    setState(() {
      _isLoadingLecturers = true;
      _lecturers = [];
      _selectedLecturerId = null;
      _classes = [];
      _selectedClassId = null;
      _showSummary = false;
    });

    // final token = Provider.of<AuthService>(context, listen: false).token!;
    try {
      // TODO: Gọi API với filter subjectId + semesterId
      // var lecturers = await _apiService.getLecturers(token, subjectId: subjectId, semesterId: semesterId);

      // ========== MOCK DATA TẠM THỜI ==========
      await Future.delayed(const Duration(milliseconds: 500));
      var lecturers = [
        FilterItem(id: 1, name: "Nguyễn Văn A"),
        FilterItem(id: 2, name: "Trần Thị B"),
        FilterItem(id: 3, name: "Lê Văn C"),
      ];
      // ========== KẾT THÚC MOCK DATA ==========

      setState(() {
        _lecturers = lecturers;
        _isLoadingLecturers = false;
      });
    } catch (e) {
      setState(() => _isLoadingLecturers = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải giảng viên: $e')));
      }
    }
  }

  // Load Lớp học theo Giảng viên + Môn học + Kỳ học
  Future<void> _loadClassesByLecturer(
    int lecturerId,
    int subjectId,
    int semesterId,
  ) async {
    setState(() {
      _isLoadingClasses = true;
      _classes = [];
      _selectedClassId = null;
      _showSummary = false;
    });

    // final token = Provider.of<AuthService>(context, listen: false).token!;
    try {
      // TODO: Gọi API với filter lecturerId + subjectId + semesterId
      // var classes = await _apiService.getClasses(token, lecturerId: lecturerId, subjectId: subjectId, semesterId: semesterId);

      // ========== MOCK DATA TẠM THỜI ==========
      await Future.delayed(const Duration(milliseconds: 500));
      var classes = [
        FilterItem(id: 1, name: "62PM1"),
        FilterItem(id: 2, name: "62PM2"),
        FilterItem(id: 3, name: "62CNTT1"),
      ];
      // ========== KẾT THÚC MOCK DATA ==========

      setState(() {
        _classes = classes;
        _isLoadingClasses = false;
      });
    } catch (e) {
      setState(() => _isLoadingClasses = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải lớp học: $e')));
      }
    }
  }

  Future<void> _loadReportData() async {
    final token = Provider.of<AuthService>(context, listen: false).token!;

    try {
      // Hiển thị loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải báo cáo...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // 1. Gọi cả 2 API cùng lúc để tối ưu tốc độ
      final results = await Future.wait([
        _apiService.getAbsenceRequests(
          token,
          lecturerId: _selectedLecturerId,
          status: 'APPROVED',
        ),
        _apiService.getMakeupSessions(
          token,
          lecturerId: _selectedLecturerId,
          status: 'APPROVED',
        ),
      ]);

      final absenceRequests = results[0] as List<AbsenceRequest>;
      final makeupSessions = results[1] as List<MakeupSession>;

      // 2. Tính tổng TIẾT nghỉ và TIẾT dạy bù (dựa vào startPeriod và endPeriod)
      int absentPeriods = 0;
      for (var request in absenceRequests) {
        if (request.startPeriod != null && request.endPeriod != null) {
          // Số tiết = endPeriod - startPeriod + 1
          // VD: Tiết 1-3 = 3 - 1 + 1 = 3 tiết
          absentPeriods += (request.endPeriod! - request.startPeriod! + 1);
        }
      }

      int makeupPeriods = 0;
      for (var session in makeupSessions) {
        // Số tiết = endPeriod - startPeriod + 1
        makeupPeriods += (session.endPeriod - session.startPeriod + 1);
      }

      // 3. Logic tính TIẾT hoàn thành
      // Giả định: Mỗi giảng viên có 45 tiết kế hoạch trong học kỳ (3 tiết x 15 tuần)
      // TODO: Có thể lấy từ API assignments/sessions trong tương lai
      int plannedPeriods = 45;

      // Tiết thực tế = Tiết kế hoạch - Tiết nghỉ + Tiết dạy bù
      // VD: 45 tiết kế hoạch - 6 tiết nghỉ + 3 tiết đã bù = 42 tiết thực tế
      int completedPeriods = plannedPeriods - absentPeriods + makeupPeriods;

      // Đảm bảo không âm và không vượt quá kế hoạch + bù
      completedPeriods = completedPeriods.clamp(
        0,
        plannedPeriods + makeupPeriods,
      );

      // 4. Tính % hoàn thành
      double completionRate = plannedPeriods > 0
          ? (completedPeriods / plannedPeriods * 100)
          : 0.0;

      // Đóng loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      setState(() {
        _completedPeriods = completedPeriods;
        _absentPeriods = absentPeriods;
        _makeupPeriods = makeupPeriods;
        _completionRate = completionRate;
        _showSummary = true;
      });

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tải báo cáo thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Đóng loading dialog nếu có lỗi
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải báo cáo: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildFilterCard(context),
        const SizedBox(height: 20),
        if (_showSummary) _buildSummaryCard(context),
      ],
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tùy chọn báo cáo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // 1. Dropdown Năm học
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Năm học',
                      prefixIcon: Icon(Icons.event_note),
                    ),
                    value: _selectedAcademicYear,
                    items: _academicYears.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.name,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedAcademicYear = value;
                          _showSummary = false; // Ẩn báo cáo khi thay đổi
                        });
                        _loadSemestersByYear(value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // 2. Dropdown Kỳ học (disabled khi chưa chọn Năm học)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Kỳ học',
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffix: _isLoadingSemesters
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    value: _selectedSemesterId,
                    items: _semesters.map((semester) {
                      return DropdownMenuItem<int>(
                        value: semester.semesterId,
                        child: Text(semester.semesterName),
                      );
                    }).toList(),
                    onChanged:
                        _selectedAcademicYear == null || _isLoadingSemesters
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSemesterId = value;
                                _showSummary = false; // Ẩn báo cáo khi thay đổi
                              });
                              _loadSubjectsBySemester(value);
                            }
                          },
                  ),
                  const SizedBox(height: 10),

                  // 3. Dropdown Môn học (disabled khi chưa chọn Kỳ học)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Môn học',
                      prefixIcon: const Icon(Icons.book),
                      suffix: _isLoadingSubjects
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    value: _selectedSubjectId,
                    items: _subjects.map((item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: _selectedSemesterId == null || _isLoadingSubjects
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSubjectId = value;
                                _showSummary = false; // Ẩn báo cáo khi thay đổi
                              });
                              _loadLecturersBySubject(
                                value,
                                _selectedSemesterId!,
                              );
                            }
                          },
                  ),
                  const SizedBox(height: 10),

                  // 4. Dropdown Giảng viên (disabled khi chưa chọn Môn học)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Giảng viên',
                      prefixIcon: const Icon(Icons.person),
                      suffix: _isLoadingLecturers
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    value: _selectedLecturerId,
                    items: _lecturers.map((item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: _selectedSubjectId == null || _isLoadingLecturers
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedLecturerId = value;
                                _showSummary = false; // Ẩn báo cáo khi thay đổi
                              });
                              _loadClassesByLecturer(
                                value,
                                _selectedSubjectId!,
                                _selectedSemesterId!,
                              );
                            }
                          },
                  ),
                  const SizedBox(height: 10),

                  // 5. Dropdown Lớp (disabled khi chưa chọn Giảng viên)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Lớp',
                      prefixIcon: const Icon(Icons.class_),
                      suffix: _isLoadingClasses
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    value: _selectedClassId,
                    items: _classes.map((item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: _selectedLecturerId == null || _isLoadingClasses
                        ? null
                        : (value) => setState(() {
                            _selectedClassId = value;
                            _showSummary = false; // Ẩn báo cáo khi thay đổi
                          }),
                  ),
                  const SizedBox(height: 20),

                  // Button Xem báo cáo
                  ElevatedButton(
                    onPressed:
                        (_selectedAcademicYear != null &&
                            _selectedSemesterId != null &&
                            _selectedSubjectId != null &&
                            _selectedLecturerId != null &&
                            _selectedClassId != null)
                        ? () => _loadReportData()
                        : null,
                    child: const Text('Xem báo cáo'),
                  ),
                ],
              ),
      ),
    );
  }

  // Hàm _buildSummaryCard không thay đổi
  Widget _buildSummaryRow(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    const int plannedPeriods =
        45; // Số tiết kế hoạch cố định (3 tiết x 15 tuần)

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kết quả tổng hợp',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Kế hoạch: $plannedPeriods tiết',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              Icons.check_circle,
              Colors.green,
              'Số tiết thực tế',
              '$_completedPeriods tiết',
            ),
            _buildSummaryRow(
              Icons.remove_circle,
              Colors.orange,
              'Số tiết đã nghỉ',
              '$_absentPeriods tiết',
            ),
            _buildSummaryRow(
              Icons.sync,
              Colors.blue,
              'Số tiết đã dạy bù',
              '$_makeupPeriods tiết',
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              Icons.star,
              Colors.purple,
              'Tỷ lệ hoàn thành',
              '${_completionRate.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  // Lấy tên đã chọn từ danh sách
                  final selectedLecturer = _lecturers.firstWhere(
                    (item) => item.id == _selectedLecturerId,
                  );
                  final selectedSubject = _subjects.firstWhere(
                    (item) => item.id == _selectedSubjectId,
                  );
                  final selectedClass = _classes.firstWhere(
                    (item) => item.id == _selectedClassId,
                  );
                  final selectedSemester = _semesters.firstWhere(
                    (semester) => semester.semesterId == _selectedSemesterId,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailScreen(
                        completedPeriods: _completedPeriods,
                        plannedPeriods: plannedPeriods,
                        absentPeriods: _absentPeriods,
                        makeupPeriods: _makeupPeriods,
                        classId: _selectedClassId!,
                        lecturerName: selectedLecturer.name,
                        subjectName: selectedSubject.name,
                        className: selectedClass.name,
                        semesterName: selectedSemester.semesterName,
                        academicYear: _selectedAcademicYear!,
                      ),
                    ),
                  );
                },
                child: const Text('Xem chi tiết'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
