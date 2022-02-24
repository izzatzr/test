// ignore_for_file: invalid_return_type_for_catch_error, must_be_immutable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:test/home.dart';

class Register extends StatefulWidget {
  Register();

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool? success = false;
  String userEmail = '';
  bool loading = false;

  setLoading({required Callback onSet}) =>
      ((void _) => onSet()).call(setState(() => loading = !loading));

  Future<void> _signInWithGoogle() => setLoading(
      onSet: () => auth
          .signInWithPopup(GoogleAuthProvider())
          .then((creds) => uploaddata(creds.user!.uid).then((_) => Get.snackbar(
                  'Registrasi',
                  'Berhasil mendaftarkan pengguna ${creds.user!.email} ')
              .future
              .then((value) => Get.to(Home()))))
          .catchError((onError) =>
              Get.snackbar('Error', 'Failed to sign in with Google: $e')));

  Future<void> _register() => setLoading(
      onSet: () => auth
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text)
          .then((e) => e.user != null
              ? ((_) =>
                  uploaddata(e.user!.uid)
                      .then((_) => Get.to(Home()))).call(
                  Get.snackbar('Registrasi', 'Berhasil mendaftarkan pengguna'))
              : success = false));

  Future<void> uploaddata(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).set({
        'Sistem Keamanan Android': false,
        'Sistem Keamanan Motor': false,
        'Foto': '',
        'Kode Unik': int.parse(
            List.generate(6, (index) => Random().nextInt(9)).join().toString())
      });

  List<Widget> buttons() => [
        SignInButtonBuilder(
            icon: Icons.person_add,
            backgroundColor: Colors.blueGrey,
            onPressed: () => _register(),
            text: 'Register'),
        SignInButton(Buttons.GoogleDark,
            text: 'Sign In', onPressed: () => _signInWithGoogle())
      ];

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text("Registrasi")),
      body: Form(
          key: formKey,
          child: Center(
              child: ListView(
                  shrinkWrap: true,
                  children: List.empty(growable: true)
                    ..add(Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: TextFormField(
                            controller: email,
                            decoration: InputDecoration(labelText: 'Email'),
                            validator: (String? value) => value!.isEmpty
                                ? "please enter some text"
                                : null)))
                    ..add(Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: TextFormField(
                            controller: password,
                            decoration: InputDecoration(labelText: 'Password'),
                            validator: (String? value) =>
                                (value == null || value.isEmpty)
                                    ? 'Please enter some text'
                                    : null,
                            obscureText: true)))
                    ..addIf(
                        loading,
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator())))
                    ..addAllIf(
                        loading == false,
                        buttons().map((e) => Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                                alignment: Alignment.center, child: e))))
                    ..add(Container(
                        alignment: Alignment.center,
                        child: Text(!success!
                            ? ''
                            : success!
                                ? 'Successfully registered $userEmail'
                                : 'Registration failed')))))));
}
