import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadFilePage extends StatefulWidget {
/*  String subjectId = "";
  String subject = "";
  String moduleId = "";
  String module = "";
  , required this.subjectId,required this.subject,required this.moduleId,required this.module
  */
  const UploadFilePage({Key? key}) : super(key: key);

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  String _selectedCourse = "";
  String _selectedSemester = "";
  String _selectedSubject = "";
  String _selectedModule = "";
  File? file;

  final _semesterList = [
    "Semester_1",
    "Semester_2",
    "Semester_3",
    "Semester_4",
    "Semester_5",
    "Semester_6"
  ];

  final _moduleList = [
    "Module 1",
    "Module 2",
    "Module 3",
    "Module 4",
  ];

  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );

    if (result == null) {
      return;
    }
    setState(() {
      pickedFile = result.files.first;
    });
  }

  int? number;
  String url = "";
  uploadData() async {
    number = Random().nextInt(18);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    File pick = File(result!.files.single.path.toString());
    var file = pick.readAsBytesSync();
    String name = DateTime.now().millisecondsSinceEpoch.toString();
    var pdfFile = FirebaseStorage.instance.ref().child(name).child('/.pdf');
    UploadTask task = pdfFile.putData(file);
    TaskSnapshot snapshot = await task;
    url = await snapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('files')
        .doc()
        .set({'fileUrl': url, 'name': "book#" + number.toString()});
  }

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
  }

  final User? user = FirebaseAuth.instance.currentUser;
  String? _course = "";
  String? _semester = "";

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        _course = event.data()!['courseName'];
        _semester = event.data()!['semester'];
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Files'),
      ),
      body: Container(
        child: Form(
          child: Column(
            children: [
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
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    items: _moduleList.map(
                      (e) {
                        return DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedModule = value as String;
                      });
                    },
                    dropdownColor: Colors.blueAccent,
                    decoration: const InputDecoration(
                        labelText: "Select Module",
                        prefixIcon: Icon(Icons.subject),
                        border: OutlineInputBorder()),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12)),
                  child: GestureDetector(
                    onTap: () async {
                      print('doubleTap');
                      selectFile();
                    },
                    child: const Center(
                      child: Text(
                        "Select File",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12)),
                  child: GestureDetector(
                    onTap: () async {
                      print('doubleTap');
                      uploadData();
                    },
                    child: const Center(
                      child: Text(
                        "Upload Files",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
