import 'package:attendance/Components/my_buttons.dart';
import 'package:attendance/Models/student_model.dart';
import 'package:attendance/Pages/attendance_page.dart';
import 'package:attendance/Pages/history_page.dart';
import 'package:attendance/Services/database_service.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Import student data
  Future<void> importStudents() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;
        if (filePath != null) {
          final bytes = File(filePath).readAsBytesSync();
          final excel = Excel.decodeBytes(bytes);
          final db = DatabaseService.instance;
          for (var table in excel.tables.keys) {
            var sheet = excel.tables[table];
            if (sheet != null) {
              for (int i = 1; i < sheet.rows.length; i++) {
                var row = sheet.rows[i];
                final student = Student(
                  id: row[0]?.value.toString() ?? '',
                  name: row[1]?.value.toString() ?? '',
                  rollno: row[2]?.value.toString() ?? '',
                  course: row[3]?.value.toString() ?? '',
                );
                await db.insertStudent(student);
              }
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Students imported successfully'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File path is null"),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error importing students: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing students: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Dashboard Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Import student
            MyButtons(
              text: 'Import Students file',
              onPressed: () => importStudents(),
            ),

            const SizedBox(height: 11),

            // Take Attendance
            MyButtons(
              text: 'Take Attendance',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendancePage(),
                ),
              ),
            ),

            const SizedBox(height: 11),

            // Report Attendance
            MyButtons(
              text: 'History of Attendance',
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryPage(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
