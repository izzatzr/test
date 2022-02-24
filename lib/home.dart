// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_constructors, avoid_returning_null_for_void, avoid_print, avoid_unnecessary_containers

import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:test/main.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<File> _imageFile = [];

  final _pickedImages = <Uint8List>[];

  // Future<void> _pickMultiImages() => ImagePickerWeb.getMultiImagesAsWidget()
  //     .then((images) => ((void _) => images != null
  //             ? setState(() => _pickedImages.addAll(images))
  //             : Get.snackbar("Error", "No File Selected"))
  //         .call(setState(() => _pickedImages.clear())))
  //     .catchError((onError) => Get.snackbar("Error", "No File Selected"));

  final List<String> allowedExt = ['jpg', 'png'];

  final Stream<DocumentSnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  uploadImageToFirebase() => _imageFile.map((img) => FirebaseStorage.instance
      .ref()
      .child('uploads/')
      .putFile(img)
      .then((p0) =>
          p0.ref.getDownloadURL().then((value) => print("done: $value"))));

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text("Face Recognition")),
      drawer: Drawer(
          child: ListView(
              children: List.empty(growable: true)
                ..add(UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(
                            FirebaseAuth.instance.currentUser?.photoURL ??
                                "https://picsum.photos/200/300")),
                    accountName: Text(
                        FirebaseAuth.instance.currentUser?.displayName ??
                            "User"),
                    accountEmail:
                        Text(FirebaseAuth.instance.currentUser?.email ?? "")))
                ..add(ListTile(
                    onTap: () => showDialog(
                        context: context,
                        builder: (context) => Dialog(
                            child: Center(
                                child: ListView(
                                    children: List.empty(growable: true)
                                      ..add(Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: List.empty(growable: true)
                                            ..addIf(
                                                _pickedImages.isNotEmpty,
                                                AnimatedSwitcher(
                                                    duration: Duration(
                                                        milliseconds: 0),
                                                    switchInCurve:
                                                        Curves.easeIn,
                                                    child: Row(
                                                        children: _pickedImages
                                                            .map((e) =>
                                                                Image.memory(e))
                                                            .toList())))
                                            ..addAllIf(
                                                _imageFile.isNotEmpty &&
                                                    !kIsWeb,
                                                _imageFile
                                                    .map((e) => Container(
                                                        child: Image.file(e)))
                                                    .toList())
                                            ..add(TextButton.icon(
                                                label: Text("pick image"),
                                                icon: Icon(Icons.add_a_photo),
                                                onPressed: () => !kIsWeb
                                                    ? Permission
                                                        .storage.isGranted
                                                        .then((value) => ImagePicker()
                                                            .pickMultiImage()
                                                            .then((value) =>
                                                                setState(() =>
                                                                    _imageFile
                                                                      ..addAll(value!.map((e) => File(e.path)).toList()))))
                                                        .catchError((_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permission denied for storage"))))
                                                    : ImagePickerWeb.getMultiImagesAsBytes().then((value) => setState(() => _pickedImages.addAll(value!)))))))
                                      ..add(TextButton(
                                          onPressed: () => print(_pickedImages
                                              .toList()
                                              .toString()),
                                          child: Text("Upload Image"))))))),
                    leading: Icon(Icons.image),
                    title: Text("Upload Images")))
                ..add(ListTile(
                    onTap: () => FirebaseAuth.instance
                        .signOut()
                        .then((value) => Get.to(AuthTypeSelector())),
                    leading: Icon(Icons.logout),
                    title: Text("Logout"))))),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _usersStream,
          builder: (context, snapshot) => snapshot.hasError
              ? Text('Something went wrong')
              : snapshot.connectionState != ConnectionState.active
                  ? Center(child: CircularProgressIndicator())
                  : !snapshot.hasData && snapshot.data == null
                      ? Center(child: Text("No Data"))
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
                                          onPressed: () => snapshot
                                              .data?.reference
                                              .update({
                                                'Sistem Keamanan Motor': false
                                              })
                                              .then((value) => Get.snackbar(
                                                  'Status', 'Dibatalkan'))
                                              .catchError((onError) =>
                                                  Get.snackbar('Status',
                                                      'Terjadi Gangguan')),
                                          icon: Icon(Icons.cancel),
                                          label: Text("Cancel")))
                                      ..add(TextButton.icon(
                                          onPressed: () => null,
                                          icon: Icon(Icons.check),
                                          label: Text("Proceed"))))))
                          : Center(
                              child: ListView(
                                shrinkWrap: true,
                                  children: [
                              'Sistem Keamanan Motor',
                              'Sistem Keamanan Android'
                            ]
                                      .map((key) => ListTile(
                                          leading: snapshot.data![key]
                                              ? Icon(Icons.check,
                                                  color: Colors.green)
                                              : Icon(Icons.cancel,
                                                  color: Colors.red),
                                          title: Text(key.toString())))
                                      .toList()
                                      .cast<Widget>()))));
}
