import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/semester.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _showSummary = false;
  final ApiService _apiService = ApiService();

  List<Semester> _semesters = [];
  List<FilterItem> _subjects = [];
  List<FilterItem> _lecturers = [];
  List<FilterItem> _departments = [];
  List<FilterItem> _classes = [];
  bool _isLoading = true;

  // Lưu danh sách ban đầu để có thể lọc lại
  List<FilterItem> _initialLecturers = [];
  List<FilterItem> _allSubjects = []; // Lưu tất cả môn học để lọc theo khoa
  Map<int, String> _subjectDepartments = {}; // Map subjectId -> departmentName

  // Thêm biến cho năm học
  List<String> _academicYears = [];
  String? _selectedAcademicYear;

  int? _selectedSemesterId;
  int? _selectedSubjectId;
  int? _selectedLecturerId;
  String? _selectedDepartmentName;
  int? _selectedClassId;

  int _absentPeriods = 0;
  int _makeupPeriods = 0;
  double _completionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final userRole = authService.userRole;

    if (token == null) return;

    setState(() => _isLoading = true);

    try {
      print('📊 Starting to load filter data...');
      print('👤 User role: $userRole');

      final results = await Future.wait([
        _apiService.getSemesters(token),
        _apiService.getSubjects(token),
        _apiService.getLecturers(token),
        _apiService.getDepartments(token),
        _apiService.getClasses(token),
      ]);

      final semesters = results[0] as List<Semester>;
      var subjects = results[1] as List<FilterItem>;
      var lecturers = results[2] as List<FilterItem>;
      var departments = results[3] as List<FilterItem>;
      final classes = results[4] as List<FilterItem>;

      print('📊 Loaded data:');
      print('   - Semesters: ${semesters.length}');
      print('   - Subjects: ${subjects.length}');
      print('   - Lecturers: ${lecturers.length}');
      print('   - Departments: ${departments.length}');
      print('   - Classes: ${classes.length}');

      // Lấy thông tin khoa của Manager từ profile
      String? managerDepartment;
      int? managerDepartmentId;

      if (userRole == 'ROLE_MANAGER') {
        try {
          print('🔍 Loading manager profile to get department...');
          final lecturerId = authService.userId;
          if (lecturerId != null) {
            // ĐÚNG: Dùng endpoint /api/lecturers/{id} theo Swagger
            print('� Loading profile by ID: $lecturerId');
            final profileData =
                await _apiService.get('api/lecturers/$lecturerId', token: token)
                    as Map<String, dynamic>;
            managerDepartment = profileData['departmentName'];
            managerDepartmentId = profileData['departmentId'];
            print(
              '✅ Manager department: $managerDepartment (ID: $managerDepartmentId)',
            );
          } else {
            print('⚠️ No lecturer ID found in auth service');
          }
        } catch (e) {
          print('⚠️ Could not load manager profile: $e');
        }

        // Lọc departments - Manager chỉ thấy khoa của mình
        if (managerDepartment != null) {
          departments = departments
              .where((dept) => dept.name == managerDepartment)
              .toList();
          print(
            '🔒 Filtered to manager department only: ${departments.length} department(s)',
          );

          // Tự động chọn khoa của Manager
          if (departments.isNotEmpty) {
            _selectedDepartmentName = departments.first.name;
            print('✅ Auto-selected department: $_selectedDepartmentName');
          }
        }

        // Lọc lecturers - Manager chỉ thấy giảng viên trong khoa
        if (managerDepartment != null) {
          try {
            print('🔍 Loading all lecturers with department info...');
            final allLecturersData =
                await _apiService.get('api/lecturers', token: token) as List;

            print('📊 Total lecturers from API: ${allLecturersData.length}');

            // Lọc theo department
            final filteredLecturersData = allLecturersData.where((lecturer) {
              final deptName =
                  lecturer['departmentName'] ?? lecturer['department_name'];
              final deptId =
                  lecturer['departmentId'] ?? lecturer['department_id'];
              return deptName == managerDepartment ||
                  (managerDepartmentId != null &&
                      deptId == managerDepartmentId);
            }).toList();

            print(
              '🔒 Filtered lecturers by department: ${filteredLecturersData.length}',
            );

            // Convert sang FilterItem
            var filteredLecturers = <FilterItem>[];
            for (var json in filteredLecturersData) {
              int parsedId;
              final idValue =
                  json['lecturerId'] ?? json['lecturer_id'] ?? json['id'];
              if (idValue == null) {
                parsedId = 0;
              } else if (idValue is int) {
                parsedId = idValue;
              } else if (idValue is String) {
                parsedId = int.tryParse(idValue) ?? 0;
              } else {
                parsedId = 0;
              }

              final nameValue =
                  json['fullName'] ?? json['full_name'] ?? json['name'];

              if (parsedId != 0 && nameValue != null) {
                filteredLecturers.add(
                  FilterItem(id: parsedId, name: nameValue.toString()),
                );
              }
            }

            lecturers = filteredLecturers;
            _initialLecturers = List.from(filteredLecturers); // Lưu để fallback
            print('✅ Final filtered lecturers: ${lecturers.length}');
          } catch (e) {
            print('⚠️ Could not filter lecturers: $e');
            // Giữ nguyên lecturers ban đầu nếu lỗi
          }
        }

        // Lọc subjects theo departmentName của Manager
        if (managerDepartment != null) {
          try {
            print('🔍 Filtering subjects by department: $managerDepartment...');

            // Re-fetch subjects with full data để lấy departmentName
            final subjectsFullData =
                await _apiService.get('api/subjects', token: token) as List;
            print(
              '📦 Fetched ${subjectsFullData.length} subjects with full data',
            );

            // Filter subjects có departmentName khớp với Manager's department
            var filteredSubjects = <FilterItem>[];
            for (var json in subjectsFullData) {
              final deptName =
                  json['departmentName'] ?? json['department_name'];
              if (deptName == managerDepartment) {
                int parsedId;
                final idValue =
                    json['subjectId'] ?? json['subject_id'] ?? json['id'];
                if (idValue == null) {
                  parsedId = 0;
                } else if (idValue is int) {
                  parsedId = idValue;
                } else if (idValue is String) {
                  parsedId = int.tryParse(idValue) ?? 0;
                } else {
                  parsedId = 0;
                }

                final nameValue =
                    json['subjectName'] ?? json['subject_name'] ?? json['name'];

                filteredSubjects.add(
                  FilterItem(
                    id: parsedId,
                    name: nameValue?.toString() ?? 'Unknown',
                  ),
                );
              }
            }

            subjects = filteredSubjects;
            print(
              '✅ Filtered subjects by department "$managerDepartment": ${subjects.length}',
            );
          } catch (e) {
            print('⚠️ Could not filter subjects: $e');
            // Giữ nguyên subjects nếu lỗi
          }
        }
      } else {
        print('✅ Admin - showing all departments, lecturers, and subjects');
      }

      setState(() {
        _semesters = semesters;
        _subjects = subjects;
        _lecturers = lecturers;
        _departments = departments;
        _classes = classes;

        // Tách danh sách năm học từ semesters
        _academicYears =
            semesters
                .map((s) => s.academicYear)
                .where((year) => year != null)
                .cast<String>()
                .toSet()
                .toList()
              ..sort((a, b) => b.compareTo(a)); // Sắp xếp mới nhất lên đầu

        _isLoading = false;
      });

      // Hiển thị thông báo nếu không có dữ liệu
      if (semesters.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không có dữ liệu học kỳ. Vui lòng liên hệ quản trị viên.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error loading filter data: $e');
      print('Stack trace: $stackTrace');

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Load subjects khi chọn semester
  Future<void> _loadDataForSemester(int semesterId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final userRole = authService.userRole;
    if (token == null) return;

    print('📊 Loading subjects for semester: $semesterId');

    try {
      // Gọi API /api/reports/subjects để lấy môn học theo semester
      final subjectsData =
          await _apiService.get(
                'api/reports/subjects?semesterId=$semesterId',
                token: token,
              )
              as List;

      print('📦 Raw subjects response: $subjectsData');

      if (subjectsData.isEmpty) {
        print(
          '⚠️ API returned empty subjects - backend may not have assignments data',
        );
        print(
          '🔄 Fallback: Using subjects filtered by department from initial load',
        );

        // FALLBACK: Nếu API trả về rỗng, giữ nguyên _subjects đã được filter
        // trong _fetchInitialData (đã lọc theo department của Manager)
        setState(() {
          _selectedSubjectId = null;
          _selectedLecturerId = null;
          _selectedClassId = null;
          _lecturers = [];
          _classes = [];
        });
        return;
      }

      // Parse theo SubjectDTO: {id, subjectCode, subjectName, credits, theoryPeriods, practicePeriods, departmentId, departmentName}
      var subjects = subjectsData.map((json) {
        final id = json['id'];
        final subjectName = json['subjectName'];
        final departmentName = json['departmentName'];

        // Lưu mapping subjectId -> departmentName
        final subjectId = id is int ? id : (int.tryParse(id.toString()) ?? 0);
        if (departmentName != null) {
          _subjectDepartments[subjectId] = departmentName.toString();
        }

        return FilterItem(
          id: subjectId,
          name: subjectName?.toString() ?? 'Unknown',
        );
      }).toList();

      // Lưu tất cả môn học (chưa lọc) để Admin có thể lọc theo khoa sau
      _allSubjects = List.from(subjects);

      // MANAGER: Lọc thêm theo department (double-check)
      if (userRole == 'ROLE_MANAGER' && _selectedDepartmentName != null) {
        print('🔒 Manager mode: filtering subjects by department...');

        // Lấy lại subjectsData với departmentName để lọc
        final subjectsFullData =
            await _apiService.get('api/subjects', token: token) as List;

        // Chỉ giữ các subject có departmentName khớp với khoa của Manager
        final subjectIdsInDepartment = <int>{};
        for (var json in subjectsFullData) {
          final deptName = json['departmentName'] ?? json['department_name'];
          if (deptName == _selectedDepartmentName) {
            final subjectId =
                json['id'] ?? json['subjectId'] ?? json['subject_id'];
            if (subjectId != null) {
              subjectIdsInDepartment.add(
                subjectId is int
                    ? subjectId
                    : int.tryParse(subjectId.toString()) ?? 0,
              );
            }
          }
        }

        // Lọc subjects theo IDs của khoa
        subjects = subjects
            .where((s) => subjectIdsInDepartment.contains(s.id))
            .toList();
        print('✅ Filtered to ${subjects.length} subjects in department');
      }

      print('✅ Loaded ${subjects.length} subjects from reports API');

      setState(() {
        _subjects = subjects;
        _selectedSubjectId = null;
        _selectedLecturerId = null;
        _selectedClassId = null;
        _lecturers = [];
        _classes = [];
      });
    } catch (e) {
      print('❌ Error loading subjects: $e');
      print('🔄 Fallback: Using subjects filtered by department');

      // FALLBACK: Giữ nguyên subjects đã filter
      setState(() {
        _selectedSubjectId = null;
        _selectedLecturerId = null;
        _selectedClassId = null;
        _lecturers = [];
        _classes = [];
      });
    }
  }

  // Lọc môn học theo khoa (cho Admin)
  void _filterSubjectsByDepartment(String? departmentName) {
    if (departmentName == null || departmentName.isEmpty) {
      // Nếu không chọn khoa, hiển thị tất cả môn học
      setState(() {
        _subjects = List.from(_allSubjects);
      });
      print(
        '🔓 Showing all ${_subjects.length} subjects (no department filter)',
      );
    } else {
      // Lọc môn học theo departmentName
      final filteredSubjects = _allSubjects.where((subject) {
        final subjectDept = _subjectDepartments[subject.id];
        return subjectDept == departmentName;
      }).toList();

      setState(() {
        _subjects = filteredSubjects;
      });
      print(
        '🔒 Filtered to ${_subjects.length} subjects in department: $departmentName',
      );
    }
  }

  // Load lecturers khi chọn subject
  Future<void> _loadLecturersForSubject(int subjectId) async {
    if (_selectedSemesterId == null) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) return;

    try {
      print(
        '👥 Loading lecturers for subject: $subjectId, semester: $_selectedSemesterId',
      );

      final lecturersData =
          await _apiService.get(
                'api/reports/lecturers?semesterId=$_selectedSemesterId&subjectId=$subjectId',
                token: token,
              )
              as List;

      print('📦 Raw lecturers response: $lecturersData');

      // Parse theo LecturerDTO: {lecturerId, lecturerCode, fullName, email, role, departmentId, departmentName}
      var lecturers = lecturersData.map((json) {
        final lecturerId = json['lecturerId'];
        final fullName = json['fullName'];

        return FilterItem(
          id: lecturerId is int
              ? lecturerId
              : (int.tryParse(lecturerId.toString()) ?? 0),
          name: fullName?.toString() ?? 'Unknown',
        );
      }).toList();

      print('✅ Loaded ${lecturers.length} lecturers for subject $subjectId');

      // FALLBACK: Nếu không có lecturers từ API reports, dùng lecturers đã filter theo department
      if (lecturers.isEmpty && _initialLecturers.isNotEmpty) {
        print(
          '⚠️ No lecturers from reports API, using department-filtered lecturers (${_initialLecturers.length})',
        );
        lecturers = List.from(
          _initialLecturers,
        ); // Sử dụng danh sách lecturers ban đầu
      }

      setState(() {
        _lecturers = lecturers;
        _selectedLecturerId = null;
        _selectedClassId = null;
      });
    } catch (e) {
      print('❌ Error loading lecturers: $e');
      // Giữ nguyên lecturers hiện tại nếu có lỗi
      setState(() {
        _selectedLecturerId = null;
        _selectedClassId = null;
      });
    }
  }

  // Load classes khi chọn lecturer
  Future<void> _loadClassesForLecturer(int lecturerId) async {
    if (_selectedSemesterId == null || _selectedSubjectId == null) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) return;

    try {
      print(
        '🏫 Loading classes for lecturer: $lecturerId, subject: $_selectedSubjectId, semester: $_selectedSemesterId',
      );

      // Try API reports/classes first
      try {
        final classesData =
            await _apiService.get(
                  'api/reports/classes?semesterId=$_selectedSemesterId&subjectId=$_selectedSubjectId&lecturerId=$lecturerId',
                  token: token,
                )
                as List;

        print('📦 Raw classes response: $classesData');

        // Parse theo format mới: {classId, classCode, className, semester}
        final classes = classesData.map((json) {
          final classId = json['classId'];
          final className = json['className'];

          return FilterItem(
            id: classId is int
                ? classId
                : (int.tryParse(classId.toString()) ?? 0),
            name: className?.toString() ?? 'Unknown',
          );
        }).toList();

        print(
          '✅ Loaded ${classes.length} classes from API for lecturer $lecturerId',
        );

        setState(() {
          _classes = classes;
          _selectedClassId = null;
        });
      } catch (apiError) {
        print('⚠️ API reports/classes failed: $apiError');
        print('🔄 Fallback: Loading classes from lecturer schedules...');

        // FALLBACK: Load classes from lecturer's schedule
        // Find lecturer email from _initialLecturers
        final lecturer = _initialLecturers.firstWhere(
          (l) => l.id == lecturerId,
          orElse: () => FilterItem(id: 0, name: ''),
        );

        if (lecturer.id == 0) {
          throw Exception('Lecturer not found with ID: $lecturerId');
        }

        // Get lecturer details to find email
        final lecturerData =
            await _apiService.get('api/lecturers/$lecturerId', token: token)
                as Map<String, dynamic>;

        final lecturerEmail = lecturerData['email'] as String?;
        if (lecturerEmail == null) {
          throw Exception('Lecturer email not found');
        }

        print('📧 Fetching schedules for: $lecturerEmail');

        // Get lecturer's schedule
        final scheduleData =
            await _apiService.get(
                  'api/schedules/lecturer/$lecturerEmail',
                  token: token,
                )
                as List;

        print('📅 Got ${scheduleData.length} sessions from schedule');

        // Extract unique classes from schedule for selected subject and semester
        final Set<String> uniqueClassNames = {};

        // Tìm semester để lấy thông tin ngày
        final semester = _semesters.firstWhere(
          (s) => s.semesterId == _selectedSemesterId,
        );

        // Tìm subject để lấy tên môn học
        final selectedSubject = _subjects.firstWhere(
          (s) => s.id == _selectedSubjectId,
        );

        print(
          '📆 Semester dates: ${semester.startDate} to ${semester.endDate}',
        );
        print('📚 Looking for subject: ${selectedSubject.name}');

        for (var session in scheduleData) {
          final sessionSubjectName = session['subjectName'] as String?;
          final sessionDate = session['sessionDate'] as String?;
          final className = session['className'] as String?;

          if (className != null &&
              sessionSubjectName != null &&
              sessionDate != null) {
            print(
              '🔍 Checking session: $className - $sessionSubjectName - $sessionDate',
            );

            // Check if subject matches
            if (sessionSubjectName == selectedSubject.name) {
              // Check if session is in selected semester
              final sessionDateTime = DateTime.parse(sessionDate);

              final isInSemester =
                  (semester.startDate == null ||
                      sessionDateTime.isAfter(semester.startDate!) ||
                      sessionDateTime.isAtSameMomentAs(semester.startDate!)) &&
                  (semester.endDate == null ||
                      sessionDateTime.isBefore(semester.endDate!) ||
                      sessionDateTime.isAtSameMomentAs(semester.endDate!));

              print('   ✓ Subject match! In semester: $isInSemester');

              if (isInSemester) {
                uniqueClassNames.add(className);
                print('   ✅ Added class: $className');
              }
            }
          }
        }

        print(
          '✅ Found ${uniqueClassNames.length} unique classes from schedule',
        );

        final classes = uniqueClassNames
            .map(
              (name) => FilterItem(
                id: uniqueClassNames.toList().indexOf(name) + 1,
                name: name,
              ),
            )
            .toList();

        setState(() {
          _classes = classes;
          _selectedClassId = null;
        });
      }
    } catch (e) {
      print('❌ Error loading classes: $e');
      setState(() {
        _classes = [];
        _selectedClassId = null;
      });
    }
  }

  // Kiểm tra xem đã chọn đủ thông tin để tạo báo cáo chưa
  bool _canGenerateReport() {
    // Bắt buộc phải chọn: năm học, kỳ học, môn học, giảng viên VÀ lớp
    return _selectedAcademicYear != null &&
        _selectedSemesterId != null &&
        _selectedSubjectId != null &&
        _selectedLecturerId != null &&
        _selectedClassId != null;
  }

  // Lấy danh sách kỳ học theo năm học đã chọn
  List<Semester> get _filteredSemesters {
    if (_selectedAcademicYear == null) return [];
    return _semesters
        .where((s) => s.academicYear == _selectedAcademicYear)
        .toList();
  }

  Future<void> _generateReport() async {
    // Validate: Phải chọn đủ tất cả thông tin
    if (!_canGenerateReport()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng chọn đầy đủ: Năm học, Kỳ học, Môn học, Giảng viên và Lớp!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;

    setState(() {
      _showSummary = false;
      _absentPeriods = 0;
      _makeupPeriods = 0;
      _completionRate = 0.0;
    });

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
                  Text('Đang tạo báo cáo...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      // Gọi trực tiếp API báo cáo với các tham số đã chọn
      print(
        '🔍 Generating report for: semesterId=$_selectedSemesterId, subjectId=$_selectedSubjectId, lecturerId=$_selectedLecturerId, classId=$_selectedClassId',
      );

      final reportData =
          await _apiService.get(
                'api/reports/lecturer-activity?semesterId=$_selectedSemesterId&subjectId=$_selectedSubjectId&lecturerId=$_selectedLecturerId&classId=$_selectedClassId',
                token: token,
              )
              as Map<String, dynamic>;

      if (mounted) Navigator.of(context).pop();

      print('📊 Report data: $reportData');

      // Lưu assignmentId từ response (không dùng nữa, chỉ log)
      final assignmentId = reportData['assignmentId'] as int?;
      print('📌 Assignment ID from response: $assignmentId');

      // ĐẾM THỰC TẾ TỪ SCHEDULES thay vì tin vào backend
      final schedules = reportData['schedules'] as List? ?? [];
      final plannedPeriods =
          reportData['plannedPeriods'] as Map<String, dynamic>?;
      final totalPlanned = plannedPeriods?['total'] as int? ?? 0;

      // Đếm số TIẾT đã dạy THỰC TẾ từ status TAUGHT
      int actualTaughtCount = 0; // Số tiết đã dạy
      int actualMakeupCount = 0; // Số tiết dạy bù

      for (var schedule in schedules) {
        final status = schedule['status']?.toString();
        final startPeriod = schedule['startPeriod'] as int? ?? 0;
        final endPeriod = schedule['endPeriod'] as int? ?? 0;
        final periods = endPeriod - startPeriod + 1; // Số tiết của buổi này

        if (status == 'TAUGHT') {
          actualTaughtCount += periods; // Đếm số tiết
        } else if (status == 'MAKEUP_TAUGHT') {
          actualMakeupCount += periods; // Đếm số tiết dạy bù
        }
      }

      print(
        '📊 Counted from schedules: TAUGHT=$actualTaughtCount tiết, MAKEUP=$actualMakeupCount tiết',
      );

      // Tính số tiết nghỉ = tổng kế hoạch - số tiết đã dạy
      final absentPeriods = totalPlanned - actualTaughtCount;
      final makeupPeriods = actualMakeupCount;

      // Tỷ lệ hoàn thành = (tiết đã dạy + tiết bù) / tổng kế hoạch
      final completionRate = totalPlanned > 0
          ? (actualTaughtCount + actualMakeupCount) / totalPlanned * 100
          : 0.0;

      print(
        '📈 Completion rate: ${completionRate.toStringAsFixed(1)}% (${actualTaughtCount + actualMakeupCount}/$totalPlanned tiết)',
      );

      setState(() {
        _absentPeriods = absentPeriods;
        _makeupPeriods = makeupPeriods;
        _completionRate = completionRate;
        _showSummary = true;
      });
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      print('❌ Error generating report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo báo cáo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải dữ liệu...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tùy chọn báo cáo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Dropdown Năm học
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Năm học',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
              hintText: _academicYears.isEmpty
                  ? 'Không có dữ liệu'
                  : 'Chọn năm học',
            ),
            value: _selectedAcademicYear,
            items: _academicYears.isEmpty
                ? null
                : _academicYears.map((year) {
                    return DropdownMenuItem(value: year, child: Text(year));
                  }).toList(),
            onChanged: _academicYears.isEmpty
                ? null
                : (value) {
                    setState(() {
                      _selectedAcademicYear = value;
                      _selectedSemesterId =
                          null; // Reset semester khi đổi năm học
                    });
                  },
          ),
          const SizedBox(height: 16),

          // Dropdown Kỳ học (chỉ hiện khi đã chọn năm học)
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Kỳ học',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.school),
              hintText: _selectedAcademicYear == null
                  ? 'Vui lòng chọn năm học trước'
                  : (_filteredSemesters.isEmpty
                        ? 'Không có dữ liệu'
                        : 'Chọn kỳ học'),
            ),
            value: _selectedSemesterId,
            items: _selectedAcademicYear == null || _filteredSemesters.isEmpty
                ? null
                : _filteredSemesters.map((semester) {
                    return DropdownMenuItem(
                      value: semester.semesterId,
                      child: Text(semester.semesterName),
                    );
                  }).toList(),
            onChanged:
                _selectedAcademicYear == null || _filteredSemesters.isEmpty
                ? null
                : (value) {
                    setState(() => _selectedSemesterId = value);
                    // Load subjects/lecturers/classes khi chọn semester
                    if (value != null) {
                      _loadDataForSemester(value);
                    }
                  },
          ),
          const SizedBox(height: 12),

          // Hiển thị thông tin khoa cho Manager (không cho chọn)
          if (_departments.length == 1 && _selectedDepartmentName != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.business, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Khoa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDepartmentName!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock, color: Colors.grey, size: 16),
                ],
              ),
            ),

          // Dropdown Khoa cho Admin (có thể chọn nhiều khoa)
          if (_departments.length > 1)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Khoa',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
                hintText: 'Chọn khoa để lọc môn học',
              ),
              value: _selectedDepartmentName,
              items: _departments.map((dept) {
                return DropdownMenuItem(
                  value: dept.name,
                  child: Text(dept.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartmentName = value;
                  // Lọc môn học theo khoa khi Admin chọn khoa
                  _filterSubjectsByDepartment(value);
                  // Reset các selection phía sau
                  _selectedSubjectId = null;
                  _selectedLecturerId = null;
                  _selectedClassId = null;
                  _lecturers = [];
                  _classes = [];
                });
              },
            ),

          const SizedBox(height: 12),

          // Dropdown Môn học (sau Khoa)
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Môn học',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.book),
              hintText: _subjects.isEmpty
                  ? 'Không có dữ liệu'
                  : 'Chọn môn học (tùy chọn)',
            ),
            value: _selectedSubjectId,
            items: _subjects.isEmpty
                ? null
                : _subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject.id,
                      child: Text(subject.name),
                    );
                  }).toList(),
            onChanged: _subjects.isEmpty
                ? null
                : (value) {
                    setState(() => _selectedSubjectId = value);
                    // Load lecturers khi chọn subject
                    if (value != null) {
                      _loadLecturersForSubject(value);
                    }
                  },
          ),

          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Giảng viên',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              hintText: _lecturers.isEmpty
                  ? 'Không có dữ liệu'
                  : 'Chọn giảng viên (tùy chọn)',
            ),
            value: _selectedLecturerId,
            items: _lecturers.isEmpty
                ? null
                : _lecturers.map((lecturer) {
                    return DropdownMenuItem(
                      value: lecturer.id,
                      child: Text(lecturer.name),
                    );
                  }).toList(),
            onChanged: _lecturers.isEmpty
                ? null
                : (value) {
                    setState(() => _selectedLecturerId = value);
                    // Load classes khi chọn lecturer
                    if (value != null) {
                      _loadClassesForLecturer(value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Lớp',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.class_),
              hintText: _classes.isEmpty
                  ? 'Không có dữ liệu'
                  : 'Chọn lớp (tùy chọn)',
            ),
            value: _selectedClassId,
            items: _classes.isEmpty
                ? null
                : _classes.map((classItem) {
                    return DropdownMenuItem(
                      value: classItem.id,
                      child: Text(classItem.name),
                    );
                  }).toList(),
            onChanged: _classes.isEmpty
                ? null
                : (value) => setState(() => _selectedClassId = value),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _canGenerateReport() ? _generateReport : null,
              icon: const Icon(Icons.assessment),
              label: const Text('Xem báo cáo', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_showSummary) ...[
            const SizedBox(height: 24),

            // Chỉ hiển thị kết quả khi đã chọn đủ thông tin và đã tạo báo cáo
            if (_showSummary && _canGenerateReport())
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kết quả báo cáo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildReportRow(
                        'Tổng số tiết nghỉ:',
                        '$_absentPeriods tiết',
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildReportRow(
                        'Số tiết đã dạy bù:',
                        '$_makeupPeriods tiết',
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildReportRow(
                        'Tỷ lệ hoàn thành:',
                        '${_completionRate.toStringAsFixed(1)}%',
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showDetailDialog,
                          icon: const Icon(Icons.list_alt),
                          label: const Text('Xem chi tiết'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _showDetailDialog() async {
    // Sử dụng lại các tham số đã chọn thay vì assignmentId
    if (_selectedSemesterId == null ||
        _selectedSubjectId == null ||
        _selectedLecturerId == null ||
        _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có dữ liệu báo cáo chi tiết'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;

    // Show loading
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
                Text('Đang tải chi tiết...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Gọi API báo cáo chi tiết với đầy đủ tham số
      final reportData =
          await _apiService.get(
                'api/reports/lecturer-activity?semesterId=$_selectedSemesterId&subjectId=$_selectedSubjectId&lecturerId=$_selectedLecturerId&classId=$_selectedClassId',
                token: token,
              )
              as Map<String, dynamic>;

      if (mounted) Navigator.of(context).pop(); // Close loading

      final studentReports =
          (reportData['studentAttendanceReports'] as List?)
              ?.map((s) => s as Map<String, dynamic>)
              .toList() ??
          [];

      // Show dialog with detailed report
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chi tiết báo cáo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Thông tin chung
                  Text(
                    '${reportData['lecturerName']} - ${reportData['subjectName']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${reportData['className']} - ${reportData['semesterName']} (${reportData['academicYear']})',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // Thống kê tiết dạy
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thống kê tiết dạy:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kế hoạch: ${reportData['plannedPeriods']?['total'] ?? 0} tiết',
                          ),
                          Text(
                            'Đã dạy: ${reportData['taughtPeriods']?['regularTaught'] ?? 0} tiết',
                          ),
                          Text(
                            'Dạy bù: ${reportData['taughtPeriods']?['makeupTaught'] ?? 0} tiết',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Danh sách sinh viên (${studentReports.length}):',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Danh sách sinh viên
                  Expanded(
                    child: studentReports.isEmpty
                        ? const Center(
                            child: Text('Không có dữ liệu sinh viên'),
                          )
                        : ListView.builder(
                            itemCount: studentReports.length,
                            itemBuilder: (context, index) {
                              final student = studentReports[index];
                              final absencePercent =
                                  (student['absencePercentage'] as num?)
                                      ?.toDouble() ??
                                  0.0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: absencePercent > 20
                                        ? Colors.red
                                        : Colors.green,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    '${student['studentCode']} - ${student['studentName']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Có mặt: ${student['attendedSessions']}/${student['totalSessions']} buổi',
                                  ),
                                  trailing: Text(
                                    'Vắng: ${absencePercent.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: absencePercent > 20
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close loading
      print('❌ Error loading detail: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải chi tiết: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
