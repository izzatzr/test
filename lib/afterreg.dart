// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

final Color yellow = Color(0xfffbc31b);
final Color orange = Color(0xfffb6900);

class Afterreg extends StatefulWidget {
  @override
  _AfterregState createState() => _AfterregState();
}

class _AfterregState extends State<Afterreg> {
  List<File> _imageFile = [];
  List<PlatformFile> _imageFileWeb = [];

  Future uploadImageToFirebase(BuildContext context) async {
    _imageFile.map((img) async {
      String fileName = basename(img.path);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(File(img.path));
      uploadTask.then((p0) =>
          p0.ref.getDownloadURL().then((value) => print("done: $value")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              height: 360,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0)),
                  gradient: LinearGradient(
                      colors: [orange, yellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight))),
          Container(
            margin: EdgeInsets.only(top: 80),
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text("Uploading Image to Firebase Storage",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontStyle: FontStyle.italic)))),
                SizedBox(height: 20.0),
                Expanded(
                    child: Stack(
                        children: List.empty(growable: true)
                          ..add(Container(
                              height: double.infinity,
                              margin: EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 10.0),
                              child: Row(
                                  children: _imageFileWeb.isNotEmpty ||
                                          _imageFile.isNotEmpty
                                      ? kIsWeb
                                          ? _imageFileWeb
                                              .map((e) => Container(
                                                  child: Image.file(File.fromRawPath(
                                                      e.bytes!))))
                                              .toList()
                                          : _imageFile
                                              .map((e) => Container(
                                                  child:
                                                      Image.file(File(e.path))))
                                              .toList()
                                      : List.empty(growable: true)
                                    ..add(TextButton.icon(
                                        label: Text("pick image"),
                                        icon: Icon(Icons.add_a_photo, size: 50),
                                        onPressed: () => FilePicker.platform
                                                .pickFiles(
                                                    type: FileType.custom,
                                                    allowedExtensions: [
                                                  'jpg',
                                                  'png'
                                                ]).then((value) => setState(() => kIsWeb ? _imageFileWeb = value!.files : _imageFile = value!.paths.map((path) => File(path!)).toList()))))))))),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                    margin: EdgeInsets.only(
                        top: 30, left: 20.0, right: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [yellow, orange]),
                        borderRadius: BorderRadius.circular(30.0)),
                    child: TextButton(
                        onPressed: () => uploadImageToFirebase(context),
                        child: Text("Upload Image",
                            style: TextStyle(fontSize: 20))))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
