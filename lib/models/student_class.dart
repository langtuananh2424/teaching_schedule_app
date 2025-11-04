
class StudentClass {
  final int id;
  final String className;

  StudentClass({required this.id, required this.className});

  factory StudentClass.fromJson(Map<String, dynamic> json) => StudentClass(
    id: json['id'] as int,
    className: json['className'] as String? ?? '',
  );
}
