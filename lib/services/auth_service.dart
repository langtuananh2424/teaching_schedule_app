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
  bool _isLoading = true;

  String? get token => _token;
  String? get userRole => _userRole;
  String? get userName => _userName;
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

      // Hiển thị cấu trúc token khi load
      print('=== LOADED TOKEN STRUCTURE ===');
      decodedToken.forEach((key, value) {
        print('$key: $value (Type: ${value.runtimeType})');
      });
      print('=====================');

      // Xử lý role với cùng logic như trong login
      if (decodedToken.containsKey('role')) {
        _userRole = decodedToken['role'].toString().toUpperCase();
      } else if (decodedToken.containsKey('roles')) {
        final roles = decodedToken['roles'];
        if (roles is List && roles.isNotEmpty) {
          _userRole = roles.first.toString().toUpperCase();
        } else if (roles != null) {
          _userRole = roles.toString().toUpperCase();
        }
      }
      // Đặt giá trị mặc định nếu không tìm thấy role
      _userRole ??= 'USER';
      _userName = decodedToken['fullName'];
    } else {
      _token = null;
      _userRole = null;
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

          // Hiển thị cấu trúc chi tiết của token
          print('=== TOKEN STRUCTURE ===');
          decodedToken.forEach((key, value) {
            print('$key: $value (Type: ${value.runtimeType})');
          });
          print('=====================');

          // Kiểm tra và lấy role từ token
          if (decodedToken.containsKey('role')) {
            _userRole = decodedToken['role'].toString().toUpperCase();
          } else if (decodedToken.containsKey('roles')) {
            final roles = decodedToken['roles'];
            if (roles is List) {
              _userRole = roles.first.toString().toUpperCase();
            } else {
              _userRole = roles.toString().toUpperCase();
            }
          }

          _userName = decodedToken['fullName'];
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
