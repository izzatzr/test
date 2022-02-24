// ignore_for_file: invalid_return_type_for_catch_error

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:test/home.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user;
  bool? btnClicked = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _auth.userChanges().listen((event) => setState(() => user = event));
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  setLoading({required Callback onSet}) =>
      ((void _) => onSet()).call(setState(() => btnClicked = !btnClicked!));

  emailPassForm() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Form(
          key: _formKey,
          child: ListView(
              shrinkWrap: true,
              children: List.empty(growable: true)
                ..add(Container(
                    alignment: Alignment.center,
                    child: Text('Login dengan email dan password',
                        style: TextStyle(fontWeight: FontWeight.bold))))
                ..add(TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (String? value) =>
                        value!.isEmpty ? 'Please enter some text' : null))
                ..add(TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: (String? value) =>
                        value!.isEmpty ? 'Please enter some text' : null,
                    obscureText: true))
                ..addIf(
                    btnClicked == false,
                    Container(
                        padding: EdgeInsets.only(top: 16),
                        alignment: Alignment.center,
                        child: SignInButton(Buttons.Email,
                            text: 'Masuk',
                            onPressed: () => setLoading(
                                onSet: () => _formKey.currentState!.validate()
                                    ? _auth
                                        .signInWithEmailAndPassword(
                                            email: _emailController.text,
                                            password: _passwordController.text)
                                        .then((result) => Get.snackbar(
                                                "Success",
                                                '${result.user?.email} signed in')
                                            .future
                                            .then((_) => Get.to(() => Home())))
                                        .catchError((_) => Get.snackbar('Error',
                                            'Failed to sign in with Email & Password'))
                                    : setLoading(onSet: () => null))))))));

  googleSignIn() => ListView(
      shrinkWrap: true,
      children: List.empty(growable: true)
        ..addIf(
            btnClicked == false,
            Container(
                alignment: Alignment.center,
                child: SignInButton(Buttons.GoogleDark,
                    text: 'Gunakan akun Google',
                    onPressed: () => _auth
                        .signInWithPopup(GoogleAuthProvider())
                        .then((result) => ((_) => Get.snackbar('Success',
                                'Sign In ${result.user?.uid} with Google success')
                            .future
                            .then((value) => Get.to(() => Home()))))
                        .catchError((result) => Get.snackbar('Failed',
                            'Failed to sign in with Google: $result'))))));

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text("Login"),
          actions: List.empty(growable: true)
            ..add(Builder(
                builder: (BuildContext context) => TextButton(
                    onPressed: () => _auth.currentUser == null
                        ? Get.showSnackbar(
                            GetSnackBar(message: 'No one has signed in.'))
                        : _auth.signOut().then((value) => Get.showSnackbar(
                            GetSnackBar(
                                message:
                                    '$user.uid has successfully signed out.'))),
                    child: Text('Sign out'))))),
      body: Center(
          child: ListView(
              shrinkWrap: true,
              children: List.empty(growable: true)
                ..add(emailPassForm())
                ..add(Divider())
                ..add(googleSignIn())
                ..addIf(
                    btnClicked, Center(child: CircularProgressIndicator())))));
}
