class AbsentList {
  final String studentId;
  final String dateTime;

  AbsentList({
    required this.studentId,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'dateTime': dateTime,
    };
  }

  factory AbsentList.fromMap(Map<String, dynamic> map) {
    return AbsentList(
      studentId: map['studentId'],
      dateTime: map['dateTime'],
    );
  }
}
