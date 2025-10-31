class StudentClass {
  final int id;
  final String className;

  StudentClass({required this.id, required this.className});

  factory StudentClass.fromJson(Map<String, dynamic> json) {
    return StudentClass(
      id: json['id'] ?? 0,
      className: json['className'] ?? 'N/A',
    );
  }
}