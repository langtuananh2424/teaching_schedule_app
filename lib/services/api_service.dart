import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/department.dart';
import '../models/subject.dart';
import '../models/student_class.dart';
import '../models/student.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  static const String _tokenKey = 'auth_token';
  static String? _token;
  static late SharedPreferences _prefs;

  static bool get hasToken => _token != null && _token!.isNotEmpty;

  // -----------------------------
  // Init + Token Handling
  // -----------------------------
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString(_tokenKey);
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    await _prefs.setString(_tokenKey, token);
  }

  static Future<void> logout() async {
    _token = null;
    await _prefs.remove(_tokenKey);
  }

  static Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // -----------------------------
  // Auth
  // -----------------------------
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'] ??
            data['accessToken'] ??
            data['jwt'] ??
            (data['data']?['token']);
        if (token != null) {
          await _saveToken(token as String);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // -----------------------------
  // Departments (Demo)
  // -----------------------------
  static Future<List<Department>> getDepartments() async {
    final res =
    await http.get(Uri.parse('$baseUrl/departments'), headers: _headers());
    if (res.statusCode == 200) {
      final List<dynamic> arr = jsonDecode(res.body);
      return arr
          .map((e) => Department.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // -----------------------------
  // Pending Assignments (Fake Data for Home)
  // -----------------------------
  static Future<List<dynamic>> getPendingAssignments() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/assignments/pending'),
        headers: _headers(),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (_) {}

    // Dữ liệu giả lập (demo)
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      {
        'title': '[Nghỉ dạy] GV: Nguyễn Văn A',
        'subject': 'Môn: Cấu trúc dữ liệu - 10/10/2025',
        'status': 'Chờ phê duyệt',
      },
      {
        'title': '[Dạy bù] GV: Trần Thị B',
        'subject': 'Môn: Lập trình Flutter - 15/10/2025',
        'status': 'Chờ phê duyệt',
      },
    ];
  }

  // -----------------------------
  // Report Summary (cho màn hình Báo cáo)
  // -----------------------------
  static Future<Map<String, dynamic>> getReportSummary({
    required String semester,
    required String teacher,
    required String className,
  }) async {
    try {
      final url = Uri.parse(
          '$baseUrl/report/summary?semester=$semester&teacher=$teacher&class=$className');
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}

    // Dữ liệu demo
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "completed": 27,
      "absent": 3,
      "compensated": 3,
      "attendance": 95.8,
    };
  }

  // -----------------------------
  // Pending Requests (nghỉ dạy / dạy bù)
  // -----------------------------
  static Future<List<Map<String, dynamic>>> getPendingRequests(String type) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/requests?type=$type'),
        headers: _headers(),
      );
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}

    // Dữ liệu demo fallback
    await Future.delayed(const Duration(milliseconds: 500));
    if (type == "absent") {
      return [
        {
          "id": 1,
          "teacher": "Trần Văn An",
          "subject": "Mạng máy tính",
          "date": "20/09/2025",
          "status": "Chờ duyệt"
        },
        {
          "id": 2,
          "teacher": "Nguyễn Văn A",
          "subject": "Lập trình nâng cao",
          "date": "21/09/2025",
          "status": "Chờ duyệt"
        },
      ];
    } else {
      return [
        {
          "id": 3,
          "teacher": "Trần Văn An",
          "subject": "Mạng máy tính",
          "date": "20/09/2025",
          "status": "Chờ duyệt"
        },
        {
          "id": 4,
          "teacher": "Lê Thị Bích",
          "subject": "CTGL & GT",
          "date": "22/09/2025",
          "status": "Chờ duyệt"
        },
      ];
    }
  }

  // -----------------------------
  // Approve / Reject Request
  // -----------------------------
  static Future<bool> approveRequest(int id) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/requests/$id/approve'),
        headers: _headers(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> rejectRequest(int id) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/requests/$id/reject'),
        headers: _headers(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // -----------------------------
  // ✅ NEW: Update request status (phê duyệt / từ chối)
  // -----------------------------
  static Future<bool> updateRequestStatus(int id, String status) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/requests/$id'),
        headers: _headers(),
        body: jsonEncode({"status": status}),
      );

      // Nếu API backend không hỗ trợ PUT thì bạn có thể dùng tạm POST:
      // final res = await http.post(
      //   Uri.parse('$baseUrl/requests/$id/update-status'),
      //   headers: _headers(),
      //   body: jsonEncode({"status": status}),
      // );

      return res.statusCode == 200;
    } catch (e) {
      print("❌ Lỗi cập nhật trạng thái yêu cầu: $e");
      return false;
    }
  }

  // -----------------------------
  // Report Detail (Báo cáo chi tiết)
  // -----------------------------
  static Future<List<Map<String, dynamic>>> getReportDetail({
    required String semester,
    required String teacher,
    required String className,
  }) async {
    try {
      final url = Uri.parse(
          '$baseUrl/report/detail?semester=$semester&teacher=$teacher&class=$className');
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error getReportDetail: $e');
    }

    // Dữ liệu demo fallback nếu API lỗi
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        "stt": 1,
        "code": "SV001",
        "name": "Nguyễn Văn A",
        "present": 25,
        "absent": 2,
        "percent": 92,
        "note": ""
      },
      {
        "stt": 2,
        "code": "SV002",
        "name": "Trần Thị B",
        "present": 27,
        "absent": 0,
        "percent": 100,
        "note": ""
      },
      {
        "stt": 3,
        "code": "SV003",
        "name": "Lê Văn C",
        "present": 24,
        "absent": 3,
        "percent": 88,
        "note": "Nghỉ có phép"
      },
    ];
  }
}
