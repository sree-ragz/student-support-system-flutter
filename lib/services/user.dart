/*
import 'package:cloud_firestore/cloud_firestore.dart';

Class User {
String userName;
String collegeName;
String courseName;
String semester;
String password;
String email;
DocumentReference reference;

User({
  this.userName,this.collegeName,this.coursename,this.semester,
  this.email,
});
User.fromMap(Map<String, dynamic> map, {this.reference}){
  userName = map["userName"];
  collegName = ["collegeName"];
  courseName =["courseName"];
  semester = ["semester"];
  email = ["email"];
}
User.fromSnapshot(DocumentSnapshot snapshot):
this.fromMap(snapshot.data,reference: snapshot.reference);

toJson(){
  return {
    'userName': userName,
    'collegeName': collegeName,
    'courseName': courseName,
    'semester': semester,
    'email': email,

  };
}
}


*/