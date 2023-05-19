import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_easy_final/chatbot/chatmain.dart';
import 'package:note_easy_final/pages/modulePage.dart';
import 'package:note_easy_final/scholarship/scholarship_page.dart';
import 'package:note_easy_final/services/drawer.dart';
import '../browser/browser_page.dart';
import 'login_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({Key? key}) : super(key: key);

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  User? user = FirebaseAuth.instance.currentUser;

  String _course = "";
  String _semester = "";
  String _selectedSubject = "";
  String _userType = "";

  bool teacher() {
    if (_userType == "UserType.teacher") {
      return true;
    } else {
      return false;
    }
  }

  final TextEditingController _subjectController = TextEditingController();

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _subjectController.text = documentSnapshot['subject'];
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
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final String subject = _subjectController.text;
                    if (subject != "") {
                      await FirebaseFirestore.instance
                          .collection(_course)
                          .doc(_semester)
                          .collection('Subjects')
                          .doc(documentSnapshot!.id)
                          .update({"subject": subject});
                      _subjectController.text = "";
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Update"))
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(String productId) async {
    await FirebaseFirestore.instance
        .collection(_course)
        .doc(_semester)
        .collection('Subjects')
        .doc(productId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You have successfully deleted a Subject"),
      ),
    );
    _subjectController.text = "";
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
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String subject = _subjectController.text;
                  if (subject != "") {
                    await FirebaseFirestore.instance
                        .collection(_course)
                        .doc(_semester)
                        .collection('Subjects')
                        .add({"subject": subject});
                  }
                  Navigator.of(context).pop();
                  _subjectController.text = "";
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
        .doc(user?.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        _course = event.data()!['courseName'];
        _semester = event.data()!['semester'];
        _userType = event.data()!['userType'];
      });
    });

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(_course),
            const SizedBox(height: 5),
            Text(
              _semester,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ChatMyApp()));
            },
            icon: const Icon(Icons.bubble_chart),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(_course)
              .doc(_semester)
              .collection('Subjects')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return RefreshIndicator(
                onRefresh: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SubjectPage()));
                },
                child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final QueryDocumentSnapshot<Object?> documents =
                          snapshot.data!.docs[index];
                      return Card(
                        shadowColor: Colors.deepPurple,
                        elevation: 5,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                            title: Text(documents['subject']),
                            onTap: () async {
                              setState(() {
                                _selectedSubject = documents['subject'];
                              });
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ModulePage(
                                        subject: _selectedSubject,
                                        documentId: documents.id,
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
                                : null),
                      );
                    }),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
         activeColor: Color.fromARGB(255, 193, 26, 151),
        
        tabs: [
          GButton(
            icon: Icons.home,
            
            iconColor: Colors.deepPurple,
         
            textColor: Colors.deepPurple,
            iconActiveColor: Colors.deepPurple,
            iconSize: 40,
            gap:10,
          ),
          GButton(
            icon: Icons.search,
           
            iconColor: Colors.deepPurple,
            textColor: Colors.deepPurple,
            iconActiveColor: Colors.deepPurple,
            iconSize: 40 ,
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
            iconSize: 40,
            gap:10,
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Scholarship()));
            },
          ),
         
        ],
      ),
    );
  }
}
