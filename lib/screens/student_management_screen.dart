import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/pagination_controls.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  late Future<List<Student>> _studentsFuture;
  final ApiService _apiService = ApiService();

  // Pagination
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [5, 10, 25, 50];

  // Bộ lọc
  int? _selectedClassId;
  List<Student> _allStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final token = context.read<AuthService>().token;
      if (token == null) {
        print('ERROR: Không có token xác thực');
        setState(() {
          _studentsFuture = Future.error('Không có token xác thực');
        });
        return;
      }

      print('Loading students with token...');
      setState(() {
        _currentPage = 0;
        _studentsFuture = _apiService
            .getStudents(token)
            .then((students) {
              print('Loaded ${students.length} students from API');
              _allStudents = students;
              return _applyFilter(students);
            })
            .catchError((error) {
              print('ERROR loading students: $error');
              throw error;
            });
      });
    } catch (e) {
      print('EXCEPTION in _loadStudents: $e');
      setState(() {
        _studentsFuture = Future.error('Lỗi tải danh sách sinh viên: $e');
      });
    }
  }

  List<Student> _applyFilter(List<Student> students) {
    if (_selectedClassId == null) {
      return students;
    }
    return students.where((s) => s.classId == _selectedClassId).toList();
  }

  void _filterStudents() {
    setState(() {
      _currentPage = 0;
      _studentsFuture = Future.value(_applyFilter(_allStudents));
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedClassId = null;
      _currentPage = 0;
      _studentsFuture = Future.value(_allStudents);
    });
  }

  List<Student> _getPaginatedStudents(List<Student> students) {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, students.length);
    return students.sublist(startIndex, endIndex);
  }

  Future<void> _showEditDialog(Student student) async {
    final formKey = GlobalKey<FormState>();
    String studentCode = student.studentCode;
    String fullName = student.fullName;
    int? selectedClassId = student.classId;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin sinh viên'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: studentCode,
                    decoration: InputDecoration(
                      labelText: 'Mã sinh viên',
                      hintText: 'Ví dụ: SV63TH100',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.badge),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mã sinh viên';
                      }
                      return null;
                    },
                    onSaved: (value) => studentCode = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: fullName,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      hintText: 'Nhập đầy đủ họ tên',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                    onSaved: (value) => fullName = value!,
                  ),
                  const SizedBox(height: 16),
                  // Dropdown chọn lớp (có thể thay đổi)
                  FutureBuilder<List<dynamic>>(
                    future: _apiService.getStudentClasses(
                      context.read<AuthService>().token ?? '',
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }
                      final classList = snapshot.data!;
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Lớp',
                          prefixIcon: Icon(Icons.class_),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        value: selectedClassId,
                        items: classList.map((cls) {
                          return DropdownMenuItem<int>(
                            value: cls.classId,
                            child: Text('${cls.classCode} - ${cls.className}'),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn lớp';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value != null) {
                            selectedClassId = value;
                          }
                        },
                      );
                    },
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
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

                try {
                  // Validate data before sending
                  if (studentCode.trim().isEmpty || fullName.trim().isEmpty) {
                    throw Exception('Các trường không được để trống');
                  }

                  if (selectedClassId == null) {
                    throw Exception('Vui lòng chọn lớp');
                  }

                  // Gửi đầy đủ 3 field như API yêu cầu
                  final requestBody = {
                    'studentCode': studentCode.trim(),
                    'fullName': fullName.trim(),
                    'classId': selectedClassId, // Lớp đã chọn (có thể thay đổi)
                  };

                  print('Updating student ${student.id}: $requestBody');
                  await _apiService.updateStudent(
                    token,
                    student.id,
                    requestBody,
                  );

                  if (!mounted) return; // Check if widget is still mounted

                  Navigator.pop(context);
                  await _loadStudents(); // Refresh data
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật thành công'),
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
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Student student) async {
    // Kiểm tra ID hợp lệ
    if (student.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể xóa: Sinh viên không có ID hợp lệ (ID: ${student.id})',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa sinh viên ${student.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = context.read<AuthService>().token;
              if (token != null) {
                try {
                  print('Deleting student with ID: ${student.id}');
                  await _apiService.deleteStudent(token, student.id);
                  Navigator.pop(context);
                  _loadStudents(); // Refresh data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    String studentCode = '';
    String fullName = '';
    int? selectedClassId;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sinh viên mới'),
        content: SizedBox(
          width: 500, // Fixed width giống lecturer dialog
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mã sinh viên',
                      hintText: 'Ví dụ: SV63TH100',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.badge),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mã sinh viên';
                      }
                      return null;
                    },
                    onSaved: (value) => studentCode = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      hintText: 'Nhập đầy đủ họ tên',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                    onSaved: (value) => fullName = value!,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<dynamic>>(
                    future: _apiService.getStudentClasses(
                      context.read<AuthService>().token ?? '',
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }
                      final classList = snapshot.data!;
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Lớp',
                          prefixIcon: Icon(Icons.class_),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items: classList.map((cls) {
                          return DropdownMenuItem<int>(
                            value: cls.classId,
                            child: Text('${cls.classCode} - ${cls.className}'),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn lớp';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          selectedClassId = value;
                        },
                      );
                    },
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
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

                try {
                  if (selectedClassId == null) {
                    throw Exception('Vui lòng chọn lớp');
                  }

                  // Đúng theo API schema: chỉ 3 field
                  final requestBody = {
                    'studentCode': studentCode.trim(),
                    'fullName': fullName.trim(),
                    'classId': selectedClassId,
                  };

                  print('Creating student: $requestBody');
                  await _apiService.createStudent(token, requestBody);

                  if (!mounted) return;

                  Navigator.pop(context);
                  await _loadStudents(); // Refresh data

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thêm sinh viên thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
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
              FutureBuilder<List<Student>>(
                future: _studentsFuture,
                builder: (context, snapshot) {
                  final totalStudents = snapshot.hasData
                      ? snapshot.data!.length
                      : 0;
                  return Text(
                    'Quản lý Sinh viên ($totalStudents sinh viên)',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                },
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadStudents,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm Sinh viên'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bộ lọc
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.blue),
                    const SizedBox(width: 10),
                    const Text(
                      'Lọc:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    // Dropdown lọc theo lớp
                    FutureBuilder<List<dynamic>>(
                      future: _apiService.getStudentClasses(
                        context.read<AuthService>().token ?? '',
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                            width: 250,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final classes = snapshot.data!;
                        return SizedBox(
                          width: 250,
                          child: DropdownButtonFormField<int>(
                            value: _selectedClassId,
                            isExpanded:
                                true, // Cho phép text expand trong dropdown
                            decoration: const InputDecoration(
                              labelText: 'Lớp học',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Tất cả lớp'),
                              ),
                              ...classes.map(
                                (cls) => DropdownMenuItem<int>(
                                  value: cls.classId,
                                  child: Text(
                                    '${cls.classCode} - ${cls.className}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedClassId = value;
                              });
                              _filterStudents();
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    if (_selectedClassId != null)
                      TextButton.icon(
                        onPressed: _clearFilter,
                        icon: const Icon(Icons.clear),
                        label: const Text('Xóa lọc'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Student>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Đang tải danh sách sinh viên...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadStudents,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('Không có sinh viên nào'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showCreateDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm sinh viên đầu tiên'),
                        ),
                      ],
                    ),
                  );
                }

                final students = snapshot.data!;
                final paginatedStudents = _getPaginatedStudents(students);

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Card(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              columns: const [
                                DataColumn(label: Text('STT')),
                                DataColumn(label: Text('Mã SV')),
                                DataColumn(label: Text('Họ và tên')),
                                DataColumn(label: Text('Lớp')),
                                DataColumn(label: Text('Thao tác')),
                              ],
                              rows: List<DataRow>.generate(
                                paginatedStudents.length,
                                (index) {
                                  final globalIndex =
                                      _currentPage * _rowsPerPage + index;
                                  final student = paginatedStudents[index];
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${globalIndex + 1}')),
                                      DataCell(Text(student.studentCode)),
                                      DataCell(Text(student.fullName)),
                                      DataCell(Text(student.className)),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () =>
                                                  _showEditDialog(student),
                                              color: Colors.blue,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () =>
                                                  _showDeleteConfirmation(
                                                    student,
                                                  ),
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    PaginationControls(
                      currentPage: _currentPage,
                      totalItems: students.length,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
