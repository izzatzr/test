import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:test/afterreg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool? _success;
  String _userEmail = '';

  Future<void> _signInWithGoogle() async {
    try {
      UserCredential userCredential;

      userCredential = await _auth.signInWithPopup(GoogleAuthProvider());

      final user = userCredential.user;
      uploaddata(user!.uid);
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Register ${user.uid} with Google')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Afterreg()),
      );
    } catch (e) {
      print(e);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: $e'),
        ),
      );
    }
  }

  uploaddata(String uid) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({
        'Sistem Keamanan Android': false,
        'Sistem Keamanan Motor': false,
        'Foto': '',
        'Kode Unik': int.parse(
            List.generate(6, (index) => Random().nextInt(9)).join().toString())
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text("Regisrasi")),
      body: Form(
          key: _formKey,
          child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          obscureText: true,
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: SignInButtonBuilder(
                                icon: Icons.person_add,
                                backgroundColor: Colors.blueGrey,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await _register();
                                  }
                                },
                                text: 'Register')),
                        Container(
                          padding: const EdgeInsets.only(top: 16),
                          alignment: Alignment.center,
                          child: SignInButton(
                            Buttons.GoogleDark,
                            text: 'Sign In',
                            onPressed: () => _signInWithGoogle(),
                          ),
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: Text(_success == null
                                ? ''
                                : (_success!
                                    ? 'Successfully registered $_userEmail'
                                    : 'Registration failed')))
                      ])))));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final User? user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email ?? '';

        uploaddata(user.uid);
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Afterreg()),
      );
    } else {
      _success = false;
    }
  }
}
