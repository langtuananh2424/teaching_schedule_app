/// Model đề xuất lịch học dựa trên API response
class ScheduleProposal {
  final int id; // ID của đề xuất
  final String classCode; // Ví dụ: 19-CNTT19
  final String className; // Ví dụ: Thiết kế web và triển khai
  final String subjectCode; // Ví dụ: FIT4014
  final String
  subjectName; // Ví dụ: Thiết kế web và triển khai hệ thống phần mềm
  final String studyTime; // Thứ 3 23/09/2025 Tiết 1-5
  final String registerTime; // Thứ 3 23/09/2025 Tiết 1-5
  final String roomCode; // Ví dụ: 88801014
  final String roomName; // Ví dụ: Kiều Tuấn Dũng
  final String proposalTime; // 03:36 17/09/2025
  final String proposalType; // Đăng ký nghỉ
  final String departmentStatus; // Đã duyệt
  final String academicStatus; // Chưa duyệt

  ScheduleProposal({
    required this.id,
    required this.classCode,
    required this.className,
    required this.subjectCode,
    required this.subjectName,
    required this.studyTime,
    required this.registerTime,
    required this.roomCode,
    required this.roomName,
    required this.proposalTime,
    required this.proposalType,
    required this.departmentStatus,
    required this.academicStatus,
  });

  factory ScheduleProposal.fromJson(Map<String, dynamic> json) {
    try {
      // Tách mã lớp và tên lớp
      String fullClassName = json['className']?.toString() ?? '';
      List<String> classNameParts = fullClassName.split(' - ');
      String classCode = classNameParts.isNotEmpty ? classNameParts[0] : '';
      String className = classNameParts.length > 1
          ? classNameParts[1]
          : fullClassName;

      // Tách mã môn và tên môn
      String fullSubjectName = json['subjectName']?.toString() ?? '';
      List<String> subjectNameParts = fullSubjectName.split(' - ');
      String subjectCode = subjectNameParts.isNotEmpty
          ? subjectNameParts[0]
          : '';
      String subjectName = subjectNameParts.length > 1
          ? subjectNameParts[1]
          : fullSubjectName;

      // Tách mã phòng và tên phòng
      String fullRoomInfo = json['roomProposed']?.toString() ?? '';
      List<String> roomInfoParts = fullRoomInfo.split(' - ');
      String roomCode = roomInfoParts.isNotEmpty ? roomInfoParts[0] : '';
      String roomName = roomInfoParts.length > 1
          ? roomInfoParts[1]
          : fullRoomInfo;

      return ScheduleProposal(
        id: json['id'] as int,
        classCode: classCode,
        className: className,
        subjectCode: subjectCode,
        subjectName: subjectName,
        studyTime: json['studyTime']?.toString() ?? '',
        registerTime: json['registerTime']?.toString() ?? '',
        roomCode: roomCode,
        roomName: roomName,
        proposalTime: json['proposalTime']?.toString() ?? '',
        proposalType: json['proposalType']?.toString() ?? '',
        departmentStatus: json['departmentStatus']?.toString() ?? '',
        academicStatus: json['academicStatus']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing proposal JSON: $json');
      print('Error details: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': '$classCode - $className',
      'subjectName': '$subjectCode - $subjectName',
      'studyTime': studyTime,
      'registerTime': registerTime,
      'roomProposed': '$roomCode - $roomName',
      'proposalTime': proposalTime,
      'proposalType': proposalType,
      'departmentStatus': departmentStatus,
      'academicStatus': academicStatus,
    };
  }
}
