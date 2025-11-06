import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/constants.dart';
import '../models/session.dart';
import '../models/absence_request.dart';
import '../models/makeup_session.dart';
import '../models/attendance.dart';
import '../models/semester.dart';
import '../models/student.dart';

class DashboardSummary {
  final int pendingAbsenceCount;
  final int pendingMakeupCount;
  final List<dynamic> recentRequests;

  DashboardSummary({
    required this.pendingAbsenceCount,
    required this.pendingMakeupCount,
    required this.recentRequests,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      pendingAbsenceCount: json['pendingAbsenceCount'] ?? 0,
      pendingMakeupCount: json['pendingMakeupCount'] ?? 0,
      recentRequests: (json['recentRequests'] as List? ?? [])
          .map(
            (req) => req['type'] == 'absence'
                ? AbsenceRequest.fromJson(req)
                : MakeupSession.fromJson(req),
          )
          .toList(),
    );
  }
}

class FilterItem {
  final int id;
  final String name;
  FilterItem({required this.id, required this.name});

  factory FilterItem.fromJson(
    Map<String, dynamic> json, {
    String idKey = 'id',
    String nameKey = 'name',
  }) {
    // Xử lý id có thể null hoặc string
    int parsedId;
    if (json[idKey] == null) {
      parsedId = 0;
    } else if (json[idKey] is int) {
      parsedId = json[idKey];
    } else if (json[idKey] is String) {
      parsedId = int.tryParse(json[idKey]) ?? 0;
    } else {
      parsedId = 0;
    }

    // Xử lý name có thể null
    String parsedName = json[nameKey]?.toString() ?? 'Unknown';

    return FilterItem(id: parsedId, name: parsedName);
  }
}

class ApiService {
  final String _baseUrl = AppConstants.baseUrl;

  Future<dynamic> get(String endpoint, {String? token}) async {
    final fullUrl = '$_baseUrl/$endpoint';
    print('🌐 GET Request: $fullUrl');
    if (token != null) {
      print('🔑 With token: ${token.substring(0, 20)}...');
    }

    final response = await http.get(
      Uri.parse(fullUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('📡 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      print(
        '✅ Response data: ${decoded.toString().substring(0, decoded.toString().length > 200 ? 200 : decoded.toString().length)}...',
      );
      return decoded;
    } else {
      throw Exception('Failed to load data: ${response.body}');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    String? token,
    dynamic body, // Cho phép Map hoặc List
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      // Parse error response để log chi tiết
      print('❌ POST Error - Status: ${response.statusCode}');
      print('❌ Response Body: ${response.body}');

      try {
        final errorJson = jsonDecode(response.body);
        print('❌ Parsed Error: $errorJson');

        // Nếu có message từ backend, dùng nó
        if (errorJson['message'] != null) {
          throw Exception(errorJson['message']);
        } else if (errorJson['error'] != null) {
          throw Exception(errorJson['error']);
        }
      } catch (e) {
        // Nếu không parse được JSON, dùng response.body
        print('⚠️ Could not parse error JSON: $e');
      }

      throw Exception('Failed to post data: ${response.body}');
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    print('🌐 PATCH Request: $_baseUrl/$endpoint');
    print('📦 Body: $body');

    final response = await http.patch(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    print('📡 PATCH Response Status: ${response.statusCode}');
    print('📡 PATCH Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      // Parse error response để log chi tiết
      print('❌ PATCH Error - Status: ${response.statusCode}');

      try {
        final errorJson = jsonDecode(response.body);
        print('❌ Parsed Error: $errorJson');

        // Nếu có message từ backend, dùng nó
        if (errorJson['message'] != null) {
          throw Exception(errorJson['message']);
        } else if (errorJson['error'] != null) {
          throw Exception(errorJson['error']);
        }
      } catch (e) {
        print('⚠️ Could not parse error JSON: $e');
      }

      throw Exception('Failed to patch data: ${response.body}');
    }
  }

  // ========== LECTURER SCHEDULE ==========
  Future<List<Session>> getSessions(String token, String email) async {
    // Theo Swagger thực tế: GET /api/schedules/lecturer/{email}
    final String endpoint = 'api/schedules/lecturer/$email';

    print('🌐 API Request: GET $_baseUrl/$endpoint');
    print('📧 Email: $email');

    try {
      final response = await get(endpoint, token: token) as List;
      print('✅ API Response: ${response.length} sessions');
      final sessions = response.map((json) => Session.fromJson(json)).toList();
      print('📅 Sessions dates:');
      for (var s in sessions) {
        print(
          '   - ${s.subjectName}: ${DateFormat('dd/MM/yyyy').format(s.sessionDate)}',
        );
      }
      return sessions;
    } catch (e) {
      print('❌ API /api/schedules/lecturer/$email lỗi: $e');
      rethrow; // Throw lỗi thay vì dùng mock data
    }
  }

  // ========== MANAGER DASHBOARD ==========
  Future<DashboardSummary> getDashboardSummary(String token) async {
    final response = await get('api/manager/dashboard-summary', token: token);
    return DashboardSummary.fromJson(response);
  }

  // ========== FILTERS ==========
  Future<List<Semester>> getSemesters(String token) async {
    try {
      // Theo swagger thực tế: GET /api/semesters?academicYear={year} (BẮT BUỘC)
      // Lấy semesters của năm hiện tại trước
      final currentYear = DateTime.now().year;
      final academicYear = '$currentYear-${currentYear + 1}';

      print('🔍 Loading semesters for academic year: $academicYear');
      final response =
          await get('api/semesters?academicYear=$academicYear', token: token)
              as List;
      print('✅ Loaded ${response.length} semesters from /api/semesters');
      return response.map((json) => Semester.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ /api/semesters?academicYear=... lỗi: $e');
      print('🔄 Fallback: thử nhiều năm học...');

      try {
        // Fallback: Thử nhiều năm
        final currentYear = DateTime.now().year;
        final allSemesters = <Semester>[];

        for (int year = currentYear - 1; year <= currentYear + 1; year++) {
          try {
            final academicYear = '$year-${year + 1}';
            final response =
                await get(
                      'api/semesters?academicYear=$academicYear',
                      token: token,
                    )
                    as List;
            final semesters = response
                .map((json) => Semester.fromJson(json))
                .toList();
            allSemesters.addAll(semesters);
            print(
              '✅ Loaded ${semesters.length} semesters for year $academicYear',
            );
          } catch (e3) {
            print('⚠️ Không load được semesters cho năm $year-${year + 1}');
          }
        }

        if (allSemesters.isEmpty) {
          throw Exception('Không thể load semesters từ bất kỳ API nào');
        }

        print(
          '✅ Tổng cộng loaded ${allSemesters.length} semesters từ nhiều năm',
        );
        return allSemesters;
      } catch (e2) {
        print('❌ Fallback cũng thất bại: $e2');
        throw Exception('Không thể load semesters từ bất kỳ API nào');
      }
    }
  }

  Future<List<FilterItem>> getLecturers(String token) async {
    final response = await get('api/lecturers', token: token) as List;

    // Debug: In ra JSON đầu tiên để xem structure
    if (response.isNotEmpty) {
      print('📝 Lecturer JSON sample: ${response.first}');
      print('📝 Total lecturers from API: ${response.length}');
    }

    // Sử dụng Map để loại bỏ duplicate lecturer_id
    final Map<int, FilterItem> lecturerMap = {};

    int skippedCount = 0;
    for (var json in response) {
      // Kiểm tra role - CHỈ lấy ROLE_LECTURER
      final role = json['role'] ?? json['roles'] ?? json['userRole'] ?? '';
      final roleStr = role.toString().toUpperCase();

      print(
        '👤 Checking: ${json['full_name'] ?? json['name']} - Role: "$role"',
      );

      // RÀNG BUỘC NGHIÊM NGẶT: Chỉ lấy ROLE_LECTURER
      if (!roleStr.contains('LECTURER')) {
        print('   ❌ Skipped (not ROLE_LECTURER)');
        skippedCount++;
        continue;
      }

      print('   ✅ Accepted (ROLE_LECTURER)');

      // Thử nhiều field names có thể cho id
      int parsedId;
      final idValue = json['lecturer_id'] ?? json['lecturerId'] ?? json['id'];
      if (idValue == null) {
        parsedId = 0;
      } else if (idValue is int) {
        parsedId = idValue;
      } else if (idValue is String) {
        parsedId = int.tryParse(idValue) ?? 0;
      } else {
        parsedId = 0;
      }

      // Thử nhiều field names có thể cho name
      final nameValue =
          json['full_name'] ??
          json['fullName'] ??
          json['name'] ??
          json['lecturer_name'] ??
          json['lecturerName'];

      final item = FilterItem(
        id: parsedId,
        name: nameValue?.toString() ?? 'Unknown',
      );

      // Chỉ giữ lại lecturer đầu tiên với mỗi id
      if (!lecturerMap.containsKey(item.id) && item.id != 0) {
        lecturerMap[item.id] = item;
      }
    }

    final lecturers = lecturerMap.values.toList();
    print('✅ Loaded ${lecturers.length} unique lecturers (ROLE_LECTURER only)');
    print('⚠️ Skipped $skippedCount non-lecturer accounts');

    // KHÔNG CÒN FALLBACK - Nếu không có ROLE_LECTURER thì trả về list rỗng
    if (lecturers.isEmpty) {
      print(
        '⚠️ WARNING: No lecturers with ROLE_LECTURER found in API response!',
      );
      print('⚠️ Please check if API /api/lecturers includes role field');
    }

    // Debug: In ra vài tên lecturer
    if (lecturers.isNotEmpty) {
      print(
        '📝 Sample lecturer names: ${lecturers.take(3).map((l) => l.name).join(", ")}',
      );
    }

    return lecturers;
  }

  // Lấy danh sách khoa (từ lecturers, extract unique departments)
  Future<List<FilterItem>> getDepartments(String token) async {
    try {
      print('🔍 Loading departments from /api/lecturers...');
      final lecturers = await get('api/lecturers', token: token) as List;
      print('📊 Received ${lecturers.length} lecturers from API');

      final Set<String> uniqueDepts = {};
      final List<FilterItem> departments = [];

      int id = 1;
      for (var lecturer in lecturers) {
        final deptName =
            lecturer['department_name'] ??
            lecturer['departmentName'] ??
            lecturer['department'];
        if (deptName != null &&
            deptName.toString().isNotEmpty &&
            !uniqueDepts.contains(deptName)) {
          uniqueDepts.add(deptName.toString());
          departments.add(FilterItem(id: id++, name: deptName.toString()));
        }
      }

      print('✅ Loaded ${departments.length} unique departments');
      if (departments.isEmpty) {
        print(
          '⚠️ WARNING: No departments found! Check if lecturers have department_name field',
        );
        if (lecturers.isNotEmpty) {
          print('📝 Sample lecturer data: ${lecturers.first}');
        }
      }
      return departments;
    } catch (e) {
      print('⚠️ Error loading departments: $e');
      return [];
    }
  }

  // Lấy danh sách môn học
  Future<List<FilterItem>> getSubjects(String token) async {
    // TRY 1: Thử API /api/subjects trước
    try {
      print('🔍 Try 1: Loading subjects from /api/subjects...');
      final response = await get('api/subjects', token: token) as List;
      print('✅ Loaded ${response.length} subjects from /api/subjects');

      return response.map((json) {
        // Parse subjectId
        int parsedId;
        final idValue = json['subjectId'] ?? json['subject_id'] ?? json['id'];
        if (idValue == null) {
          parsedId = 0;
        } else if (idValue is int) {
          parsedId = idValue;
        } else if (idValue is String) {
          parsedId = int.tryParse(idValue) ?? 0;
        } else {
          parsedId = 0;
        }

        // Parse subjectName
        final nameValue =
            json['subjectName'] ?? json['subject_name'] ?? json['name'];

        return FilterItem(
          id: parsedId,
          name: nameValue?.toString() ?? 'Unknown',
        );
      }).toList();
    } catch (e1) {
      print('⚠️ /api/subjects không khả dụng: $e1');

      // TRY 2: Thử API /api/reports/subjects
      try {
        print('🔍 Try 2: Loading subjects from /api/reports/subjects...');
        final response =
            await get('api/reports/subjects', token: token) as List;
        print(
          '✅ Loaded ${response.length} subjects from /api/reports/subjects',
        );

        return response.map((json) {
          int parsedId;
          final idValue = json['subjectId'] ?? json['subject_id'] ?? json['id'];
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

          return FilterItem(
            id: parsedId,
            name: nameValue?.toString() ?? 'Unknown',
          );
        }).toList();
      } catch (e2) {
        print('⚠️ /api/reports/subjects cũng không khả dụng: $e2');

        // FALLBACK: Extract từ absence requests
        try {
          print('🔍 Fallback: Loading subjects from absence requests...');
          final requests = await getAbsenceRequests(token);
          print('📊 Received ${requests.length} absence requests');

          final Set<String> uniqueSubjects = {};
          final List<FilterItem> subjects = [];

          int id = 1;
          for (var request in requests) {
            if (request.subjectName.isNotEmpty &&
                !uniqueSubjects.contains(request.subjectName)) {
              uniqueSubjects.add(request.subjectName);
              subjects.add(FilterItem(id: id++, name: request.subjectName));
            }
          }

          print('✅ Loaded ${subjects.length} unique subjects from requests');
          if (subjects.isEmpty) {
            print('⚠️ WARNING: No subjects found! This might be because:');
            print('   1. No absence requests exist for your department');
            print(
              '   2. Backend permission restricts access to absence requests',
            );
            print('   3. Backend doesn\'t have /api/subjects endpoint');
            print('   4. Absence requests don\'t have subjectName field');
          }
          return subjects;
        } catch (e3) {
          print('❌ Error loading subjects from all sources: $e3');
          return [];
        }
      }
    }
  }

  Future<List<FilterItem>> getClasses(String token) async {
    try {
      // Theo swagger: GET /api/reports/classes
      // Trả về: [{ classId, classCode, className, semester }]
      final response = await get('api/reports/classes', token: token) as List;
      print('✅ Loaded ${response.length} classes from /api/reports/classes');

      return response.map((json) {
        // Parse classId
        int parsedId;
        final idValue = json['classId'] ?? json['class_id'] ?? json['id'];
        if (idValue == null) {
          parsedId = 0;
        } else if (idValue is int) {
          parsedId = idValue;
        } else if (idValue is String) {
          parsedId = int.tryParse(idValue) ?? 0;
        } else {
          parsedId = 0;
        }

        // Parse className
        final nameValue =
            json['className'] ?? json['class_name'] ?? json['name'];

        return FilterItem(
          id: parsedId,
          name: nameValue?.toString() ?? 'Unknown',
        );
      }).toList();
    } catch (e) {
      print('⚠️ /api/reports/classes không khả dụng: $e');

      // Fallback cũ: thử /api/classes
      try {
        final response = await get('api/classes', token: token) as List;
        print(
          '✅ Fallback: Loaded ${response.length} classes from /api/classes',
        );
        return response
            .map(
              (json) => FilterItem.fromJson(
                json,
                idKey: 'class_id',
                nameKey: 'class_name',
              ),
            )
            .toList();
      } catch (e2) {
        print('⚠️ /api/classes cũng không khả dụng: $e2');
        print('🔄 Final fallback: extract classes từ absence_requests');

        // Final fallback: lấy từ absence requests
        try {
          final requests = await getAbsenceRequests(token);
          final Set<String> uniqueClasses = {};
          final List<FilterItem> classes = [];

          int id = 1;
          for (var request in requests) {
            if (request.className.isNotEmpty &&
                !uniqueClasses.contains(request.className)) {
              uniqueClasses.add(request.className);
              classes.add(FilterItem(id: id++, name: request.className));
            }
          }

          print(
            '✅ Extracted ${classes.length} unique classes từ absence_requests',
          );
          return classes;
        } catch (e3) {
          print('❌ Error loading classes: $e3');
          return [];
        }
      }
    }
  }

  Future<List<FilterItem>> getStudentClasses(String token) async {
    final response = await get('api/student-classes', token: token) as List;
    return response
        .map(
          (json) =>
              FilterItem.fromJson(json, idKey: 'id', nameKey: 'className'),
        )
        .toList();
  }

  // ========== ABSENCE REQUESTS ==========
  Future<List<AbsenceRequest>> getAbsenceRequests(
    String token, {
    int? lecturerId,
    String? status,
  }) async {
    try {
      String endpoint = 'api/absence-requests';
      List<String> params = [];
      if (lecturerId != null) params.add('lecturerId=$lecturerId');
      if (status != null) params.add('status=$status');
      if (params.isNotEmpty) endpoint += '?${params.join('&')}';

      print('🌐 API Request: GET $_baseUrl/$endpoint');
      print('🔑 Token (first 30 chars): ${token.substring(0, 30)}...');

      final response = await get(endpoint, token: token) as List;

      print('✅ API Response: ${response.length} absence requests');
      if (response.isEmpty) {
        print('⚠️ WARNING: No absence requests returned!');
        print('   This could mean:');
        print('   1. No data exists in database');
        print('   2. Manager account has restricted access (department-based)');
        print('   3. Backend permission denies access');
      } else {
        print('📝 Sample request: ${response.first}');
      }

      return response.map((json) => AbsenceRequest.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ API /api/absence-requests lỗi: $e');
      print('📦 Trả về empty list (backend chưa có dữ liệu)');
      return []; // Return empty list instead of throwing error
    }
  }

  Future<AbsenceRequest> getAbsenceRequestById(String token, int id) async {
    final response = await get('api/absence-requests/$id', token: token);
    return AbsenceRequest.fromJson(response);
  }

  Future<AbsenceRequest> createAbsenceRequest(
    String token, {
    required int sessionId,
    required int lecturerId,
    required String reason,
    DateTime? makeupDate,
    int? makeupStartPeriod,
    int? makeupEndPeriod,
    String? makeupClassroom,
  }) async {
    // Build body with required fields
    final body = <String, dynamic>{
      'sessionId': sessionId,
      'lecturerId': lecturerId,
      'reason': reason,
    };

    // Add makeup fields if ALL are provided (backend creates makeup automatically)
    if (makeupDate != null &&
        makeupStartPeriod != null &&
        makeupEndPeriod != null &&
        makeupClassroom != null &&
        makeupClassroom.isNotEmpty) {
      body['makeupDate'] = DateTime(
        makeupDate.year,
        makeupDate.month,
        makeupDate.day,
        12, // noon UTC to avoid timezone date shift
        0,
        0,
      ).toUtc().toIso8601String();
      body['makeupStartPeriod'] = makeupStartPeriod;
      body['makeupEndPeriod'] = makeupEndPeriod;
      body['makeupClassroom'] = makeupClassroom;
    }

    print('🌐 API Request: POST $_baseUrl/api/absence-requests');
    print('📦 Body: $body');

    final response = await post(
      'api/absence-requests',
      token: token,
      body: body,
    );

    print('✅ API Response: $response');

    return AbsenceRequest.fromJson(response);
  }

  // Manager duyệt đơn xin nghỉ
  Future<AbsenceRequest> approveAbsenceRequestByManager(
    String token, {
    required int requestId,
    required String newStatus, // APPROVED or REJECTED
    String? notes,
  }) async {
    // Thử nhiều format body khác nhau
    final body = {'status': newStatus, if (notes != null) 'notes': notes};

    print(
      '🌐 Manager Approval: PATCH $_baseUrl/api/absence-requests/$requestId/manager-approval',
    );
    print('📦 Body: $body');
    print('🔑 Token: ${token.substring(0, 20)}...');

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/absence-requests/$requestId/manager-approval'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return AbsenceRequest.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        // Parse error để xem chi tiết
        try {
          final errorJson = jsonDecode(response.body);
          print('❌ Error details: $errorJson');

          final message = errorJson['message'] ?? 'Unknown error';
          final details = errorJson['details'] ?? '';
          final validationErrors = errorJson['validationErrors'];

          print('❌ Message: $message');
          print('❌ Details: $details');
          print('❌ Validation Errors: $validationErrors');

          throw Exception('$message${details.isNotEmpty ? " - $details" : ""}');
        } catch (e) {
          print('⚠️ Could not parse error: $e');
          throw Exception('Failed to approve: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Academic Affairs duyệt đơn xin nghỉ
  Future<AbsenceRequest> approveAbsenceRequestByAcademicAffairs(
    String token, {
    required int requestId,
    required String newStatus, // APPROVED or REJECTED
    String? notes,
  }) async {
    final body = {
      'status': newStatus, // Backend dùng "status" không phải "newStatus"
      if (notes != null) 'notes': notes,
    };

    print(
      '🌐 Academic Affairs Approval: PATCH $_baseUrl/api/absence-requests/$requestId/academic-affairs-approval',
    );
    print('📦 Body: $body');

    final response = await http.patch(
      Uri.parse(
        '$_baseUrl/api/absence-requests/$requestId/academic-affairs-approval',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('📡 Response Status: ${response.statusCode}');
    print('📡 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return AbsenceRequest.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception('Failed to approve: ${response.body}');
    }
  }

  // Backward compatible method - dùng manager approval
  @Deprecated('Use approveAbsenceRequestByManager instead')
  Future<AbsenceRequest> approveAbsenceRequest(
    String token, {
    required int requestId,
    required int approverId,
    required String newStatus,
    String? notes,
  }) async {
    return approveAbsenceRequestByManager(
      token,
      requestId: requestId,
      newStatus: newStatus,
      notes: notes,
    );
  }

  // ========== MAKEUP SESSIONS ==========
  Future<List<MakeupSession>> getMakeupSessions(
    String token, {
    int? lecturerId,
    String? status,
  }) async {
    try {
      String endpoint = 'api/makeup-sessions';
      List<String> params = [];
      if (lecturerId != null) params.add('lecturerId=$lecturerId');
      if (status != null) params.add('status=$status');
      if (params.isNotEmpty) endpoint += '?${params.join('&')}';

      print('🌐 API Request: GET $_baseUrl/$endpoint');

      final response = await get(endpoint, token: token) as List;

      print('✅ API Response: ${response.length} makeup sessions');
      if (response.isEmpty) {
        print('⚠️ WARNING: No makeup sessions returned!');
        print('   This could mean:');
        print('   1. No makeup sessions exist');
        print('   2. Manager account has restricted access (department-based)');
        print('   3. Backend permission denies access');
      } else {
        print('📝 Sample makeup session: ${response.first}');
      }

      return response.map((json) => MakeupSession.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ API /api/makeup-sessions lỗi: $e');
      print('📦 Trả về empty list (backend chưa có dữ liệu)');
      return []; // Return empty list instead of throwing error
    }
  }

  Future<MakeupSession> createMakeupSession(
    String token, {
    required int absenceRequestId,
    required DateTime makeupDate,
    required int startPeriod,
    required int endPeriod,
    required String classroom,
    String? notes,
  }) async {
    final body = {
      'absenceRequestId': absenceRequestId,
      'makeupDate': DateFormat('yyyy-MM-dd').format(makeupDate),
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
      'classroom': classroom,
      if (notes != null) 'notes': notes,
    };

    final response = await post(
      'api/makeup-sessions',
      token: token,
      body: body,
    );
    return MakeupSession.fromJson(response);
  }

  // Manager duyệt buổi bù
  Future<MakeupSession> approveMakeupSessionByManager(
    String token, {
    required int makeupSessionId,
    required String newStatus, // APPROVED or REJECTED
    String? notes,
  }) async {
    final body = {'status': newStatus, if (notes != null) 'notes': notes};

    print(
      '🌐 Manager Approval (Makeup): PATCH $_baseUrl/api/makeup-sessions/$makeupSessionId/manager-approval',
    );
    print('📦 Body: $body');
    print('🔑 Token: ${token.substring(0, 20)}...');

    try {
      final response = await http.patch(
        Uri.parse(
          '$_baseUrl/api/makeup-sessions/$makeupSessionId/manager-approval',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return MakeupSession.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        // Parse error để xem chi tiết
        try {
          final errorJson = jsonDecode(response.body);
          print('❌ Error details: $errorJson');

          final message = errorJson['message'] ?? 'Unknown error';
          final details = errorJson['details'] ?? '';
          final validationErrors = errorJson['validationErrors'];

          print('❌ Message: $message');
          print('❌ Details: $details');
          print('❌ Validation Errors: $validationErrors');

          throw Exception('$message${details.isNotEmpty ? " - $details" : ""}');
        } catch (e) {
          print('⚠️ Could not parse error: $e');
          throw Exception('Failed to approve makeup session: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // Academic Affairs duyệt buổi bù
  Future<MakeupSession> approveMakeupSessionByAcademicAffairs(
    String token, {
    required int makeupSessionId,
    required String newStatus, // APPROVED or REJECTED
    String? notes,
  }) async {
    final body = {'status': newStatus, if (notes != null) 'notes': notes};

    print(
      '🌐 Academic Affairs Approval (Makeup): PATCH $_baseUrl/api/makeup-sessions/$makeupSessionId/academic-affairs-approval',
    );
    print('📦 Body: $body');

    try {
      final response = await http.patch(
        Uri.parse(
          '$_baseUrl/api/makeup-sessions/$makeupSessionId/academic-affairs-approval',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return MakeupSession.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          print('❌ Error details: $errorJson');

          final message = errorJson['message'] ?? 'Unknown error';
          final details = errorJson['details'] ?? '';

          throw Exception('$message${details.isNotEmpty ? " - $details" : ""}');
        } catch (e) {
          print('⚠️ Could not parse error: $e');
          throw Exception(
            'Failed to approve makeup session (AA): ${response.body}',
          );
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      rethrow;
    }
  }

  // ========== ATTENDANCE ==========
  Future<List<Attendance>> getAttendanceBySession(
    String token,
    int sessionId,
  ) async {
    final response =
        await get('api/attendance/session/$sessionId', token: token) as List;
    return response.map((json) => Attendance.fromJson(json)).toList();
  }

  Future<void> updateAttendance(
    String token, {
    required int sessionId,
    required List<Map<String, dynamic>> attendanceList,
  }) async {
    // Backend yêu cầu POST /api/attendance/session/{sessionId} với body là array trực tiếp
    await post(
      'api/attendance/session/$sessionId',
      token: token,
      body: attendanceList,
    );
  }

  // ========== STUDENTS ==========
  Future<List<Student>> getStudentsByClass(String token, int classId) async {
    final response =
        await get('api/students/by-class/$classId', token: token) as List;
    return response.map((json) => Student.fromJson(json)).toList();
  }
}
