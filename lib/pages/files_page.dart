import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:note_easy_final/services/drawer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../chatbot/chatmain.dart';

// ignore: must_be_immutable
class FilePage extends StatefulWidget {
  String subject = "";
  String module = "";
  String course = "";
  String semester = "";
  FilePage({
    Key? key,
    required this.course,
    required this.semester,
    required this.subject,
    required this.module,
  }) : super(key: key);

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  late Future<ListResult> futureFiles;

  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseStorage.instance.ref('/files').listAll();
  }

  Future downLoadFile(Reference ref) async {
    /*
    final dir = await getApplicationDocumentsDirectory();
    
    final file = File('${dir.path}/${ref.name}');

    await ref.writeToFile(file);
*/
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Downloaded ${ref.name}"),
      ),
    );
  }

  bool teacher() {
    if (_userType == "UserType.teacher") {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _inputController.text = documentSnapshot['name'];
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
                controller: _inputController,
                decoration: const InputDecoration(
                  labelText: 'File Name',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final String name = _inputController.text;

                    String table = widget.course +
                        widget.semester +
                        widget.subject +
                        widget.module;
                    await FirebaseFirestore.instance
                        .collection(table)
                        .doc(documentSnapshot!.id)
                        .update({"name": name});
                    _inputController.text = "";
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
    String table =
        widget.course + widget.semester + widget.subject + widget.module;

    await FirebaseFirestore.instance.collection(table).doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You have successfully deleted the File"),
      ),
    );
    _inputController.text = "";
  }

  final TextEditingController _inputController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  String _userType = "";

  @override
  Widget build(BuildContext context) {
    String table =
        widget.course + widget.semester + widget.subject + widget.module;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        _userType = event.data()!['UserType'];
      });
    });
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Files"),
         actions: [
          IconButton(
            onPressed: (){
             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatMyApp()));
            },
            icon: const Icon(Icons.bubble_chart),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(table).snapshots(),
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
                        title: Text(documents['name']),
                        // delete
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  View(url: documents['fileUrl'])));
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
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          uploadFile();
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Future uploadFile() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextFormField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: '*mention Topic',
                  labelText: 'Topic',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () async {
                    if (_inputController.text != "") {
                      uploadData(_inputController.text);
                    } else if (_inputController.text == "") {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text("Enter the Topic"),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text("Upload Files"))
            ],
          ),
        );
      },
    );
  }

  int? number;
  String url = "";
  uploadData(String topic) async {
    number = Random().nextInt(18);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    File pick = File(result!.files.single.path.toString());
    var file = pick.readAsBytesSync();
    String name = DateTime.now().millisecondsSinceEpoch.toString();
    var pdfFile = FirebaseStorage.instance.ref().child(name).child('/.pdf');
    UploadTask task = pdfFile.putData(file);
    TaskSnapshot snapshot = await task;
    url = await snapshot.ref.getDownloadURL();

    String table =
        widget.course + widget.semester + widget.subject + widget.module;
    await FirebaseFirestore.instance
        .collection(table)
        .doc()
        .set({'fileUrl': url, 'name': topic});
  }
}

// ignore: must_be_immutable
class View extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final url;
  PdfViewerController? _pdfViewerController;
  View({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        actions: [
          IconButton(
              onPressed: () async {
                /*
                await FlutterDownloader.enqueue(
                  url: url,
                  savedDir: '/Storage/emulated/0/Download/',
                  showNotification: true,
                  openFileFromNotification: true,
                );*/
              },
              icon: const Icon(Icons.download_sharp))
        ],
      ),
      body: SfPdfViewer.network(
        url,
        controller: _pdfViewerController,
      ),
    );
  }
/*
  void inti(String url) async {
    final directory = await getExternalStorageDirectory();
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory.toString(),
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
    FlutterDownloader.registerCallback((id, status, progress) {
      print(
          'Download task ($id) is in status ($status) and process ($progress)');
    });
  }*/
}
