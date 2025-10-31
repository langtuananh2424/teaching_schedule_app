// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:frontend_app/controllers/session_controller.dart';
// import 'package:frontend_app/controllers/auth_controller.dart'; // Để logout
// import 'package:frontend_app/models/session.dart';
// import 'package:frontend_app/models/schedule_status.dart';
// import 'package:intl/intl.dart';
//
// class LecturerHomeScreen extends StatelessWidget {
//   const LecturerHomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final SessionController sessionController = Get.put(SessionController());
//     final AuthController authController = Get.find(); // Tìm AuthController đã tồn tại
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lịch Giảng Dạy'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               authController.logout(); // Gọi hàm logout
//             },
//           )
//         ],
//       ),
//       body: Obx(() {
//         if (sessionController.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (sessionController.sessionList.isEmpty) {
//           return const Center(child: Text('Không có buổi học nào.'));
//         }
//
//         return ListView.builder(
//           itemCount: sessionController.sessionList.length,
//           itemBuilder: (context, index) {
//             final session = sessionController.sessionList[index];
//             return _buildSessionItem(context, session);
//           },
//         );
//       }),
//     );
//   }
//
//   Widget _buildSessionItem(BuildContext context, Session session) {
//     Color statusColor;
//     switch (session.status) {
//       case ScheduleStatus.TAUGHT: statusColor = Colors.green; break;
//       case ScheduleStatus.NOT_TAUGHT: statusColor = Colors.blue; break;
//       case ScheduleStatus.ABSENT_APPROVED:
//       case ScheduleStatus.ABSENT_UNAPPROVED: statusColor = Colors.red; break;
//       default: statusColor = Colors.orange;
//     }
//
//     final String time = DateFormat('HH:mm').format(session.sessionDate);
//     final String date = DateFormat('dd/MM/yyyy').format(session.sessionDate);
//
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           Get.toNamed('/session_details', arguments: session);
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               SizedBox(
//                   width: 70, // Tăng độ rộng
//                   child: Column(
//                     children: [
//                       Text(time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                       Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                     ],
//                   )
//               ),
//               const VerticalDivider(),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       session.assignment.subject.subjectName,
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     Text('${session.assignment.studentClass.className} - ${session.classroom}'),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Trạng thái: ${session.statusText}',
//                       style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }