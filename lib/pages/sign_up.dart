import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_easy_final/auth/validator.dart';
import 'package:note_easy_final/pages/login_page.dart';
import 'package:note_easy_final/pages/selection_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

  final _formKey = GlobalKey<FormState>();

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
    _confirmPasswordVisible = true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                  size: 100,
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
                  key: _formKey,
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
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                    : Icons.visibility_sharp),
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
                            controller: _confirmPasswordController,
                            obscureText: _confirmPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              labelText: 'Confirm Password',
                              suffixIcon: IconButton(
                                icon: Icon(_confirmPasswordVisible
                                    ? Icons.visibility_off_sharp
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                if (passwordConfirmed()) {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );
                                  /*
                              .then((value) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(value.user?.uid)
                                .set({
                              "email": value.user?.email,
                            });
                          });
                          */
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(auth.currentUser!.uid)
                                      .set({
                                    "userName": "userName",
                                    "collegeName": "collegeName",
                                    "courseName": "courseName",
                                    "semester": "semester",
                                    "userType": "userType",
                                    "email": auth.currentUser!.email,
                                  });

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectionPage(),
                                    ),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Column(
                                    children: [
                                      const Text("Failed with Error:"),
                                      Text(e.code.toString()),
                                    ],
                                  ),
                                ));
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
                                "Sign Up",
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign In",
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
        ),
      ),
    );
  }
}
