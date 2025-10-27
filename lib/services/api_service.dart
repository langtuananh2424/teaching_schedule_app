// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:frontend_app/models//schedule.dart'; // Giả sử bạn đã tạo model
//
// class ScheduleApiService {
//   // Thay thế bằng URL API thực tế của bạn
//   final String baseUrl = 'http://10.0.2.2:8080/api/schedules';
//
//   Future<List<TeachingSchedule>> fetchTeachingSchedules() async {
//     final response = await http.get(Uri.parse(baseUrl));
//
//     if (response.statusCode == 200) {
//       // Chuyển đổi chuỗi JSON thành danh sách Dart Map
//       List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
//
//       // Chuyển đổi danh sách Map thành danh sách đối tượng TeachingSchedule
//       return jsonResponse.map((schedule) => TeachingSchedule.fromJson(schedule)).toList();
//     } else {
//       // Xử lý lỗi
//       throw Exception('Failed to load teaching schedules. Status: ${response.statusCode}');
//     }
//   }
// }