import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_easy_final/auth/validator.dart';
import 'package:note_easy_final/pages/home_page.dart';

enum UserType { teacher, student }

class SelectionPage extends StatefulWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  final _collegeNameController = TextEditingController();

  UserType? _userType = UserType.student;
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _semesterList = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6"
  ];

  String? _selectedCourse;
  String? _selectedSemester;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to S Cube"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white)),
                      child: TextFormField(
                        controller: _nameController,
                        validator: (value) => Validator.validateName(
                          name: value,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Username',
                          labelText: 'Username',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white)),
                      child: TextFormField(
                        controller: _collegeNameController,
                        decoration: InputDecoration(
                          hintText: 'College Name',
                          labelText: 'College Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('CourseList')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return const Text('Loading...');
                      } else {
                        List<DropdownMenuItem> courseList = [];
                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          DocumentSnapshot snap = snapshot.data!.docs[i];
                          courseList.add(
                            DropdownMenuItem<String>(
                              child: Text(snap.id),
                              value: snap.id,
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: DropdownButtonFormField<dynamic>(
                              isExpanded: true,
                              items: courseList,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCourse = value as String;
                                });
                              },
                              value: _selectedCourse,
                              dropdownColor: Colors.blueAccent,
                              decoration: const InputDecoration(
                                  labelText: "Select Course",
                                  prefixIcon: Icon(Icons.subject),
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        items: _semesterList.map(
                          (e) {
                            return DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSemester = value as String;
                          });
                        },
                        dropdownColor: Colors.blueAccent,
                        decoration: const InputDecoration(
                            labelText: "Select Semester",
                            prefixIcon: Icon(Icons.subject),
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      RadioListTile<UserType>(
                        title: const Text("Teacher"),
                        value: UserType.teacher,
                        groupValue: _userType,
                        onChanged: (value) {
                          setState(() {
                            _userType = value;
                          });
                        },
                      ),
                      RadioListTile<UserType>(
                          title: const Text("Student"),
                          value: UserType.student,
                          groupValue: _userType,
                          onChanged: (value) {
                            setState(() {
                              _userType = value;
                            });
                          })
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedCourse != null &&
                          _selectedSemester != null &&
                          _nameController.text != "" &&
                          _collegeNameController.text != "") {
                        if (_formKey.currentState!.validate()) {
                          String userName = _nameController.text;
                          final user = FirebaseAuth.instance.currentUser;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .update({
                            'userName': userName,
                            'userType': _userType.toString(),
                            'collegeName': _collegeNameController.text,
                            'courseName': _selectedCourse,
                            'semester': _selectedSemester,
                            'email': user.email
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SubjectPage()));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              "Enter all details",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: const Text("Save Details"),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
