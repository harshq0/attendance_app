import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance/Models/student_model.dart';
import 'package:attendance/Services/database_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  List<Student> students = [];
  Map<String, List<String>> absenceData = {};
  Map<String, int> studentAbsenceCount = {};
  List<String> perfectAttendanceStudents = [];

  @override
  void initState() {
    super.initState();
    loadStudent();
    loadAbsenceData();
  }

  Future<void> loadStudent() async {
    final db = DatabaseService.instance;
    final loadedStudents = await db.getStudents();
    setState(() {
      students = loadedStudents;
    });
  }

  Future<void> loadAbsenceData() async {
    final db = DatabaseService.instance;
    final data = await db.getStudentAbsence(startDate, endDate);
    setState(() {
      absenceData = data;
      calculateAbsenceSummary();
    });
  }

  void calculateAbsenceSummary() {
    studentAbsenceCount.clear();
    perfectAttendanceStudents.clear();

    for (var student in students) {
      studentAbsenceCount[student.id] = 0;
    }

    absenceData.forEach((date, studentIds) {
      for (var studentId in studentIds) {
        studentAbsenceCount[studentId] =
            (studentAbsenceCount[studentId] ?? 0) + 1;
      }
    });

    for (var student in students) {
      if ((studentAbsenceCount[student.id] ?? 0) == 0) {
        perfectAttendanceStudents.add(student.id);
      }
    }
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null &&
        (picked.start != startDate || picked.end != endDate)) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      loadAbsenceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Absence History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
            child: Row(
              children: [
                const Text('Date Range: '),
                TextButton(
                  onPressed: selectDateRange,
                  child: Text(
                    '${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
              child: ListView(
                children: [
                  const Text(
                    'Datewise Absent Students:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  ...absenceData.entries.where((entry) {
                    final date = DateTime.parse(entry.key);
                    return date.isAfter(
                            startDate.subtract(const Duration(days: 1))) &&
                        date.isBefore(endDate.add(const Duration(days: 1)));
                  }).map((entry) {
                    final date = entry.key;
                    final absentStudentIds = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: $date',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...absentStudentIds.map((studentId) {
                          final student = students.firstWhere(
                              (s) => s.id == studentId,
                              orElse: () => Student(
                                  id: studentId,
                                  name: 'Unknown',
                                  rollno: 'Unknown',
                                  course: 'Unknown'));
                          return ListTile(
                            title: Text(student.name),
                            subtitle: Text(student.rollno),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                  const Divider(
                    thickness: 0.2,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Student-wise Absence:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...studentAbsenceCount.entries.map((entry) {
                    final student = students.firstWhere(
                        (s) => s.id == entry.key,
                        orElse: () => Student(
                            id: entry.key,
                            name: 'Unknown',
                            rollno: 'Unknown',
                            course: 'Unknown'));
                    return ListTile(
                      title: Text(student.name),
                      subtitle: Text('Absences: ${entry.value}'),
                    );
                  }).toList(),
                  const Divider(
                    thickness: 0.2,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Students with 100% Attendance:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...perfectAttendanceStudents.map((studentId) {
                    final student = students.firstWhere(
                        (s) => s.id == studentId,
                        orElse: () => Student(
                            id: studentId,
                            name: 'Unknown',
                            rollno: 'Unknown',
                            course: 'Unknown'));
                    return ListTile(
                      title: Text(student.name),
                      subtitle: Text(student.rollno),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
