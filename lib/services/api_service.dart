import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Import các tệp cần thiết từ dự án của bạn
import '../constants/constants.dart';
import '../models/lecturer.dart';
import '../models/session.dart';
import '../models/absence_request.dart';
import '../models/makeup_session.dart';
import '../models/session_attendance.dart';
import '../models/student.dart';
import '../models/schedule_proposal.dart';
import '../models/student_class.dart';
import '../models/subject.dart';
import '../models/assignment.dart';
import '../models/schedule.dart';

// --- CÁC LỚP MODEL PHỤ TRỢ ---

// Model cho dữ liệu tổng quan trên Dashboard của quản lý
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
    var requestsFromJson = json['recentRequests'] as List? ?? [];
    List<dynamic> parsedRequests = requestsFromJson.map((req) {
      if (req['type'] == 'absence') {
        return AbsenceRequest.fromJson(req);
      } else {
        return MakeupSession.fromJson(req);
      }
    }).toList();

    return DashboardSummary(
      pendingAbsenceCount: json['pendingAbsenceCount'] ?? 0,
      pendingMakeupCount: json['pendingMakeupCount'] ?? 0,
      recentRequests: parsedRequests,
    );
  }
}

// Model chung cho các item trong bộ lọc báo cáo
class FilterItem {
  final int id;
  final String name;

  FilterItem({required this.id, required this.name});

  factory FilterItem.fromJson(
    Map<String, dynamic> json, {
    String idKey = 'id',
    String nameKey = 'name',
  }) {
    return FilterItem(id: json[idKey], name: json[nameKey]);
  }
}

// --- LỚP DỊCH VỤ API CHÍNH ---

class ApiService {
  // Dùng localhost cho môi trường web
  final String _baseUrl = AppConstants.baseUrl;

  // --- CÁC HÀM TIỆN ÍCH CHUNG ---

  // Hàm GET chung để xử lý các yêu cầu và lỗi
  Future<dynamic> _get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      // Ném ra lỗi với nội dung từ server để dễ debug
      throw Exception('Failed to load data from $endpoint: ${response.body}');
    }
  }

  // POST request handler
  Future<dynamic> _post(
    String endpoint, {
    required String token,
    required Map<String, dynamic> body,
  }) async {
    print('POST $endpoint');
    print('Body: $body');

    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('POST $endpoint - Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to post data to $endpoint: ${response.body}');
    }
  }

  Future<void> _delete(String endpoint, {required String token}) async {
    print('DELETE $endpoint');

    final response = await http.delete(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('DELETE $endpoint - Status: ${response.statusCode}');
    print('Response: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete data from $endpoint: ${response.body}');
    }
  }

  Future<dynamic> _put(
    String endpoint, {
    required String token,
    required Map<String, dynamic> body,
  }) async {
    print('PUT $endpoint');
    print('Body: $body');

    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('PUT $endpoint - Status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Status 200 = OK with body, Status 204 = No Content (success without body)
    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isNotEmpty) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null; // 204 No Content case
    } else {
      // Parse error message from backend
      String errorMessage = 'Failed to update data at $endpoint';
      print('Error response: ${response.body}');
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson is Map && errorJson.containsKey('message')) {
          errorMessage = errorJson['message'];
        } else if (errorJson is Map && errorJson.containsKey('error')) {
          errorMessage = errorJson['error'];
        }
      } catch (e) {
        errorMessage = 'Failed to update data at $endpoint: ${response.body}';
      }
      throw Exception(errorMessage);
    }
  }

  Future<dynamic> _patch(
    String endpoint, {
    required String token,
    required Map<String, dynamic> body,
  }) async {
    print('PATCH $endpoint');
    print('Body: $body');

    final response = await http.patch(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('PATCH $endpoint - Status: ${response.statusCode}');
    print('Response: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isNotEmpty && response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } else {
      throw Exception('Failed to patch data at $endpoint: ${response.body}');
    }
  }

  // --- CÁC HÀM API CỤ THỂ ---

  /// Lấy lịch trình của một giảng viên theo ngày.
  /// **Backend Cần Cung Cấp:** `GET /api/lecturer/schedule`
  Future<List<Session>> getSessions(String token, DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final String endpoint = 'api/lecturer/schedule?date=$formattedDate';
    final response = await _get(endpoint, token: token) as List;
    return response.map((json) => Session.fromJson(json)).toList();
  }

  /// Lấy danh sách điểm danh của các buổi học theo ngày
  Future<List<SessionAttendance>> getAttendance(
    String token,
    DateTime date,
  ) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await _get(
      'api/sessions/attendance?date=$formattedDate',
      token: token,
    );

    if (response is List) {
      return response.map((json) => SessionAttendance.fromJson(json)).toList();
    } else {
      throw Exception('Invalid response format');
    }
  }

  /// Lấy danh sách sinh viên
  Future<List<Student>> getStudents(String token) async {
    try {
      final response = await _get('api/students', token: token);

      print('GET api/students response type: ${response.runtimeType}');
      if (response is List && response.isNotEmpty) {
        print('First student data: ${response.first}');
      }

      if (response == null) {
        return [];
      }

      if (response is! List) {
        print('Invalid response type: ${response.runtimeType}');
        print('Response content: $response');
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      final students = <Student>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            print('Invalid item type: ${item.runtimeType}');
            print('Item content: $item');
            continue;
          }

          final student = Student.fromJson(item);
          print(
            '✅ Parsed student: ID=${student.id}, Code=${student.studentCode}, Name=${student.fullName}',
          );
          students.add(student);
        } catch (e) {
          print('❌ Error parsing student data: $item');
          print('Error details: $e');
          // Continue processing other items instead of throwing
        }
      }

      return students;
    } catch (e, stackTrace) {
      print('Error getting students: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error getting students: $e');
    }
  }

  /// Lấy danh sách sinh viên theo lớp
  Future<List<Student>> getStudentsByClass(String token, int classId) async {
    try {
      final data = await _get('api/students/by-class/$classId', token: token);
      return (data as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error getting students by class: $e');
    }
  }

  /// Cập nhật thông tin sinh viên
  Future<void> updateStudent(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      // Backend chỉ hỗ trợ PUT
      await _put('api/students/$id', token: token, body: data);
    } catch (e) {
      throw Exception('Error updating student: $e');
    }
  }

  /// Tạo sinh viên mới
  Future<void> createStudent(String token, Map<String, dynamic> data) async {
    try {
      await _post('api/students', token: token, body: data);
    } catch (e) {
      throw Exception('Error creating student: $e');
    }
  }

  /// Xóa sinh viên
  Future<void> deleteStudent(String token, int id) async {
    try {
      await _delete('api/students/$id', token: token);
    } catch (e) {
      throw Exception('Error deleting student: $e');
    }
  }

  /// Lấy dữ liệu tổng quan cho Dashboard của quản lý.
  /// **Backend Cần Cung Cấp:** `GET /api/manager/dashboard-summary`
  Future<DashboardSummary> getDashboardSummary(String token) async {
    final response = await _get('api/manager/dashboard-summary', token: token);
    return DashboardSummary.fromJson(response);
  }

  /// Lấy tất cả các đơn xin nghỉ (dùng cho màn hình phê duyệt của quản lý).
  /// **API Đã Có:** `GET /api/absence-requests`
  Future<List<AbsenceRequest>> getAbsenceRequests(String token) async {
    final response = await _get('api/absence-requests', token: token) as List;
    return response.map((json) => AbsenceRequest.fromJson(json)).toList();
  }

  /// Cập nhật trạng thái duyệt của Trưởng khoa cho đơn xin nghỉ
  Future<void> updateAbsenceRequestManagerApproval(
    String token,
    int id,
    String status,
  ) async {
    try {
      await _patch(
        'api/absence-requests/$id/manager-approval',
        token: token,
        body: {'status': status},
      );
    } catch (e) {
      throw Exception('Error updating manager approval: $e');
    }
  }

  /// Cập nhật trạng thái duyệt của Phòng Đào tạo cho đơn xin nghỉ
  Future<void> updateAbsenceRequestAcademicAffairsApproval(
    String token,
    int id,
    String status,
  ) async {
    try {
      await _patch(
        'api/absence-requests/$id/academic-affairs-approval',
        token: token,
        body: {'status': status},
      );
    } catch (e) {
      throw Exception('Error updating academic affairs approval: $e');
    }
  }

  /// Lấy tất cả makeup sessions
  Future<List<MakeupSession>> getMakeupSessions(String token) async {
    final response = await _get('api/makeup-sessions', token: token) as List;
    return response.map((json) => MakeupSession.fromJson(json)).toList();
  }

  /// Cập nhật trạng thái duyệt của Trưởng khoa cho yêu cầu dạy bù
  Future<void> updateMakeupSessionManagerApproval(
    String token,
    int id,
    String status,
  ) async {
    try {
      await _patch(
        'api/makeup-sessions/$id/manager-approval',
        token: token,
        body: {'status': status},
      );
    } catch (e) {
      throw Exception('Error updating manager approval: $e');
    }
  }

  /// Cập nhật trạng thái duyệt của Phòng Đào tạo cho yêu cầu dạy bù
  Future<void> updateMakeupSessionAcademicAffairsApproval(
    String token,
    int id,
    String status,
  ) async {
    try {
      await _patch(
        'api/makeup-sessions/$id/academic-affairs-approval',
        token: token,
        body: {'status': status},
      );
    } catch (e) {
      throw Exception('Error updating academic affairs approval: $e');
    }
  }

  /// Lấy danh sách tất cả giảng viên.
  Future<List<Lecturer>> getLecturers(String token) async {
    try {
      print('API: Calling GET /api/lecturers');
      final response = await _get('api/lecturers', token: token);

      if (response == null) {
        print('API: Response is null, returning empty list');
        return [];
      }

      if (response is! List) {
        print('Invalid response type: ${response.runtimeType}');
        print('Response content: $response');
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      print('API: Received ${response.length} items from server');
      final lecturers = <Lecturer>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            print('Invalid item type: ${item.runtimeType}');
            print('Item content: $item');
            continue;
          }

          final lecturer = Lecturer.fromJson(item);
          lecturers.add(lecturer);
        } catch (e) {
          print('Error parsing lecturer data: $item');
          print('Error details: $e');
          // Continue processing other items instead of throwing
        }
      }

      print('API: Successfully parsed ${lecturers.length} lecturers');
      return lecturers;
    } catch (e, stackTrace) {
      print('Error getting lecturers: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error getting lecturers: $e');
    }
  }

  /// Lọc giảng viên theo vai trò
  Future<List<Lecturer>> getLecturersByRole(String token, String role) async {
    try {
      print('API: Calling GET /api/lecturers/filter-by?role=$role');
      final response = await _get(
        'api/lecturers/filter-by?role=$role',
        token: token,
      );

      if (response == null) {
        print('API: Response is null, returning empty list');
        return [];
      }

      if (response is! List) {
        print('Invalid response type: ${response.runtimeType}');
        print('Response content: $response');
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      print('API: Received ${response.length} items from server');
      final lecturers = <Lecturer>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            print('Invalid item type: ${item.runtimeType}');
            print('Item content: $item');
            continue;
          }

          final lecturer = Lecturer.fromJson(item);
          lecturers.add(lecturer);
        } catch (e) {
          print('Error parsing lecturer data: $item');
          print('Error details: $e');
          // Continue processing other items instead of throwing
        }
      }

      print('API: Successfully parsed ${lecturers.length} lecturers');
      return lecturers;
    } catch (e, stackTrace) {
      print('Error getting lecturers by role: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error getting lecturers by role: $e');
    }
  }

  /// Lọc giảng viên theo khoa và/hoặc vai trò
  Future<List<Lecturer>> getFilteredLecturers(
    String token,
    int? departmentId,
    String? role,
  ) async {
    try {
      // Build query params
      final params = <String>[];
      if (departmentId != null) {
        params.add('departmentId=$departmentId');
      }
      if (role != null && role.isNotEmpty) {
        params.add('role=$role');
      }

      final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
      final endpoint = params.isEmpty
          ? 'api/lecturers'
          : 'api/lecturers/filter-by$queryString';

      print('API: Calling GET /$endpoint');
      final response = await _get(endpoint, token: token);

      if (response == null) {
        print('API: Response is null, returning empty list');
        return [];
      }

      if (response is! List) {
        print('Invalid response type: ${response.runtimeType}');
        print('Response content: $response');
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      print('API: Received ${response.length} items from server');
      final lecturers = <Lecturer>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            print('Invalid item type: ${item.runtimeType}');
            print('Item content: $item');
            continue;
          }

          final lecturer = Lecturer.fromJson(item);
          lecturers.add(lecturer);
        } catch (e) {
          print('Error parsing lecturer data: $item');
          print('Error details: $e');
        }
      }

      print('API: Successfully parsed ${lecturers.length} lecturers');
      return lecturers;
    } catch (e, stackTrace) {
      print('Error getting filtered lecturers: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error getting filtered lecturers: $e');
    }
  }

  /// Tạo giảng viên mới
  Future<void> createLecturer(String token, Map<String, dynamic> data) async {
    try {
      print('Creating lecturer with data: $data');
      await _post('api/lecturers', token: token, body: data);
      print('✅ Lecturer created successfully');
    } catch (e) {
      print('❌ Error creating lecturer: $e');
      throw Exception('Error creating lecturer: $e');
    }
  }

  /// Cập nhật thông tin giảng viên
  Future<void> updateLecturer(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _put('api/lecturers/$id', token: token, body: data);
    } catch (e) {
      throw Exception('Error updating lecturer: $e');
    }
  }

  /// Xóa giảng viên
  Future<void> deleteLecturer(String token, int id) async {
    try {
      await _delete('api/lecturers/$id', token: token);
    } catch (e) {
      throw Exception('Error deleting lecturer: $e');
    }
  }

  /// Cập nhật mật khẩu giảng viên
  Future<void> updateLecturerPassword(
    String token,
    int id,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      await _put(
        'api/lecturers/$id/password',
        token: token,
        body: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  /// [ADMIN] Đặt lại mật khẩu người dùng (không cần mật khẩu cũ)
  Future<void> adminResetPassword(
    String token,
    int userId,
    String newPassword,
  ) async {
    try {
      print(
        '🔐 Admin Reset Password - userId: $userId, newPassword length: ${newPassword.length}',
      );
      final response = await _put(
        'api/users/$userId/password',
        token: token,
        body: {'newPassword': newPassword},
      );
      print('✅ Reset password response: $response');
    } catch (e) {
      print('❌ Reset password error: $e');
      throw Exception('Error resetting password: $e');
    }
  }

  /// Lấy tất cả users
  Future<List<Map<String, dynamic>>> getAllUsers(String token) async {
    try {
      final response = await _get('api/users', token: token);
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Error getting users: $e');
    }
  }

  /// Tìm userId từ email
  Future<int?> getUserIdByEmail(String token, String email) async {
    try {
      final users = await getAllUsers(token);
      final user = users.firstWhere(
        (u) => u['email'] == email,
        orElse: () => <String, dynamic>{},
      );
      return user['userId'] as int?;
    } catch (e) {
      print('Error finding userId for email $email: $e');
      return null;
    }
  }

  // ==================== STUDENT CLASSES ====================

  /// Lấy tất cả các lớp sinh viên
  Future<List<StudentClass>> getStudentClasses(String token) async {
    try {
      print('API: Calling GET /api/student-classes');
      final response = await _get('api/student-classes', token: token);

      if (response == null) {
        print('API: Response is null, returning empty list');
        return [];
      }

      if (response is! List) {
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      print('API: Received ${response.length} student classes');
      final classes = <StudentClass>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            continue;
          }
          final studentClass = StudentClass.fromJson(item);
          classes.add(studentClass);
        } catch (e) {
          print('Error parsing student class: $item');
          print('Error details: $e');
        }
      }

      print('API: Successfully parsed ${classes.length} student classes');
      return classes;
    } catch (e) {
      print('Error getting student classes: $e');
      throw Exception('Error getting student classes: $e');
    }
  }

  /// Lấy lớp sinh viên theo ID
  Future<StudentClass> getStudentClassById(String token, int id) async {
    try {
      final response = await _get('api/student-classes/$id', token: token);
      return StudentClass.fromJson(response);
    } catch (e) {
      throw Exception('Error getting student class: $e');
    }
  }

  /// Tạo lớp sinh viên mới
  Future<void> createStudentClass(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      await _post('api/student-classes', token: token, body: data);
    } catch (e) {
      throw Exception('Error creating student class: $e');
    }
  }

  /// Cập nhật lớp sinh viên
  Future<void> updateStudentClass(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _put('api/student-classes/$id', token: token, body: data);
    } catch (e) {
      throw Exception('Error updating student class: $e');
    }
  }

  /// Xóa lớp sinh viên
  Future<void> deleteStudentClass(String token, int id) async {
    try {
      await _delete('api/student-classes/$id', token: token);
    } catch (e) {
      throw Exception('Error deleting student class: $e');
    }
  }

  // ========== SUBJECT MANAGEMENT ==========

  /// Lấy tất cả các môn học
  Future<List<Subject>> getSubjects(String token) async {
    try {
      print('API: Calling GET /api/subjects');
      final response = await _get('api/subjects', token: token);

      if (response == null) {
        print('API: Response is null, returning empty list');
        return [];
      }

      if (response is! List) {
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      print('API: Received ${response.length} subjects');
      final subjects = <Subject>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            continue;
          }
          final subject = Subject.fromJson(item);
          subjects.add(subject);
        } catch (e) {
          print('Error parsing subject: $item');
          print('Error details: $e');
        }
      }

      print('API: Successfully parsed ${subjects.length} subjects');
      return subjects;
    } catch (e) {
      print('Error getting subjects: $e');
      throw Exception('Error getting subjects: $e');
    }
  }

  /// Lấy môn học theo ID
  Future<Subject> getSubjectById(String token, int id) async {
    try {
      final response = await _get('api/subjects/$id', token: token);
      return Subject.fromJson(response);
    } catch (e) {
      throw Exception('Error getting subject: $e');
    }
  }

  /// Tạo môn học mới
  Future<void> createSubject(String token, Map<String, dynamic> data) async {
    try {
      await _post('api/subjects', token: token, body: data);
    } catch (e) {
      throw Exception('Error creating subject: $e');
    }
  }

  /// Cập nhật môn học
  Future<void> updateSubject(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _put('api/subjects/$id', token: token, body: data);
    } catch (e) {
      throw Exception('Error updating subject: $e');
    }
  }

  /// Xóa môn học
  Future<void> deleteSubject(String token, int id) async {
    try {
      await _delete('api/subjects/$id', token: token);
    } catch (e) {
      throw Exception('Error deleting subject: $e');
    }
  }

  // ========== ASSIGNMENT MANAGEMENT ==========

  /// Lấy tất cả các phân công giảng dạy
  Future<List<Assignment>> getAssignments(String token) async {
    try {
      print('API: Calling GET /api/assignments');
      final response = await _get('api/assignments', token: token);

      if (response == null) {
        print('API: Response is null, returning empty list');
        return [];
      }

      if (response is! List) {
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      print('API: Received ${response.length} assignments');
      final assignments = <Assignment>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            continue;
          }
          final assignment = Assignment.fromJson(item);
          assignments.add(assignment);
        } catch (e) {
          print('Error parsing assignment: $item');
          print('Error details: $e');
        }
      }

      print('API: Successfully parsed ${assignments.length} assignments');
      return assignments;
    } catch (e) {
      print('Error getting assignments: $e');
      throw Exception('Error getting assignments: $e');
    }
  }

  /// Lấy phân công giảng dạy theo ID
  Future<Assignment> getAssignmentById(String token, int id) async {
    try {
      final response = await _get('api/assignments/$id', token: token);
      return Assignment.fromJson(response);
    } catch (e) {
      throw Exception('Error getting assignment: $e');
    }
  }

  /// Tạo phân công giảng dạy mới
  Future<void> createAssignment(String token, Map<String, dynamic> data) async {
    try {
      await _post('api/assignments', token: token, body: data);
    } catch (e) {
      throw Exception('Error creating assignment: $e');
    }
  }

  /// Cập nhật phân công giảng dạy
  Future<void> updateAssignment(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _put('api/assignments/$id', token: token, body: data);
    } catch (e) {
      throw Exception('Error updating assignment: $e');
    }
  }

  /// Xóa phân công giảng dạy
  Future<void> deleteAssignment(String token, int id) async {
    try {
      await _delete('api/assignments/$id', token: token);
    } catch (e) {
      throw Exception('Error deleting assignment: $e');
    }
  }

  // ========== SCHEDULE MANAGEMENT ==========

  /// Lấy tất cả các lịch học
  Future<List<Schedule>> getSchedules(String token) async {
    try {
      print('API: Calling GET /api/schedules');
      final response = await _get('api/schedules', token: token);

      if (response == null) {
        print('API: Response is null, returning empty list');
        return [];
      }

      if (response is! List) {
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      print('API: Received ${response.length} schedules');
      final schedules = <Schedule>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            continue;
          }
          final schedule = Schedule.fromJson(item);
          schedules.add(schedule);
        } catch (e) {
          print('Error parsing schedule: $item');
          print('Error details: $e');
        }
      }

      print('API: Successfully parsed ${schedules.length} schedules');
      return schedules;
    } catch (e) {
      print('Error getting schedules: $e');
      throw Exception('Error getting schedules: $e');
    }
  }

  /// Lấy lịch học theo ID
  Future<Schedule> getScheduleById(String token, int id) async {
    try {
      final response = await _get('api/schedules/$id', token: token);
      return Schedule.fromJson(response);
    } catch (e) {
      throw Exception('Error getting schedule: $e');
    }
  }

  /// Tạo lịch học mới
  Future<void> createSchedule(String token, Map<String, dynamic> data) async {
    try {
      await _post('api/schedules', token: token, body: data);
    } catch (e) {
      throw Exception('Error creating schedule: $e');
    }
  }

  /// Cập nhật lịch học
  Future<void> updateSchedule(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _put('api/schedules/$id', token: token, body: data);
    } catch (e) {
      throw Exception('Error updating schedule: $e');
    }
  }

  /// Xóa lịch học
  Future<void> deleteSchedule(String token, int id) async {
    try {
      await _delete('api/schedules/$id', token: token);
    } catch (e) {
      throw Exception('Error deleting schedule: $e');
    }
  }

  /// Lấy danh sách đề xuất lịch học
  Future<List<ScheduleProposal>> getScheduleProposals(String token) async {
    try {
      final response = await _get('api/proposals', token: token);

      if (response == null) {
        return [];
      }

      if (response is! List) {
        print('Invalid response type: ${response.runtimeType}');
        print('Response content: $response');
        throw Exception(
          'Invalid response format: Expected List but got ${response.runtimeType}',
        );
      }

      final proposals = <ScheduleProposal>[];

      for (final item in response) {
        try {
          if (item is! Map<String, dynamic>) {
            print('Invalid item type: ${item.runtimeType}');
            print('Item content: $item');
            continue;
          }

          final proposal = ScheduleProposal.fromJson(item);
          proposals.add(proposal);
        } catch (e) {
          print('Error parsing proposal data: $item');
          print('Error details: $e');
        }
      }

      return proposals;
    } catch (e, stackTrace) {
      print('Error getting schedule proposals: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error getting schedule proposals: $e');
    }
  }

  /// Phê duyệt đề xuất lịch học (Khoa)
  Future<void> approveProposalByDepartment(String token, int proposalId) async {
    try {
      await _put(
        'api/proposals/$proposalId/department-approval',
        token: token,
        body: {'approved': true},
      );
    } catch (e) {
      throw Exception('Error approving proposal by department: $e');
    }
  }

  /// Phê duyệt đề xuất lịch học (Phòng Đào tạo)
  Future<void> approveProposalByAcademicAffairs(
    String token,
    int proposalId,
  ) async {
    try {
      await _put(
        'api/proposals/$proposalId/academic-approval',
        token: token,
        body: {'approved': true},
      );
    } catch (e) {
      throw Exception('Error approving proposal by academic affairs: $e');
    }
  }

  // --- CÁC HÀM LẤY DỮ LIỆU BỘ LỌC CHO TRANG BÁO CÁO ---

  /// Lấy danh sách khoa.
  /// **API Đã Có:** `GET /api/departments`
  Future<List<FilterItem>> getDepartments(String token) async {
    final response = await _get('api/departments', token: token) as List;
    print('🏫 Raw departments from API: $response');
    final departments = response
        .map(
          (json) => FilterItem.fromJson(
            json,
            idKey: 'departmentId',
            nameKey: 'departmentName',
          ),
        )
        .toList();
    print(
      '🏫 Parsed departments: ${departments.map((d) => 'ID:${d.id} Name:${d.name}').toList()}',
    );
    return departments;
  }

  /// Lấy danh sách môn học cho dropdown/filter.
  Future<List<FilterItem>> getSubjectsForFilter(String token) async {
    final response = await _get('api/subjects', token: token) as List;
    return response
        .map(
          (json) => FilterItem.fromJson(
            json,
            idKey: 'subjectId',
            nameKey: 'subjectName',
          ),
        )
        .toList();
  }

  /// Lấy danh sách lớp học.
  /// Lấy danh sách học khóa.
  /// **Backend Cần Cung Cấp:** `GET /api/semesters`
  Future<List<FilterItem>> getSemesters(String token) async {
    final response = await _get('api/semesters', token: token) as List;
    return response
        .map(
          (json) => FilterItem.fromJson(
            json,
            idKey: 'semester_id',
            nameKey: 'semester_name',
          ),
        )
        .toList();
  }
}
