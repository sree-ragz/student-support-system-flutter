import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:note_easy_final/pages/files_page.dart';
import 'package:note_easy_final/services/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../browser/browser_page.dart';
import '../chatbot/chatmain.dart';

// ignore: must_be_immutable
class ModulePage extends StatefulWidget {
  String subject = "";
  String documentId = "";
  ModulePage({Key? key, required this.subject, required this.documentId})
      : super(key: key);

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String _course = "";
  String _semester = "";
  String _userType = "";
  String _selectedModule = "";

  bool teacher() {
    if (_userType == "UserType.teacher") {
      return true;
    } else {
      return false;
    }
  }

  final TextEditingController _moduleController = TextEditingController();

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _moduleController.text = documentSnapshot['module'];
    }
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
              TextField(
                controller: _moduleController,
                decoration: const InputDecoration(
                  labelText: 'Module',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final String module = _moduleController.text;
                    await FirebaseFirestore.instance
                        .collection(_course)
                        .doc(_semester)
                        .collection('Subjects')
                        .doc(widget.documentId)
                        .collection(widget.subject)
                        .doc(documentSnapshot!.id)
                        .update({"module": module});
                    _moduleController.text = "";
                    Navigator.of(context).pop();
                  },
                  child: const Text("Update"))
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(String docId) async {
    await FirebaseFirestore.instance
        .collection(_course)
        .doc(_semester)
        .collection('Subjects')
        .doc(widget.documentId)
        .collection(widget.subject)
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You have successfully deleted a Module"),
      ),
    );
    _moduleController.text = "";
  }

  // ignore: unused_element
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
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
              TextField(
                controller: _moduleController,
                decoration: const InputDecoration(labelText: 'Module'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String module = _moduleController.text;
                  await FirebaseFirestore.instance
                      .collection(_course)
                      .doc(_semester)
                      .collection('Subjects')
                      .doc(widget.documentId)
                      .collection(widget.subject)
                      .add({"module": module});
                  Navigator.of(context).pop();
                  _moduleController.text = "";
                },
                child: const Text("Create"),
              ),
            ],
          ),
        );
      },
    );
  }

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
        _userType = event.data()!['userType'];
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
         actions: [
          IconButton(
            onPressed: (){
             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatMyApp()));
            },
            icon: const Icon(Icons.bubble_chart),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
          // <2> Pass `Stream<QuerySnapshot>` to stream
          stream: FirebaseFirestore.instance
              .collection(_course)
              .doc(_semester)
              .collection('Subjects')
              .doc(widget.documentId)
              .collection(widget.subject)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // <3> Retrieve `List<DocumentSnapshot>' from snapshot
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final QueryDocumentSnapshot<Object?> documents =
                        snapshot.data!.docs[index];
                    return Card(
                      elevation: 5,
                      shadowColor: Colors.deepPurple,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(documents['module']),
                        // delete
                        onTap: () {
                          setState(() {
                            _selectedModule = documents['module'];
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FilePage(
                                    course: _course,
                                    semester: _semester,
                                    subject: widget.subject,
                                    module: _selectedModule,
                                  )));
                        },
                        trailing: teacher()
                            ? SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          _update(documents);
                                        },
                                        icon: const Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () {
                                          _delete(documents.id);
                                        },
                                        icon: const Icon(Icons.delete)),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    );
                  }

                  /*,
                  children: documents
                      .map((doc) => Card(
                            child: ListTile(
                              title: Text(doc['module']),
                            ),
                          ))
                      .toList()
                      */
                  );
            } else if (snapshot.hasError) {
              return const Text('It Error!');
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: teacher()
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                _create();
              },
            )
          : null,
          bottomNavigationBar: GNav(
         
        
        tabs: [
          GButton(
            icon: Icons.home,
            iconColor: Colors.deepPurple,
            textColor: Colors.deepPurple,
            iconActiveColor: Colors.deepPurple,
            iconSize: 35,
            gap:10,
          ),
          GButton(
            icon: Icons.search,
            iconColor: Colors.deepPurple,
            textColor: Colors.deepPurple,
            iconActiveColor: Colors.deepPurple,
            iconSize: 35,
            gap:10,
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => BrowserApp(value: "https://www.google.com/",)));
            },
          ),
          GButton(
            icon: Icons.school_sharp,
            iconColor: Colors.deepPurple,
            textColor: Colors.deepPurple,
            iconActiveColor: Colors.deepPurple,
            iconSize: 35,
            gap:10
          ),
         
        ],
      ),
    );
  }
}
