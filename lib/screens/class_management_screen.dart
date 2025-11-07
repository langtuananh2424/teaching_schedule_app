import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_class.dart';
import '../services/api_service.dart';
import '../widgets/pagination_controls.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  String? _selectedSemester;
  final ApiService _apiService = ApiService();
  List<StudentClass> _classes = [];
  List<StudentClass> _filteredClasses = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  // Pagination
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [5, 10, 25, 50];

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

      final classes = await _apiService.getStudentClasses(_token!);
      setState(() {
        _classes = classes;
        _filteredClasses = classes;
        _selectedSemester = null;
        _currentPage = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải danh sách lớp học: $e';
        _isLoading = false;
      });
    }
  }

  List<StudentClass> _getPaginatedClasses() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    return _filteredClasses.sublist(
      startIndex,
      endIndex > _filteredClasses.length ? _filteredClasses.length : endIndex,
    );
  }

  Future<void> _addClass() async {
    final result = await showDialog<StudentClass>(
      context: context,
      builder: (context) => const ClassDialog(),
    );

    if (result != null && _token != null) {
      try {
        await _apiService.createStudentClass(_token!, result.toJson());
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm lớp học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi thêm lớp học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editClass(StudentClass studentClass) async {
    final result = await showDialog<StudentClass>(
      context: context,
      builder: (context) => ClassDialog(studentClass: studentClass),
    );

    if (result != null && _token != null && result.classId != null) {
      try {
        await _apiService.updateStudentClass(
          _token!,
          result.classId!,
          result.toJson(),
        );
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật lớp học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật lớp học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteClass(StudentClass studentClass) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa lớp học "${studentClass.className}"?',
        ),
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

    if (confirmed == true && _token != null && studentClass.classId != null) {
      try {
        await _apiService.deleteStudentClass(_token!, studentClass.classId!);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa lớp học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa lớp học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _filterBySemester(String? semester) {
    setState(() {
      _selectedSemester = semester;
      if (semester == null) {
        _filteredClasses = _classes;
      } else {
        _filteredClasses = _classes
            .where((c) => c.semester == semester)
            .toList();
      }
      _currentPage = 0;
    });
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
          : _classes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có lớp học nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addClass,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm lớp học'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<int>(
                        future: Future.value(_classes.length),
                        builder: (context, snapshot) {
                          final totalClasses = snapshot.hasData
                              ? snapshot.data!
                              : 0;
                          return Text(
                            'Quản lý Lớp học ($totalClasses lớp)',
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
                            onPressed: _addClass,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm Lớp học'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bộ lọc học khóa
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.blue),
                      const SizedBox(width: 10),
                      const Text(
                        'Lọc:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSemester,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Học khóa',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Tất cả học khóa'),
                            ),
                            ...{..._classes.map((c) => c.semester)}.map(
                              (semester) => DropdownMenuItem<String>(
                                value: semester,
                                child: Text(semester),
                              ),
                            ),
                          ],
                          onChanged: (value) => _filterBySemester(value),
                        ),
                      ),
                      if (_selectedSemester != null)
                        TextButton.icon(
                          onPressed: () => _filterBySemester(null),
                          icon: const Icon(Icons.clear),
                          label: const Text('Xóa lọc'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Mã lớp')),
                          DataColumn(label: Text('Tên lớp')),
                          DataColumn(label: Text('Học khóa')),
                          DataColumn(label: Text('Thao tác')),
                        ],
                        rows: _getPaginatedClasses().map((studentClass) {
                          return DataRow(
                            cells: [
                              DataCell(Text(studentClass.classCode)),
                              DataCell(Text(studentClass.className)),
                              DataCell(Text(studentClass.semester)),
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
                                      onPressed: () => _editClass(studentClass),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Xóa',
                                      onPressed: () =>
                                          _deleteClass(studentClass),
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
                // Pagination controls
                PaginationControls(
                  currentPage: _currentPage,
                  totalItems: _filteredClasses.length,
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

class ClassDialog extends StatefulWidget {
  final StudentClass? studentClass;

  const ClassDialog({super.key, this.studentClass});

  @override
  State<ClassDialog> createState() => _ClassDialogState();
}

class _ClassDialogState extends State<ClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _classCodeController;
  late TextEditingController _classNameController;
  late TextEditingController _semesterController;

  @override
  void initState() {
    super.initState();
    _classCodeController = TextEditingController(
      text: widget.studentClass?.classCode ?? '',
    );
    _classNameController = TextEditingController(
      text: widget.studentClass?.className ?? '',
    );
    _semesterController = TextEditingController(
      text: widget.studentClass?.semester ?? '',
    );
  }

  @override
  void dispose() {
    _classCodeController.dispose();
    _classNameController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.studentClass != null;

    return AlertDialog(
      title: Text(isEditing ? 'Chỉnh sửa lớp học' : 'Thêm lớp học'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _classCodeController,
                decoration: const InputDecoration(
                  labelText: 'Mã lớp',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã lớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên lớp',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên lớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(
                  labelText: 'Học khóa',
                  hintText: 'Ví dụ: K65',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập học khóa';
                  }
                  return null;
                },
              ),
            ],
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
              final studentClass = StudentClass(
                classId: widget.studentClass?.classId,
                classCode: _classCodeController.text,
                className: _classNameController.text,
                semester: _semesterController.text,
              );
              Navigator.pop(context, studentClass);
            }
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }
}
