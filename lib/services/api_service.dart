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
    return FilterItem(id: json[idKey], name: json[nameKey]);
  }
}

class ApiService {
  final String _baseUrl = AppConstants.baseUrl;

  Future<dynamic> get(String endpoint, {String? token}) async {
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
      throw Exception('Failed to post data: ${response.body}');
    }
  }

  Future<dynamic> patch(
      String endpoint, {
        String? token,
        Map<String, dynamic>? body,
      }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to patch data: ${response.body}');
    }
  }

  // ========== LECTURER SCHEDULE ==========
  Future<List<Session>> getSessions(String token, String email) async {
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
      // ========== MOCK DATA TẠM THỜI ==========
      print('⚠️ API /api/schedules/lecturer/$email lỗi: $e, dùng mock data');

      // Mock data cho demo
      final now = DateTime.now();
      return [
        Session(
          sessionId: 1,
          assignmentId: 101,
          sessionDate: now,
          startPeriod: 1,
          endPeriod: 3,
          classroom: '329-A2',
          content: 'Chương 1: Giới thiệu về mạng máy tính',
          status: 'NOT_TAUGHT',
          notes: null,
          subjectName: 'Mạng máy tính, 64KTPM3',
          className: '64KTPM3',
        ),
        Session(
          sessionId: 2,
          assignmentId: 102,
          sessionDate: now,
          startPeriod: 4,
          endPeriod: 6,
          classroom: '327-A2',
          content: 'Thực hành Lab 1',
          status: 'NOT_TAUGHT',
          notes: null,
          subjectName: 'Mạng máy tính, 64KTPM5',
          className: '64KTPM5',
        ),
        Session(
          sessionId: 3,
          assignmentId: 103,
          sessionDate: now,
          startPeriod: 7,
          endPeriod: 9,
          classroom: '325-A2',
          content: 'Bài giảng lý thuyết',
          status: 'NOT_TAUGHT',
          notes: null,
          subjectName: 'Quản trị mạng, 64HTT1',
          className: '64HTT1',
        ),
        Session(
          sessionId: 4,
          assignmentId: 104,
          sessionDate: now,
          startPeriod: 10,
          endPeriod: 12,
          classroom: '327-A2',
          content: 'Thực hành nâng cao',
          status: 'NOT_TAUGHT',
          notes: null,
          subjectName: 'Quản trị mạng, 64HTT3',
          className: '64HTT3',
        ),
      ];
    }
  }

  // ========== MANAGER DASHBOARD ==========
  Future<DashboardSummary> getDashboardSummary(String token) async {
    final response = await get('api/manager/dashboard-summary', token: token);
    return DashboardSummary.fromJson(response);
  }

  // ========== FILTERS ==========
  Future<List<Semester>> getSemesters(String token) async {
    final response = await get('api/semesters', token: token) as List;
    return response.map((json) => Semester.fromJson(json)).toList();
  }

  Future<List<FilterItem>> getLecturers(String token) async {
    final response = await get('api/lecturers', token: token) as List;
    return response
        .map(
          (json) => FilterItem.fromJson(
        json,
        idKey: 'lecturer_id',
        nameKey: 'full_name',
      ),
    )
        .toList();
  }

  Future<List<FilterItem>> getClasses(String token) async {
    final response = await get('api/classes', token: token) as List;
    return response
        .map(
          (json) => FilterItem.fromJson(
        json,
        idKey: 'class_id',
        nameKey: 'class_name',
      ),
    )
        .toList();
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
    String endpoint = 'api/absence-requests';
    List<String> params = [];
    if (lecturerId != null) params.add('lecturerId=$lecturerId');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await get(endpoint, token: token) as List;
    return response.map((json) => AbsenceRequest.fromJson(json)).toList();
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
    final body = {
      'sessionId': sessionId,
      'lecturerId': lecturerId,
      'reason': reason,
      if (makeupDate != null)
        'makeupDate': DateFormat('yyyy-MM-dd').format(makeupDate),
      if (makeupStartPeriod != null) 'makeupStartPeriod': makeupStartPeriod,
      if (makeupEndPeriod != null) 'makeupEndPeriod': makeupEndPeriod,
      if (makeupClassroom != null) 'makeupClassroom': makeupClassroom,
    };

    final response = await post(
      'api/absence-requests',
      token: token,
      body: body,
    );
    return AbsenceRequest.fromJson(response);
  }

  Future<AbsenceRequest> approveAbsenceRequest(
      String token, {
        required int requestId,
        required int approverId,
        required String newStatus, // APPROVED or REJECTED
        String? notes,
      }) async {
    final body = {
      'approverId': approverId,
      'newStatus': newStatus,
      if (notes != null) 'notes': notes,
    };

    final response = await patch(
      'api/absence-requests/$requestId/approve',
      token: token,
      body: body,
    );
    return AbsenceRequest.fromJson(response);
  }

  // ========== MAKEUP SESSIONS ==========
  Future<List<MakeupSession>> getMakeupSessions(
      String token, {
        int? lecturerId,
        String? status,
      }) async {
    String endpoint = 'api/makeup-sessions';
    List<String> params = [];
    if (lecturerId != null) params.add('lecturerId=$lecturerId');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await get(endpoint, token: token) as List;
    return response.map((json) => MakeupSession.fromJson(json)).toList();
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