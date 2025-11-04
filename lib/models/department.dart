
class Department {
  final int departmentId;
  final String departmentName;

  Department({required this.departmentId, required this.departmentName});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    departmentId: json['departmentId'] as int,
    departmentName: json['departmentName'] as String,
  );
}
