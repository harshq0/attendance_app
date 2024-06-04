class Student {
  final String id;
  final String name;
  final String rollno;
  final String course;

  Student({
    required this.id,
    required this.name,
    required this.rollno,
    required this.course,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rollno': rollno,
      'course': course,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      rollno: map['rollno'],
      course: map['course'],
    );
  }
}
