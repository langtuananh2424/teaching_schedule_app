// lib/controllers/auth_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart'; // Đảm bảo import này đúng
import '../models/lecturer.dart';

class AuthController with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userRole = '';
  Lecturer? _lecturer;

  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  Lecturer? get lecturer => _lecturer;

  Future<bool> login(String email, String password) async {
    try {
      // SỬA LẠI ĐOẠN NÀY
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/auth/login'), // Sửa 1: Dùng AppConstants.baseUrl
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // Thêm header
        },
        body: jsonEncode({ // Sửa 2: Mã hóa body thành JSON
          'email': email,
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _isLoggedIn = true;
        _userRole = data['role'] as String;
        if (_userRole == 'lecturer') {
          _lecturer = Lecturer.fromJson(data['lecturer']);
        } else {
          _lecturer = null;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print(e); // In lỗi ra để dễ gỡ rối
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _userRole = '';
    _lecturer = null;
    notifyListeners();
  }
}