import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_easy_final/pages/forgot_screen.dart';
import 'package:note_easy_final/pages/home_page.dart';
import 'package:note_easy_final/pages/sign_up.dart';
import '../auth/validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _passwordVisible = true;
    super.initState();
  }

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.school,
                  size: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  "S Cube!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Student best Companion",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 50),
                Form(
                  key: _key,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white)),
                          child: TextFormField(
                            validator: (value) => Validator.validateEmail(
                              email: value,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white)),
                          child: TextFormField(
                            validator: (value) => Validator.validatePassword(
                              password: value,
                            ),
                            controller: _passwordController,
                            obscureText: _passwordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(_passwordVisible
                                    ? Icons.visibility_off_sharp
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage()));
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: GestureDetector(
                          onTap: () async {
                            if (_key.currentState!.validate()) {
                              try {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SubjectPage()));
                              } on FirebaseAuthException catch (e) {
                                if (e.code == "user-not-found") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                              'No user found for that email')));
                                } else if (e.code == 'wrong-password') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content:
                                              Text('Wrong password provided')));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.code.toString(),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(12)),
                            child: GestureDetector(
                              onTap: () async {
                                await FirebaseAuth.instance.signInAnonymously();
                              },
                              child: const Center(
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      /*
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          await FirebaseAuth.instance.signInAnonymously();
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => SubjectPage()));
                        } on FirebaseAuthException catch (e) {
                          switch (e.code) {
                            case "admin-restriced-operation":
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => SubjectPage()));
                            
                              break;
                            default:
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => SubjectPage()));
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                          child: Text(
                            "Guest Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Doesn't have an account?",
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
