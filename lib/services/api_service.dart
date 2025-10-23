import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // THÊM DÒNG NÀY ĐỂ SỬA LỖI 'DateFormat'
import '../constants/constants.dart';
import '../models/session.dart';
// Import các model khác nếu cần
import '../models/absence_request.dart';
import '../models/makeup_session.dart';

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
          .map((req) => req['type'] == 'absence'
          ? AbsenceRequest.fromJson(req)
          : MakeupSession.fromJson(req))
          .toList(),
    );
  }
}
class FilterItem {
  final int id;
  final String name;
  FilterItem({required this.id, required this.name});
  factory FilterItem.fromJson(Map<String, dynamic> json, {String idKey = 'id', String nameKey = 'name'}) {
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

  // ĐÃ XÓA HÀM `getSessions` BỊ TRÙNG LẶP
  // Chỉ giữ lại phiên bản đúng nhận tham số `date`
  Future<List<Session>> getSessions(String token, DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final String endpoint = 'api/lecturer/schedule?date=$formattedDate';

    final response = await get(endpoint, token: token) as List;
    return response.map((json) => Session.fromJson(json)).toList();
  }

  Future<DashboardSummary> getDashboardSummary(String token) async {
    final response = await get('api/manager/dashboard-summary', token: token);
    return DashboardSummary.fromJson(response);
  }

// Lấy danh sách học kỳ
  Future<List<FilterItem>> getSemesters(String token) async {
    // Backend cần cung cấp endpoint này, ví dụ: 'api/semesters'
    final response = await get('api/semesters', token: token) as List;
    return response.map((json) => FilterItem.fromJson(json, idKey: 'semester_id', nameKey: 'semester_name')).toList();
  }

  // Lấy danh sách giảng viên
  Future<List<FilterItem>> getLecturers(String token) async {
    // Backend cần cung cấp endpoint này, ví dụ: 'api/lecturers'
    final response = await get('api/lecturers', token: token) as List;
    return response.map((json) => FilterItem.fromJson(json, idKey: 'lecturer_id', nameKey: 'full_name')).toList();
  }

  // Lấy danh sách lớp học
  Future<List<FilterItem>> getClasses(String token) async {
    // Backend cần cung cấp endpoint này, ví dụ: 'api/classes'
    final response = await get('api/classes', token: token) as List;
    return response.map((json) => FilterItem.fromJson(json, idKey: 'class_id', nameKey: 'class_name')).toList();
  }
}