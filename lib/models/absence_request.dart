// lib/models/absence_request.dart

class AbsenceRequest {
  final int id;
  final String requestType;
  final String reason;
  final DateTime createdAt;
  final String status;
  final String? approverName;
  final String lecturerName;
  final String subjectName;
  final String className;
  final DateTime sessionDate; // **PROPERTY ADDED HERE**

  AbsenceRequest({
    required this.id,
    required this.requestType,
    required this.reason,
    required this.createdAt,
    required this.status,
    this.approverName,
    required this.lecturerName,
    required this.subjectName,
    required this.className,
    required this.sessionDate, // **ADDED TO CONSTRUCTOR**
  });

  // The factory constructor is updated to handle the new property
  factory AbsenceRequest.fromJson(Map<String, dynamic> json) {
    return AbsenceRequest(
      id: json['id'],
      requestType: json['requestType'] ?? 'Yêu cầu',
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      approverName: json['approverName'],
      lecturerName: json['lecturerName'] ?? 'N/A',
      subjectName: json['subjectName'] ?? 'N/A',
      className: json['className'] ?? 'N/A',
      sessionDate: DateTime.parse(json['sessionDate']), // **MAPPING ADDED HERE**
    );
  }
}