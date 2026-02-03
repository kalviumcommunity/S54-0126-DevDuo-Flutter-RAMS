class Student {
  final String id;
  final String name;
  final String studentId;
  final String klass; // "class" is reserved in Dart

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.klass,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      name: data['name'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      klass: data['class'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'studentId': studentId,
    'class': klass,
  };
}
