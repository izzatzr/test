// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:test/homepage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ScaffoldSnackbar {
  ScaffoldSnackbar(this._context);
  final BuildContext _context;

  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  final String title = 'Sign In & Out';

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  User? user;

  @override
  void initState() {
    _auth.userChanges().listen(
          (event) => setState(() => user = event),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () async {
                  final User? user = _auth.currentUser;
                  if (user == null) {
                    ScaffoldSnackbar.of(context).show('No one has signed in.');
                    return;
                  }
                  await _signOut();

                  final String uid = user.uid;
                  ScaffoldSnackbar.of(context)
                      .show('$uid has successfully signed out.');
                },
                child: const Text('Sign out'),
              );
            },
          )
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          return ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              _EmailPasswordForm(),
              _OtherProvidersSignInSection(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signOut() async {
    await _auth.signOut();
  }
}

class UpdateUserDialog extends StatefulWidget {
  const UpdateUserDialog({Key? key, this.user}) : super(key: key);

  final User? user;

  @override
  _UpdateUserDialogState createState() => _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  TextEditingController? _nameController;
  TextEditingController? _urlController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user!.displayName);
    _urlController = TextEditingController(text: widget.user!.photoURL);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update profile'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextFormField(
              controller: _nameController,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'displayName'),
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'photoURL'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              validator: (String? value) {
                if (value != null && value.isNotEmpty) {
                  var uri = Uri.parse(value);
                  if (uri.isAbsolute) {
                    return null;
                  }
                  return 'Faulty URL!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.user!.updateDisplayName(_nameController!.text);
            widget.user!.updatePhotoURL(_urlController!.text);

            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        )
      ],
    );
  }

  @override
  void dispose() {
    _nameController!.dispose();
    _urlController!.dispose();
    super.dispose();
  }
}

class _EmailPasswordForm extends StatefulWidget {
  const _EmailPasswordForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Sign in with email and password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (String? value) {
                  if (value!.isEmpty) return 'Please enter some text';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (String? value) {
                  if (value!.isEmpty) return 'Please enter some text';
                  return null;
                },
                obscureText: true,
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: SignInButton(
                  Buttons.Email,
                  text: 'Sign In',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _signInWithEmailAndPassword();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user!;
      ScaffoldSnackbar.of(context).show('${user.email} signed in');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(
                  title: "title",
                )),
      );
    } catch (e) {
      ScaffoldSnackbar.of(context)
          .show('Failed to sign in with Email & Password');
    }
  }
}

class _OtherProvidersSignInSection extends StatefulWidget {
  const _OtherProvidersSignInSection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OtherProvidersSignInSectionState();
}

class _OtherProvidersSignInSectionState
    extends State<_OtherProvidersSignInSection> {
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.empty(growable: true)
                ..add(Container(
                    alignment: Alignment.center,
                    child: Text('Social Authentication',
                        style: TextStyle(fontWeight: FontWeight.bold))))
                ..add(Container(
                    padding: EdgeInsets.only(top: 16),
                    alignment: Alignment.center,
                    child: SignInButton(Buttons.GoogleDark,
                        text: 'Sign In',
                        onPressed: () => _auth
                            .signInWithPopup(GoogleAuthProvider())
                            .then((result) => ((_) => Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => MyHomePage(title: "dwde"))))
                                .call(ScaffoldSnackbar.of(context)
                                  ..show(
                                      'Sign In ${result.user?.uid} with Google success')))
                            .catchError((result) => ScaffoldSnackbar.of(context)
                                .show('Failed to sign in with Google: $result'))))))));
}
