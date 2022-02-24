import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:test/home.dart';
import 'package:test/registrasi.dart';
import 'package:test/login.dart';
import 'firebase_options.dart';
import 'package:getxfire/getxfire.dart';

void main() =>
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .then((_) => runApp(GetMaterialApp(
            title: 'Sistem Keamanan Motor',
            debugShowCheckedModeBanner: false,
            home: StreamBuilder<User?>(
                stream: GetxFire.auth.authStateChanges(),
                builder: (context, user) =>
                    user.connectionState != ConnectionState.active
                        ? Center(child: CircularProgressIndicator())
                        : user.data != null || user.hasData
                            ? Home()
                            : AuthTypeSelector()))));

class AuthTypeSelector extends StatelessWidget {
  final List<SignInButtonBuilder> buttons = [
    SignInButtonBuilder(
        icon: Icons.person_add,
        backgroundColor: Colors.blue,
        text: "Registrasi",
        onPressed: () => Get.to(Register())),
    SignInButtonBuilder(
        icon: Icons.verified_user,
        backgroundColor: Colors.blue,
        text: "Login",
        onPressed: () => Get.to(SignInPage()))
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('Aplikasi Autentikasi Sepeda Motor')),
      body: Center(
          child: ListView(
              shrinkWrap: true,
              children: buttons
                  .map((btn) => Padding(
                      padding: EdgeInsets.all(8),
                      child:
                          Container(alignment: Alignment.center, child: btn)))
                  .toList())));
}
