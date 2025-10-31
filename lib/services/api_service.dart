import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_app/models/session.dart'; // Import model session

class ApiService {
  // !!! ĐẢM BẢO IP NÀY ĐÚNG !!!
  // Dùng http://10.0.2.2:8080 cho Android Emulator
  final String _baseUrl = "http://10.0.2.2:8080/api";
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          final token = await _storage.read(key: 'jwt_token');
          print("ApiService Interceptor: Đang đọc token... Giá trị: $token");
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await _storage.delete(key: 'jwt_token');
            // Thêm logic điều hướng về màn hình đăng nhập
            // ví dụ: Get.offAllNamed('/login');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Hàm lấy Lịch học (Buổi học)
  Future<List<Session>> getSessions() async {
    try {
      final response = await _dio.get('$_baseUrl/schedules');
      List<dynamic> jsonData = response.data as List;
      if (jsonData.isNotEmpty) {
        print("DỮ LIỆU THÔ (RAW DATA) TỪ API: ${jsonData[0]}");
      }

      // Dòng print này để xác nhận API thành công
      print("ApiService: Đã tải thành công ${jsonData.length} buổi học.");

      return jsonData.map((json) => Session.fromJson(json)).toList();

    } on DioException catch (e) {
      // ========================================================
      // THAY ĐỔI QUAN TRỌNG NHẤT LÀ Ở ĐÂY
      // Chúng ta cần các dòng print này để biết lỗi
      // ========================================================
      print("===== LỖI API SERVICE (getSessions) =====");
      print("URL ĐÃ GỌI: ${e.requestOptions.uri}");
      print("NỘI DUNG LỖI (MESSAGE): ${e.message}");
      print("PHẢN HỒI TỪ SERVER (RESPONSE): ${e.response?.data}");
      print("============================================");
      // ========================================================

      return []; // Trả về rỗng
    }
  }
}