import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/subject.dart';
import '../models/student_class.dart';
import '../models/lecturer.dart';
import '../services/api_service.dart';
import '../widgets/pagination_controls.dart';

class AssignmentManagementScreen extends StatefulWidget {
  const AssignmentManagementScreen({super.key});

  @override
  State<AssignmentManagementScreen> createState() =>
      _AssignmentManagementScreenState();
}

class _AssignmentManagementScreenState
    extends State<AssignmentManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Assignment> _assignments = [];
  List<Assignment> _filteredAssignments = [];
  List<Subject> _subjects = [];
  List<StudentClass> _classes = [];
  List<Lecturer> _lecturers = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  // Pagination
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [5, 10, 25, 50];

  // Bộ lọc
  int? _selectedSubjectId;
  int? _selectedClassId;
  int? _selectedLecturerId;
  List<Assignment> _allAssignments = [];

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

      print('🔄 Loading assignment data...');

      // Load assignments and reference data in parallel
      final results = await Future.wait([
        _apiService.getAssignments(_token!),
        _apiService.getSubjects(_token!),
        _apiService.getStudentClasses(_token!),
        _apiService.getLecturers(_token!),
      ]);

      print('✅ API Response:');
      print('   - Assignments: ${(results[0] as List).length}');
      print('   - Subjects: ${(results[1] as List).length}');
      print('   - Classes: ${(results[2] as List).length}');
      print('   - Lecturers: ${(results[3] as List).length}');

      // Parse data TRƯỚC KHI setState
      final assignments = results[0] as List<Assignment>;
      final subjects = results[1] as List<Subject>;
      final classes = results[2] as List<StudentClass>;
      final lecturers = results[3] as List<Lecturer>;
      
      print('📊 Parsed data:');
      print('   - Subjects: ${subjects.length} items');
      print('   - Classes: ${classes.length} items');
      print('   - Lecturers: ${lecturers.length} items');
      
      // Check nếu có data rỗng
      if (subjects.isEmpty) {
        print('⚠️ WARNING: Subjects list is EMPTY!');
      }
      if (classes.isEmpty) {
        print('⚠️ WARNING: Classes list is EMPTY!');
      }
      if (lecturers.isEmpty) {
        print('⚠️ WARNING: Lecturers list is EMPTY!');
      }

      setState(() {
        _assignments = assignments;
        _allAssignments = assignments;
        _subjects = subjects;
        _classes = classes;
        _lecturers = lecturers;
        
        // Validate và reset filter không hợp lệ
        _validateAndResetInvalidFilters();
        
        // Apply filter sau khi đã có đầy đủ data
        _filteredAssignments = _applyFilter(_allAssignments);
        _currentPage = 0;
        
        // CHỈ set isLoading = false KHI ĐÃ CÓ ĐẦY ĐỦ DATA
        _isLoading = false;
      });
      
      print('✅ setState completed, UI should update now');
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  List<Assignment> _applyFilter(List<Assignment> assignments) {
    return assignments.where((assignment) {
      if (_selectedSubjectId != null &&
          assignment.subjectId != _selectedSubjectId) {
        return false;
      }
      if (_selectedClassId != null && assignment.classId != _selectedClassId) {
        return false;
      }
      if (_selectedLecturerId != null &&
          assignment.lecturerId != _selectedLecturerId) {
        return false;
      }
      return true;
    }).toList();
  }

  void _filterAssignments() {
    setState(() {
      _currentPage = 0;
      _filteredAssignments = _applyFilter(_allAssignments);
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedSubjectId = null;
      _selectedClassId = null;
      _selectedLecturerId = null;
      _currentPage = 0;
      _filteredAssignments = _allAssignments;
    });
  }

  // Kiểm tra xem giá trị có tồn tại trong danh sách không
  bool _isValidSubjectId(int? id) {
    if (id == null) return true;
    if (_subjects.isEmpty) return false;
    return _subjects.any((s) => s.subjectId == id);
  }

  bool _isValidClassId(int? id) {
    if (id == null) return true;
    if (_classes.isEmpty) return false;
    return _classes.any((c) => c.classId == id);
  }

  bool _isValidLecturerId(int? id) {
    if (id == null) return true;
    if (_lecturers.isEmpty) return false;
    return _lecturers.any((l) => l.id == id);
  }

  // Reset filter khi data không hợp lệ
  void _validateAndResetInvalidFilters() {
    bool needsReset = false;

    if (_selectedSubjectId != null && !_isValidSubjectId(_selectedSubjectId)) {
      _selectedSubjectId = null;
      needsReset = true;
    }

    if (_selectedClassId != null && !_isValidClassId(_selectedClassId)) {
      _selectedClassId = null;
      needsReset = true;
    }

    if (_selectedLecturerId != null &&
        !_isValidLecturerId(_selectedLecturerId)) {
      _selectedLecturerId = null;
      needsReset = true;
    }

    if (needsReset) {
      _filteredAssignments = _applyFilter(_allAssignments);
    }
  }

  Future<void> _addAssignment() async {
    print('🔷 Opening Add Assignment Dialog...');
    print('   - Subjects available: ${_subjects.length}');
    print('   - Classes available: ${_classes.length}');
    print('   - Lecturers available: ${_lecturers.length}');
    
    if (_subjects.isEmpty || _classes.isEmpty || _lecturers.isEmpty) {
      print('⚠️ Warning: Some data is empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đợi dữ liệu tải xong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final result = await showDialog<Assignment>(
      context: context,
      builder: (context) => AssignmentDialog(
        subjects: _subjects,
        classes: _classes,
        lecturers: _lecturers,
      ),
    );

    if (result != null && _token != null) {
      try {
        await _apiService.createAssignment(_token!, result.toJson());
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm phân công thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi thêm phân công: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editAssignment(Assignment assignment) async {
    print('✏️ Opening Edit Assignment Dialog...');
    print('   - Editing assignment ID: ${assignment.assignmentId}');
    print('   - Current subjectId: ${assignment.subjectId}');
    print('   - Current classId: ${assignment.classId}');
    print('   - Current lecturerId: ${assignment.lecturerId}');
    
    if (_subjects.isEmpty || _classes.isEmpty || _lecturers.isEmpty) {
      print('⚠️ Warning: Some data is empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đợi dữ liệu tải xong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final result = await showDialog<Assignment>(
      context: context,
      builder: (context) => AssignmentDialog(
        assignment: assignment,
        subjects: _subjects,
        classes: _classes,
        lecturers: _lecturers,
      ),
    );

    if (result != null && _token != null && result.assignmentId != null) {
      try {
        await _apiService.updateAssignment(
          _token!,
          result.assignmentId!,
          result.toJson(),
        );
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật phân công thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật phân công: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAssignment(Assignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa phân công này?'),
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

    if (confirmed == true &&
        _token != null &&
        assignment.assignmentId != null) {
      try {
        await _apiService.deleteAssignment(_token!, assignment.assignmentId!);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa phân công thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa phân công: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  List<Assignment> _getPaginatedAssignments() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    return _filteredAssignments.sublist(
      startIndex,
      endIndex > _filteredAssignments.length
          ? _filteredAssignments.length
          : endIndex,
    );
  }

  String _getSubjectName(int subjectId) {
    final subject = _subjects.firstWhere(
      (s) => s.subjectId == subjectId,
      orElse: () => Subject(
        subjectId: subjectId,
        subjectCode: '',
        subjectName: 'N/A',
        credits: 0,
      ),
    );
    return subject.subjectName;
  }

  String _getClassName(int classId) {
    final studentClass = _classes.firstWhere(
      (c) => c.classId == classId,
      orElse: () => StudentClass(
        classId: classId,
        classCode: '',
        className: 'N/A',
        semester: '',
      ),
    );
    return studentClass.className;
  }

  String _getLecturerName(int lecturerId) {
    final lecturer = _lecturers.firstWhere(
      (l) => l.id == lecturerId,
      orElse: () => Lecturer(
        id: lecturerId,
        lecturerCode: '',
        fullName: 'N/A',
        email: '',
        departmentName: '',
        departmentId: 0,
        role: '',
      ),
    );
    return lecturer.fullName;
  }

  @override
  Widget build(BuildContext context) {
    // Lọc các đối tượng có ID hợp lệ và loại bỏ trùng lặp để dùng trong dropdown
    final subjectOptionsMap = <int, Subject>{};
    for (final subject in _subjects) {
      final id = subject.subjectId;
      if (id != null && !subjectOptionsMap.containsKey(id)) {
        subjectOptionsMap[id] = subject;
      }
    }
    final subjectOptions = subjectOptionsMap.values.toList();

    final classOptionsMap = <int, StudentClass>{};
    for (final studentClass in _classes) {
      final id = studentClass.classId;
      if (id != null && !classOptionsMap.containsKey(id)) {
        classOptionsMap[id] = studentClass;
      }
    }
    final classOptions = classOptionsMap.values.toList();

    final lecturerOptionsMap = <int, Lecturer>{};
    for (final lecturer in _lecturers) {
      final id = lecturer.id;
      if (!lecturerOptionsMap.containsKey(id)) {
        lecturerOptionsMap[id] = lecturer;
      }
    }
    final lecturerOptions = lecturerOptionsMap.values.toList();

    final canShowFilters =
        subjectOptions.isNotEmpty && classOptions.isNotEmpty && lecturerOptions.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý phân công giảng dạy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải dữ liệu...'),
                ],
              ),
            )
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
          : Column(
              children: [
                // Bộ lọc - chỉ hiển thị khi data đã load xong
                if (canShowFilters)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.filter_list,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Bộ lọc',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                if (_selectedSubjectId != null ||
                                    _selectedClassId != null ||
                                    _selectedLecturerId != null)
                                  TextButton.icon(
                                    onPressed: _clearFilter,
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Xóa lọc'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                // Dropdown lọc theo môn học
                                SizedBox(
                                  width: 280,
                                  child: DropdownButtonFormField<int?>(
                                    key: ValueKey('subject_filter_${subjectOptions.length}'),
                                    value: _isValidSubjectId(_selectedSubjectId) &&
                                            subjectOptions.any(
                                              (subject) =>
                                                  subject.subjectId ==
                                                  _selectedSubjectId,
                                            )
                                        ? _selectedSubjectId
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Môn học',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Tất cả môn học'),
                                      ),
                                      ...subjectOptions.map(
                                        (subject) => DropdownMenuItem<int?>(
                                          value: subject.subjectId,
                                          child: Text(
                                            '${subject.subjectCode} - ${subject.subjectName}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSubjectId = value;
                                      });
                                      _filterAssignments();
                                    },
                                  ),
                                ),
                                // Dropdown lọc theo lớp học
                                SizedBox(
                                  width: 280,
                                  child: DropdownButtonFormField<int?>(
                                    key: ValueKey('class_filter_${classOptions.length}'),
                                    value: _isValidClassId(_selectedClassId) &&
                                            classOptions.any(
                                              (studentClass) =>
                                                  studentClass.classId ==
                                                  _selectedClassId,
                                            )
                                        ? _selectedClassId
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Lớp học',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Tất cả lớp'),
                                      ),
                                      ...classOptions.map(
                                        (studentClass) => DropdownMenuItem<int?>(
                                          value: studentClass.classId,
                                          child: Text(
                                            '${studentClass.classCode} - ${studentClass.className}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedClassId = value;
                                      });
                                      _filterAssignments();
                                    },
                                  ),
                                ),
                                // Dropdown lọc theo giảng viên
                                SizedBox(
                                  width: 280,
                                  child: DropdownButtonFormField<int?>(
                                    key: ValueKey('lecturer_filter_${lecturerOptions.length}'),
                                    value: _isValidLecturerId(_selectedLecturerId) &&
                                            lecturerOptions.any(
                                              (lecturer) =>
                                                  lecturer.id ==
                                                  _selectedLecturerId,
                                            )
                                        ? _selectedLecturerId
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Giảng viên',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('Tất cả giảng viên'),
                                      ),
                                      ...lecturerOptions.map(
                                        (lecturer) => DropdownMenuItem<int?>(
                                          value: lecturer.id,
                                          child: Text(
                                            '${lecturer.lecturerCode ?? ''} - ${lecturer.fullName}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedLecturerId = value;
                                      });
                                      _filterAssignments();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _assignments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                              const Icon(
                                Icons.assignment,
                                size: 64,
                                color: Colors.grey,
                              ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có phân công nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addAssignment,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm phân công'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Học kỳ')),
                          DataColumn(label: Text('Môn học')),
                          DataColumn(label: Text('Lớp học')),
                          DataColumn(label: Text('Giảng viên')),
                          DataColumn(label: Text('Thao tác')),
                        ],
                                    rows: _getPaginatedAssignments().map((
                                      assignment,
                                    ) {
                          return DataRow(
                            cells: [
                                          DataCell(
                                            Text(assignment.semester ?? 'N/A'),
                                          ),
                              DataCell(
                                Text(
                                  assignment.subjectName ??
                                                  _getSubjectName(
                                                    assignment.subjectId,
                                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  assignment.className ??
                                                  _getClassName(
                                                    assignment.classId,
                                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  assignment.lecturerName ??
                                                  _getLecturerName(
                                                    assignment.lecturerId,
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
                                      onPressed: () =>
                                                      _editAssignment(
                                                        assignment,
                                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Xóa',
                                      onPressed: () =>
                                                      _deleteAssignment(
                                                        assignment,
                                                      ),
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
                  totalItems: _filteredAssignments.length,
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
                ),
              ],
            ),
      floatingActionButton: _assignments.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addAssignment,
              tooltip: 'Thêm phân công',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class AssignmentDialog extends StatefulWidget {
  final Assignment? assignment;
  final List<Subject> subjects;
  final List<StudentClass> classes;
  final List<Lecturer> lecturers;

  const AssignmentDialog({
    super.key,
    this.assignment,
    required this.subjects,
    required this.classes,
    required this.lecturers,
  });

  @override
  State<AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<AssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _semesterController;
  int? _selectedSubjectId;
  int? _selectedClassId;
  int? _selectedLecturerId;

  @override
  void initState() {
    super.initState();
    
    print('📝 Dialog initState:');
    print('   - Subjects passed: ${widget.subjects.length}');
    print('   - Classes passed: ${widget.classes.length}');
    print('   - Lecturers passed: ${widget.lecturers.length}');
    print('   - Is editing: ${widget.assignment != null}');
    
    _semesterController = TextEditingController(
      text: widget.assignment?.semester ?? '',
    );
    
    // Chỉ set giá trị nếu hợp lệ và lists không rỗng
    if (widget.subjects.isNotEmpty) {
      final subjectId = widget.assignment?.subjectId;
      print('   - Checking subjectId: $subjectId');
      if (subjectId != null && widget.subjects.any((s) => s.subjectId == subjectId)) {
        _selectedSubjectId = subjectId;
        print('   ✅ Set _selectedSubjectId = $subjectId');
      } else {
        print('   ⚠️ SubjectId not found in list');
      }
    }
    
    if (widget.classes.isNotEmpty) {
      final classId = widget.assignment?.classId;
      print('   - Checking classId: $classId');
      if (classId != null && widget.classes.any((c) => c.classId == classId)) {
        _selectedClassId = classId;
        print('   ✅ Set _selectedClassId = $classId');
      } else {
        print('   ⚠️ ClassId not found in list');
      }
    }
    
    if (widget.lecturers.isNotEmpty) {
      final lecturerId = widget.assignment?.lecturerId;
      print('   - Checking lecturerId: $lecturerId');
      if (lecturerId != null && widget.lecturers.any((l) => l.id == lecturerId)) {
        _selectedLecturerId = lecturerId;
        print('   ✅ Set _selectedLecturerId = $lecturerId');
      } else {
        print('   ⚠️ LecturerId not found in list');
      }
    }
  }

  @override
  void dispose() {
    _semesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.assignment != null;
    
    // Lọc dữ liệu hợp lệ và loại bỏ trùng lặp cho dropdown trong dialog
    final subjectOptionsMap = <int, Subject>{};
    for (final subject in widget.subjects) {
      final id = subject.subjectId;
      if (id != null && !subjectOptionsMap.containsKey(id)) {
        subjectOptionsMap[id] = subject;
      }
    }
    final subjectOptions = subjectOptionsMap.values.toList();

    final classOptionsMap = <int, StudentClass>{};
    for (final cls in widget.classes) {
      final id = cls.classId;
      if (id != null && !classOptionsMap.containsKey(id)) {
        classOptionsMap[id] = cls;
      }
    }
    final classOptions = classOptionsMap.values.toList();

    final lecturerOptionsMap = <int, Lecturer>{};
    for (final lecturer in widget.lecturers) {
      final id = lecturer.id;
      if (!lecturerOptionsMap.containsKey(id)) {
        lecturerOptionsMap[id] = lecturer;
      }
    }
    final lecturerOptions = lecturerOptionsMap.values.toList();

    // Kiểm tra data đã sẵn sàng chưa
    final hasData = subjectOptions.isNotEmpty &&
        classOptions.isNotEmpty &&
        lecturerOptions.isNotEmpty;

    return AlertDialog(
      title: Text(isEditing ? 'Chỉnh sửa phân công' : 'Thêm phân công'),
      content: SizedBox(
        width: 500,
        height: 450, // Thêm chiều cao cố định
        child: !hasData
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Form(
        key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _semesterController,
                  decoration: const InputDecoration(
                    labelText: 'Học kỳ (tuỳ chọn)',
                    hintText: 'Ví dụ: HK1-2024',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  key: ValueKey('dialog_subject_${subjectOptions.length}'),
                  value: _selectedSubjectId != null &&
                          subjectOptions.any(
                            (s) => s.subjectId == _selectedSubjectId,
                          )
                      ? _selectedSubjectId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Môn học',
                    border: OutlineInputBorder(),
                  ),
                  items: subjectOptions.map((subject) {
                    return DropdownMenuItem<int?>(
                      value: subject.subjectId,
                      child: Text(
                        '${subject.subjectCode} - ${subject.subjectName}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn môn học';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  key: ValueKey('dialog_class_${classOptions.length}'),
                  value: _selectedClassId != null &&
                          classOptions.any(
                            (c) => c.classId == _selectedClassId,
                          )
                      ? _selectedClassId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Lớp học',
                    border: OutlineInputBorder(),
                  ),
                  items: classOptions.map((studentClass) {
                    return DropdownMenuItem<int?>(
                      value: studentClass.classId,
                      child: Text(
                        '${studentClass.classCode} - ${studentClass.className}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn lớp học';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  key: ValueKey('dialog_lecturer_${lecturerOptions.length}'),
                  value: _selectedLecturerId != null &&
                          lecturerOptions.any(
                            (l) => l.id == _selectedLecturerId,
                          )
                      ? _selectedLecturerId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Giảng viên',
                    border: OutlineInputBorder(),
                  ),
                  items: lecturerOptions.map((lecturer) {
                    return DropdownMenuItem<int?>(
                      value: lecturer.id,
                      child: Text(
                        '${lecturer.lecturerCode ?? ''} - ${lecturer.fullName}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLecturerId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn giảng viên';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: !hasData
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ]
          : [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final assignment = Assignment(
                assignmentId: widget.assignment?.assignmentId,
                semester: _semesterController.text.isNotEmpty
                    ? _semesterController.text
                    : null,
                subjectId: _selectedSubjectId!,
                classId: _selectedClassId!,
                lecturerId: _selectedLecturerId!,
              );
              Navigator.pop(context, assignment);
            }
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }
}
