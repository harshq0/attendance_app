import 'package:attendance/Components/my_buttons.dart';
import 'package:attendance/Models/student_model.dart';
import 'package:attendance/Services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  int currentIndex = 0;
  List<Student> students = [];
  Map<String, bool> attendance = {};

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  // Load Student
  Future<void> loadStudent() async {
    final db = DatabaseService.instance;
    final loadedStudents = await db.getStudents();
    setState(() {
      students = loadedStudents;

      attendance = {
        for (var student in students) student.id: false,
      };
    });
  }

  Future<void> present() async {
    setState(() {
      if (currentIndex < students.length) {
        attendance[students[currentIndex].id] = false;
        currentIndex++;
      } else {
        saveAttendance();
      }
    });
  }

  Future<void> absent() async {
    setState(() {
      if (currentIndex < students.length) {
        attendance[students[currentIndex].id] = true;
        currentIndex++;
      } else {
        saveAttendance();
      }
    });
  }

  Future<void> saveAttendance() async {
    final db = DatabaseService.instance;
    for (var student in students) {
      final isPresent = attendance[student.id] ?? false;
      if (isPresent) {
        await db.insertAbsence(
          student.id,
          DateFormat('yyyy-MM-dd').format(selectedDate),
        );
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Attendance',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Date :'),
                TextButton(
                  onPressed: () async {
                    final picker = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      initialDate: selectedDate,
                    );
                    if (picker != null && picker != selectedDate) {
                      setState(() {
                        selectedDate = picker;
                      });
                    }
                  },
                  child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                ),
              ],
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Container(
                        color: currentIndex == index
                            ? Colors.yellow.withOpacity(0.3)
                            : Colors.white,
                        child: ListTile(
                          leading: Text((index + 1).toString()),
                          title: Text(student.name),
                          subtitle: Text(student.rollno),
                          trailing: Switch(
                            value: attendance[student.id] ?? false,
                            onChanged: (value) {
                              setState(() {
                                attendance[student.id] = value;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyButtons(text: 'Present', onPressed: present),
              const SizedBox(width: 60),
              MyButtons(text: 'Absent', onPressed: absent),
            ],
          ),
        ],
      ),
    );
  }
}
