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
      _userRole = rolesList?.first
          ?.toString()
          .toUpperCase(); // Lấy phần tử đầu tiên
      _userName = decodedToken['fullName'];

      // Email có thể ở nhiều field khác nhau
      _userEmail =
          decodedToken['email'] ??
              decodedToken['username'] ??
              decodedToken['sub'];

      // Parse userId từ token (có thể là String hoặc int)
      final subValue = decodedToken['sub'];
      _userId = subValue is int ? subValue : int.tryParse(subValue.toString());

      print(
        '🔑 Token decoded: userId=$_userId, email=$_userEmail, role=$_userRole, name=$_userName',
      );
    } else {
      _token = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final Uri loginUrl = Uri.parse('${AppConstants.baseUrl}/api/auth/login');

    try {
      final response = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _token = responseBody['accessToken'];

        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);

          Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);

          print('🔍 Login token contents: $decodedToken');

          // SỬA LỖI TẠI ĐÂY: Xử lý 'roles' như một danh sách
          final rolesList = decodedToken['roles'] as List<dynamic>?;
          _userRole = rolesList?.first
              ?.toString()
              .toUpperCase(); // Lấy phần tử đầu tiên
          _userName = decodedToken['fullName'];

          // Email có thể ở nhiều field khác nhau
          _userEmail =
              decodedToken['email'] ??
                  decodedToken['username'] ??
                  decodedToken['sub'];

          // Parse userId từ token (có thể là String hoặc int)
          final subValue = decodedToken['sub'];
          _userId = subValue is int
              ? subValue
              : int.tryParse(subValue.toString());

          print(
            '🔑 Login success: userId=$_userId, email=$_userEmail, role=$_userRole, name=$_userName',
          );
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

  Future<void> logout() async {
    _token = null;
    _userRole = null;
    _userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}