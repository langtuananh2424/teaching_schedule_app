// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

class AuthService with ChangeNotifier {
  String? _token;
  String? _userRole;
  String? _userName;
  String? _userEmail;
  int? _userId; // Thêm userId để lưu ID người dùng
  bool _isLoading = true;

  String? get token => _token;
  String? get userRole => _userRole;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  int? get userId => _userId; // Getter cho userId
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);

      print('🔍 Token contents: $decodedToken');

      // SỬA LỖI TẠI ĐÂY: Xử lý 'roles' như một danh sách
      final rolesList = decodedToken['roles'] as List<dynamic>?;
      final rawRole = rolesList?.first?.toString().toUpperCase();

      // Đảm bảo role có prefix "ROLE_"
      if (rawRole != null) {
        _userRole = rawRole.startsWith('ROLE_') ? rawRole : 'ROLE_$rawRole';
      }

      _userName = decodedToken['fullName'];

      // Email có thể ở nhiều field khác nhau
      _userEmail =
          decodedToken['email'] ??
          decodedToken['username'] ??
          decodedToken['sub'];

      // Parse userId từ token (có thể là String hoặc int)
      // Token có thể chứa: sub, userId, lecturerId, id
      final subValue = decodedToken['sub'];
      final userIdValue = decodedToken['userId'];
      final lecturerIdValue = decodedToken['lecturerId'];
      final idValue = decodedToken['id'];

      // Thử các field khác nhau
      if (lecturerIdValue != null) {
        _userId = lecturerIdValue is int
            ? lecturerIdValue
            : int.tryParse(lecturerIdValue.toString());
      } else if (userIdValue != null) {
        _userId = userIdValue is int
            ? userIdValue
            : int.tryParse(userIdValue.toString());
      } else if (idValue != null) {
        _userId = idValue is int ? idValue : int.tryParse(idValue.toString());
      } else if (subValue != null) {
        _userId = subValue is int
            ? subValue
            : int.tryParse(subValue.toString());
      }

      // Nếu vẫn chưa có userId, thử lấy từ cache
      if (_userId == null) {
        _userId = prefs.getInt('cached_lecturer_id');
        if (_userId != null) {
          print('📦 Loaded lecturerId from cache: $_userId');
        }
      }

      print(
        '🔑 Token decoded: userId=$_userId (from lecturerId=$lecturerIdValue, userId=$userIdValue, id=$idValue, sub=$subValue), email=$_userEmail, role=$_userRole, name=$_userName',
      );

      // Nếu là LECTURER và vẫn chưa có userId, thử lấy từ API
      if (_userRole == 'ROLE_LECTURER' &&
          _userId == null &&
          _userEmail != null) {
        await _fetchLecturerIdFromApi();
      }
    } else {
      _token = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final Uri loginUrl = Uri.parse('${AppConstants.baseUrl}/api/auth/login');

    try {
      // Xóa cache cũ trước khi login mới để tránh dùng nhầm userId cũ
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_lecturer_id');
      _userId = null; // Reset userId trước khi parse token mới

      final response = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _token = responseBody['accessToken'];

        if (_token != null) {
          await prefs.setString('token', _token!);

          Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);

          print('🔍 Login token contents: $decodedToken');

          // SỬA LỖI TẠI ĐÂY: Xử lý 'roles' như một danh sách
          final rolesList = decodedToken['roles'] as List<dynamic>?;
          final rawRole = rolesList?.first?.toString().toUpperCase();

          // Đảm bảo role có prefix "ROLE_"
          if (rawRole != null) {
            _userRole = rawRole.startsWith('ROLE_') ? rawRole : 'ROLE_$rawRole';
          }

          _userName = decodedToken['fullName'];

          // Email có thể ở nhiều field khác nhau
          _userEmail =
              decodedToken['email'] ??
              decodedToken['username'] ??
              decodedToken['sub'];

          // Parse userId từ token (có thể là String hoặc int)
          // Token có thể chứa: sub, userId, lecturerId, id
          final subValue = decodedToken['sub'];
          final userIdValue = decodedToken['userId'];
          final lecturerIdValue = decodedToken['lecturerId'];
          final idValue = decodedToken['id'];

          // Thử các field khác nhau
          if (lecturerIdValue != null) {
            _userId = lecturerIdValue is int
                ? lecturerIdValue
                : int.tryParse(lecturerIdValue.toString());
          } else if (userIdValue != null) {
            _userId = userIdValue is int
                ? userIdValue
                : int.tryParse(userIdValue.toString());
          } else if (idValue != null) {
            _userId = idValue is int
                ? idValue
                : int.tryParse(idValue.toString());
          } else if (subValue != null) {
            _userId = subValue is int
                ? subValue
                : int.tryParse(subValue.toString());
          }

          print(
            '🔑 Login token initial: userId=$_userId (from lecturerId=$lecturerIdValue, userId=$userIdValue, id=$idValue, sub=$subValue), email=$_userEmail, role=$_userRole, name=$_userName',
          );

          // Nếu là LECTURER và chưa có userId, thử lấy từ API /api/lecturers
          if (_userRole == 'ROLE_LECTURER' &&
              _userId == null &&
              _userEmail != null) {
            await _fetchLecturerIdFromApi();
          }

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  // Hàm phụ để lấy lecturerId từ API /api/lecturers
  Future<void> _fetchLecturerIdFromApi() async {
    try {
      print(
        '🔍 Trying to fetch lecturerId from /api/lecturers for email: $_userEmail',
      );

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/lecturers'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> lecturers = jsonDecode(response.body);

        // Filter theo email
        final matchingLecturers = lecturers
            .where((lecturer) => lecturer['email'] == _userEmail)
            .toList();

        if (matchingLecturers.isEmpty) {
          print('⚠️ No lecturer found with email: $_userEmail');
          return;
        }

        final lecturer = matchingLecturers.first;

        // ĐÚNG: Theo Swagger, field là 'lecturerId' không phải 'lecturer_id'
        final lecturerId = lecturer['lecturerId'];
        _userId = lecturerId is int
            ? lecturerId
            : int.tryParse(lecturerId.toString());

        print(
          '✅ Found lecturerId from API: $_userId for ${lecturer['fullName']}',
        );

        // Lưu vào SharedPreferences để dùng lại
        final prefs = await SharedPreferences.getInstance();
        if (_userId != null) {
          await prefs.setInt('cached_lecturer_id', _userId!);
        }
      } else {
        print('⚠️ Failed to fetch lecturers: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching lecturerId from API: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _userRole = null;
    _userName = null;
    _userEmail = null;
    _userId = null; // Xóa userId khi logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove(
      'cached_lecturer_id',
    ); // Xóa cache để tránh dùng nhầm userId cũ
    print('🚪 Logged out - cleared token and cached_lecturer_id');
    notifyListeners();
  }
}
