// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Stream<DocumentSnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _usersStream,
          builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) =>
              snapshot.hasError
                  ? Text('Something went wrong')
                  : snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator())
                      : snapshot.data!['Sistem Keamanan Android'] == false &&
                              snapshot.data!['Sistem Keamanan Motor'] == true
                          ? SimpleDialog(
                              title: Text("OTP"),
                              children: List.empty(growable: true)
                                ..add(Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextFormField(
                                        controller: TextEditingController())))
                                ..add(Row(
                                    children: List.empty(growable: true)
                                      ..add(TextButton.icon(
                                          onPressed: () => snapshot.data?.reference
                                              .update(
                                                  {'Sistem Keamanan Motor': false})
                                              .then((value) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              Text("Cancel"))))
                                              .catchError((onError) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(content: Text("Failed")))),
                                          icon: Icon(Icons.cancel),
                                          label: Text("Cancel")))
                                      ..add(TextButton.icon(
                                          onPressed: () => null,
                                          icon: Icon(Icons.check),
                                          label: Text("Proceed"))))))
                          : ListView(
                              children: [
                              'Sistem Keamanan Motor',
                              'Sistem Keamanan Android'
                            ]
                                  .map((key) => ListTile(
                                      title: Text(key.toString()),
                                      subtitle:
                                          Text(snapshot.data![key].toString())))
                                  .toList()
                                  .cast<Widget>())),
      floatingActionButton: FloatingActionButton(
          onPressed: () => FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .update({'Sistem Keamanan Android': false, 'Sistem Keamanan Motor': false}),
          tooltip: 'Increment',
          child: const Icon(Icons.add)));
}
