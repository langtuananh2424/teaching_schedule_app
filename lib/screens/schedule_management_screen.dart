import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';
import '../models/assignment.dart';
import '../services/api_service.dart';
import '../widgets/pagination_controls.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Schedule> _schedules = [];
  List<Schedule> _filteredSchedules = [];
  List<Assignment> _assignments = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [5, 10, 25, 50];

  // Bộ lọc
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedLecturer;
  String? _selectedStatus;

  final List<String> _daysOfWeek = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token == null) {
        setState(() {
          _error = 'Không tìm thấy token. Vui lòng đăng nhập lại.';
          _isLoading = false;
        });
        return;
      }

      // Load schedules and assignments in parallel
      final results = await Future.wait([
        _apiService.getSchedules(_token!),
        _apiService.getAssignments(_token!),
      ]);

      setState(() {
        _schedules = results[0] as List<Schedule>;

        // TODO: Auto-update đang gặp lỗi với backend
        // Tạm thời tắt và để user tự cập nhật thủ công
        // Backend trả về lỗi 400 "Failed to read request" khi update
        /*
        // Tự động cập nhật trạng thái thành COMPLETED nếu ngày đã qua
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (var schedule in _schedules) {
          if (schedule.sessionDate != null && schedule.sessionId != null) {
            final sessionDay = DateTime(
              schedule.sessionDate!.year,
              schedule.sessionDate!.month,
              schedule.sessionDate!.day,
            );

            // Nếu ngày học đã qua và trạng thái vẫn là PENDING hoặc NOT_TAUGHT
            if (sessionDay.isBefore(today) &&
                (schedule.status == 'PENDING' ||
                    schedule.status == 'NOT_TAUGHT')) {
              // Tự động cập nhật trạng thái sang COMPLETED
              _autoUpdateScheduleStatus(schedule.sessionId!, 'COMPLETED');
            }
          }
        }
        */

        _filteredSchedules = _schedules;
        _assignments = results[1] as List<Assignment>;
        _currentPage = 0;
        _applyFilters();
        _isLoading = false;

        // Debug: In ra dữ liệu để kiểm tra
        print('=== SCHEDULES DATA ===');
        print('Total schedules: ${_schedules.length}');
        if (_schedules.isNotEmpty) {
          print('First schedule:');
          print('  sessionId: ${_schedules[0].sessionId}');
          print('  assignmentId: ${_schedules[0].assignmentId}');
          print('  subjectName: ${_schedules[0].subjectName}');
          print('  className: ${_schedules[0].className}');
          print('  lecturerName: ${_schedules[0].lecturerName}');
          print('  sessionDate: ${_schedules[0].sessionDate}');
          print('  classroom: ${_schedules[0].classroom}');
          print('  status: ${_schedules[0].status}');
        }
        print('Total assignments: ${_assignments.length}');
        print('======================');
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _autoUpdateScheduleStatus(
    int sessionId,
    String newStatus,
  ) async {
    if (_token == null) return;

    try {
      // Tìm schedule để lấy tất cả các trường
      final schedule = _schedules.firstWhere((s) => s.sessionId == sessionId);

      // Kiểm tra các trường bắt buộc
      if (schedule.assignmentId == null ||
          schedule.sessionDate == null ||
          schedule.startPeriod == null ||
          schedule.endPeriod == null) {
        print(
          'Skip auto-update for schedule $sessionId: missing required fields',
        );
        return;
      }

      // Tạo bản sao với status mới và dùng toUpdateJson()
      final updatedSchedule = Schedule(
        sessionId: schedule.sessionId,
        assignmentId: schedule.assignmentId,
        sessionDate: schedule.sessionDate,
        lessonOrder: schedule.lessonOrder,
        startPeriod: schedule.startPeriod,
        endPeriod: schedule.endPeriod,
        classroom: schedule.classroom,
        content: schedule.content,
        status: newStatus,
        notes: schedule.notes,
      );

      final updateData = updatedSchedule.toUpdateJson();

      print('Auto-updating schedule $sessionId status to $newStatus');
      print('Update data: $updateData');

      await _apiService.updateSchedule(_token!, sessionId, updateData);

      print('Auto-update successful for schedule $sessionId');
    } catch (e) {
      print('Failed to auto-update schedule $sessionId: $e');
      // Không hiển thị lỗi cho user vì đây là auto-update
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredSchedules = _schedules.where((schedule) {
        // Lọc theo môn học
        if (_selectedSubject != null &&
            schedule.subjectName != _selectedSubject) {
          return false;
        }

        // Lọc theo lớp
        if (_selectedClass != null && schedule.className != _selectedClass) {
          return false;
        }

        // Lọc theo giảng viên
        if (_selectedLecturer != null &&
            schedule.lecturerName != _selectedLecturer) {
          return false;
        }

        // Lọc theo trạng thái
        if (_selectedStatus != null && schedule.status != _selectedStatus) {
          return false;
        }

        return true;
      }).toList();

      _currentPage = 0;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedSubject = null;
      _selectedClass = null;
      _selectedLecturer = null;
      _selectedStatus = null;
      _filteredSchedules = _schedules;
      _currentPage = 0;
    });
  }

  List<DropdownMenuItem<String?>> _buildSubjectDropdownItems() {
    final subjects =
        _schedules
            .map((s) => s.subjectName)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

    return [
      const DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
      ...subjects.map(
        (subject) =>
            DropdownMenuItem<String?>(value: subject, child: Text(subject)),
      ),
    ];
  }

  List<DropdownMenuItem<String?>> _buildClassDropdownItems() {
    final classes =
        _schedules.map((s) => s.className).whereType<String>().toSet().toList()
          ..sort();

    return [
      const DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
      ...classes.map(
        (className) =>
            DropdownMenuItem<String?>(value: className, child: Text(className)),
      ),
    ];
  }

  List<DropdownMenuItem<String?>> _buildLecturerDropdownItems() {
    final lecturers =
        _schedules
            .map((s) => s.lecturerName)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

    return [
      const DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
      ...lecturers.map(
        (lecturer) =>
            DropdownMenuItem<String?>(value: lecturer, child: Text(lecturer)),
      ),
    ];
  }

  List<Schedule> _getPaginatedSchedules() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(
      0,
      _filteredSchedules.length,
    );
    return _filteredSchedules.sublist(startIndex, endIndex);
  }

  Future<void> _addSchedule() async {
    final result = await showDialog<Schedule>(
      context: context,
      builder: (context) =>
          ScheduleDialog(assignments: _assignments, daysOfWeek: _daysOfWeek),
    );

    if (result != null && _token != null) {
      try {
        await _apiService.createSchedule(_token!, result.toJson());
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm lịch học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi thêm lịch học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editSchedule(Schedule schedule) async {
    final result = await showDialog<Schedule>(
      context: context,
      builder: (context) => ScheduleDialog(
        schedule: schedule,
        assignments: _assignments,
        daysOfWeek: _daysOfWeek,
      ),
    );

    if (result != null && _token != null && result.sessionId != null) {
      try {
        final jsonData = result.toUpdateJson();
        print('Updating schedule with data: $jsonData');

        await _apiService.updateSchedule(_token!, result.sessionId!, jsonData);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật lịch học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error updating schedule: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật lịch học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteSchedule(Schedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch học này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && _token != null && schedule.sessionId != null) {
      try {
        await _apiService.deleteSchedule(_token!, schedule.sessionId!);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa lịch học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa lịch học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : _schedules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có lịch học nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addSchedule,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm lịch học'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Header với tiêu đề và nút
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<int>(
                        future: Future.value(_schedules.length),
                        builder: (context, snapshot) {
                          final totalSchedules = snapshot.hasData
                              ? snapshot.data!
                              : 0;
                          return Text(
                            'Quản lý Lịch học ($totalSchedules buổi)',
                            style: Theme.of(context).textTheme.headlineMedium,
                          );
                        },
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Làm mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _addSchedule,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm Lịch học'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bộ lọc
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.filter_list, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Bộ lọc',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedSubject != null ||
                                  _selectedClass != null ||
                                  _selectedLecturer != null ||
                                  _selectedStatus != null)
                                TextButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.clear, size: 16),
                                  label: const Text('Xóa bộ lọc'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              // Lọc theo môn học
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String?>(
                                  value: _selectedSubject,
                                  decoration: const InputDecoration(
                                    labelText: 'Môn học',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: _buildSubjectDropdownItems(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSubject = value;
                                      _applyFilters();
                                    });
                                  },
                                ),
                              ),

                              // Lọc theo lớp
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String?>(
                                  value: _selectedClass,
                                  decoration: const InputDecoration(
                                    labelText: 'Lớp',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: _buildClassDropdownItems(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedClass = value;
                                      _applyFilters();
                                    });
                                  },
                                ),
                              ),

                              // Lọc theo giảng viên
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String?>(
                                  value: _selectedLecturer,
                                  decoration: const InputDecoration(
                                    labelText: 'Giảng viên',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: _buildLecturerDropdownItems(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLecturer = value;
                                      _applyFilters();
                                    });
                                  },
                                ),
                              ),

                              // Lọc theo trạng thái
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String?>(
                                  value: _selectedStatus,
                                  decoration: const InputDecoration(
                                    labelText: 'Trạng thái',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Tất cả'),
                                    ),
                                    DropdownMenuItem<String?>(
                                      value: 'PENDING',
                                      child: Text('Chưa dạy'),
                                    ),
                                    DropdownMenuItem<String?>(
                                      value: 'COMPLETED',
                                      child: Text('Đã dạy'),
                                    ),
                                    DropdownMenuItem<String?>(
                                      value: 'CANCELLED',
                                      child: Text('Đã hủy'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value;
                                      _applyFilters();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_filteredSchedules.length != _schedules.length)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Hiển thị ${_filteredSchedules.length} / ${_schedules.length} buổi học',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Môn học')),
                          DataColumn(label: Text('Lớp')),
                          DataColumn(label: Text('Giảng viên')),
                          DataColumn(label: Text('Ngày')),
                          DataColumn(label: Text('Tiết')),
                          DataColumn(label: Text('Phòng')),
                          DataColumn(label: Text('Trạng thái')),
                          DataColumn(label: Text('Thao tác')),
                        ],
                        rows: _getPaginatedSchedules().map((schedule) {
                          return DataRow(
                            cells: [
                              DataCell(Text(schedule.subjectName ?? '-')),
                              DataCell(Text(schedule.className ?? '-')),
                              DataCell(Text(schedule.lecturerName ?? '-')),
                              DataCell(
                                Text(
                                  schedule.sessionDate != null
                                      ? '${schedule.sessionDate!.day}/${schedule.sessionDate!.month}/${schedule.sessionDate!.year}'
                                      : '-',
                                ),
                              ),
                              DataCell(
                                Text(
                                  schedule.startPeriod != null &&
                                          schedule.endPeriod != null
                                      ? '${schedule.startPeriod}-${schedule.endPeriod}'
                                      : '-',
                                ),
                              ),
                              DataCell(Text(schedule.classroom ?? '-')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: schedule.statusColor.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: schedule.statusColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    schedule.statusDisplay,
                                    style: TextStyle(
                                      color: schedule.statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Chỉnh sửa',
                                      onPressed: () => _editSchedule(schedule),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Xóa',
                                      onPressed: () =>
                                          _deleteSchedule(schedule),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                PaginationControls(
                  currentPage: _currentPage,
                  totalItems: _filteredSchedules.length,
                  rowsPerPage: _rowsPerPage,
                  rowsPerPageOptions: _rowsPerPageOptions,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  onRowsPerPageChanged: (rows) {
                    setState(() {
                      _rowsPerPage = rows;
                      _currentPage = 0;
                    });
                  },
                ),
              ],
            ),
    );
  }
}

class ScheduleDialog extends StatefulWidget {
  final Schedule? schedule;
  final List<Assignment> assignments;
  final List<String> daysOfWeek;

  const ScheduleDialog({
    super.key,
    this.schedule,
    required this.assignments,
    required this.daysOfWeek,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lessonOrderController;
  late TextEditingController _startPeriodController;
  late TextEditingController _endPeriodController;
  late TextEditingController _classroomController;
  late TextEditingController _contentController;
  late TextEditingController _notesController;
  int? _selectedAssignmentId;
  DateTime? _selectedDate;
  String? _selectedStatus;

  final List<Map<String, String>> _statuses = [
    {'value': 'PENDING', 'label': 'Chưa dạy'},
    {'value': 'COMPLETED', 'label': 'Đã dạy'},
    {'value': 'CANCELLED', 'label': 'Đã hủy'},
  ];

  @override
  void initState() {
    super.initState();
    _lessonOrderController = TextEditingController(
      text: widget.schedule?.lessonOrder?.toString() ?? '',
    );
    _startPeriodController = TextEditingController(
      text: widget.schedule?.startPeriod?.toString() ?? '',
    );
    _endPeriodController = TextEditingController(
      text: widget.schedule?.endPeriod?.toString() ?? '',
    );
    _classroomController = TextEditingController(
      text: widget.schedule?.classroom ?? '',
    );
    _contentController = TextEditingController(
      text: widget.schedule?.content ?? '',
    );
    _notesController = TextEditingController(
      text: widget.schedule?.notes ?? '',
    );
    _selectedAssignmentId = widget.schedule?.assignmentId;
    _selectedDate = widget.schedule?.sessionDate;

    // Map old status values to new values
    String? currentStatus = widget.schedule?.status;
    if (currentStatus == 'NOT_TAUGHT') {
      currentStatus = 'PENDING';
    } else if (currentStatus == 'TAUGHT') {
      currentStatus = 'COMPLETED';
    }
    _selectedStatus = currentStatus ?? 'PENDING';
  }

  @override
  void dispose() {
    _lessonOrderController.dispose();
    _startPeriodController.dispose();
    _endPeriodController.dispose();
    _classroomController.dispose();
    _contentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return AlertDialog(
      title: Text(isEditing ? 'Chỉnh sửa buổi học' : 'Thêm buổi học'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedAssignmentId,
                  decoration: const InputDecoration(
                    labelText: 'Phân công *',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.assignments.map((assignment) {
                    return DropdownMenuItem(
                      value: assignment.assignmentId,
                      child: Text(
                        '${assignment.subjectName ?? 'N/A'} - ${assignment.className ?? 'N/A'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAssignmentId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn phân công';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày học *',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Chọn ngày',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lessonOrderController,
                  decoration: const InputDecoration(
                    labelText: 'Buổi học thứ',
                    hintText: 'Ví dụ: 1, 2, 3...',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startPeriodController,
                        decoration: const InputDecoration(
                          labelText: 'Tiết bắt đầu *',
                          hintText: '1',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bắt buộc';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Số không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _endPeriodController,
                        decoration: const InputDecoration(
                          labelText: 'Tiết kết thúc *',
                          hintText: '3',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bắt buộc';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Số không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _classroomController,
                  decoration: const InputDecoration(
                    labelText: 'Phòng học',
                    hintText: 'Ví dụ: A101',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem(
                      value: status['value'],
                      child: Text(status['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng chọn ngày học'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final schedule = Schedule(
                sessionId: widget.schedule?.sessionId,
                assignmentId: _selectedAssignmentId,
                sessionDate: _selectedDate,
                lessonOrder: _lessonOrderController.text.isNotEmpty
                    ? int.tryParse(_lessonOrderController.text)
                    : null,
                startPeriod: int.parse(_startPeriodController.text),
                endPeriod: int.parse(_endPeriodController.text),
                classroom: _classroomController.text.isNotEmpty
                    ? _classroomController.text
                    : null,
                content: _contentController.text.isNotEmpty
                    ? _contentController.text
                    : null,
                status: _selectedStatus,
                notes: _notesController.text.isNotEmpty
                    ? _notesController.text
                    : null,
              );
              Navigator.pop(context, schedule);
            }
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }
}
