import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:note_easy_final/pages/home_page.dart';
import 'package:note_easy_final/pages/login_page.dart';
import 'package:note_easy_final/pages/selection_page.dart';
import 'package:note_easy_final/services/upload_file.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final User? user = FirebaseAuth.instance.currentUser;
  String _userName = "";
  String _courseName = "";
  String _semester = "";
  String _userType = "";
  String _selectedCourse = "";
  String _selectedSemester = "";

  final _semesterList = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6"
  ];

  bool teacher() {
    if (_userType == "UserType.teacher") {
      return true;
    } else {
      return false;
    }
  }

  Future<void> changeCourse() async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: ListView(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('CourseList')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
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
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: DropdownButtonFormField<dynamic>(
                                isExpanded: true,
                                items: courseList,
                                value: _courseName,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCourse = value as String;
                                  });
                                },
                                decoration: const InputDecoration(
                                    labelText: "Select Course",
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
                                items: _semesterList.map(
                                  (e) {
                                    return DropdownMenuItem(
                                      child: Text(e),
                                      value: e,
                                    );
                                  },
                                ).toList(),
                                value: _semester,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSemester = value.toString();
                                  });
                                },
                                decoration: const InputDecoration(
                                    labelText: "Select Semester",
                                    prefixIcon: Icon(Icons.subject),
                                    border: OutlineInputBorder()),
                              ),
                            ),
                          ),
                          ElevatedButton(
                              child: const Text("Save Details"),
                              onPressed: () async {
                                if (_selectedCourse != "" &&
                                    _selectedSemester != "") {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user!.uid)
                                      .update({
                                    'courseName': _selectedCourse,
                                    'semester': _selectedSemester,
                                  });
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const SubjectPage()));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text('Select your course and semester'),
                                  ));
                                }
                              }),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        _userName = event.data()!['userName'];
        _courseName = event.data()!['courseName'];
        _semester = event.data()!['semester'];
        _userType = event.data()!['userType'];
      });
    });
    final String? _email = user!.email;
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName:
                  Text(_userName, style: const TextStyle(fontSize: 24)),
              accountEmail:
                  Text("$_email", style: const TextStyle(fontSize: 16)),
              currentAccountPictureSize: const Size.square(42),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 35),
                //Text
              ), //circleAvatar
            ), //UserAccountDrawerHeader
          ), //DrawerHeader
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(" " + _courseName),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                changeCourse();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: Text(" " + _semester),
            onTap: () {
              Navigator.pop(context);
            },
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                changeCourse();
              },
            ),
          ),
          teacher()
              ? ListTile(
                  leading: const Icon(Icons.accessibility),
                  title: const Text(' Teacher '),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              : ListTile(
                  leading: const Icon(Icons.accessibility),
                  title: const Text(' Student '),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
          ListTile(
            leading: const Icon(Icons.upload_file_rounded),
            title: const Text(' Upload Files '),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UploadFilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text(' Edit Profile '),
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SelectionPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(' Developers '),
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text(
                        " Developed by  ",
                        style: TextStyle(fontSize: 20),
                      ),
                      content: Column(
                        children: const [
                          Text(
                            "Aravind",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Sreerag",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Dhanoop",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Fathima Suhana",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Sumayya",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(' LogOut'),
            onTap: () async {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}
