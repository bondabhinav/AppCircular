import 'package:flutter/material.dart';

class Student {
  int id;
  String name;
  bool isChecked;

  Student({required this.id, required this.name, this.isChecked = false});
}

class StudentListWidget extends StatefulWidget {
  @override
  _StudentListWidgetState createState() => _StudentListWidgetState();
}

class _StudentListWidgetState extends State<StudentListWidget> {
  List<Student> students = [
    Student(id: 1, name: "John Doe"),
    Student(id: 2, name: "Jane Smith"),
    Student(id: 3, name: "Alex Johnson"),
    Student(id: 4, name: "Emily Brown"),
    Student(id: 5, name: "Michael Davis"),
    Student(id: 6, name: "Olivia Taylor"),
    Student(id: 7, name: "William Clark"),
    // Add more students here
  ];

  bool selectAll = false;
  List<int> selectedIds = [];

  @override
  void initState() {
    super.initState();
    selectedIds = [];
  }

  void toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      students.forEach((student) {
        student.isChecked = selectAll;
      });
      if (selectAll) {
        selectedIds = students.map((student) => student.id).toList();
      } else {
        selectedIds.clear();
      }
    });
  }

  void toggleStudentSelection(int studentId, bool value) {
    setState(() {
      students.firstWhere((student) => student.id == studentId).isChecked = value;
      if (value) {
        selectedIds.add(studentId);
      } else {
        selectedIds.remove(studentId);
      }
      selectAll = students.every((student) => student.isChecked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: toggleSelectAll,
                child: Text(
                  selectAll ? 'Deselect All' : 'Select All',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              Text(
                'Selected: ${selectedIds.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: students.map((student) {
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.trailing, // Align checkbox to the right
                  value: student.isChecked,
                  onChanged: (bool? value) {
                    toggleStudentSelection(student.id, value!);
                  },
                  title: Text(student.name),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Retrieve the selected student IDs
              print(selectedIds);
            },
            child: Text('Get Selected IDs'),
          ),
        ],
      ),
    );
  }
}


