import 'package:flutter/material.dart';
import 'package:note_easy_final/pages/login_page.dart';
import 'package:note_easy_final/pages/sign_up.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  @override
  Widget build(BuildContext context) {
    if (showLoginPage == true) {
      return const LoginPage();
    } else {
      return const SignUpPage();
    }
  }
}
