// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'package:zesty/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zesty/bottom_nav_bar.dart';
import 'package:zesty/ingredients.dart';
import 'package:zesty/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const Home());
}

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  GoogleSignInAccount? _currentUser;
  void updateCurrentUser(GoogleSignInAccount? newUser){
    setState((){
      _currentUser = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return MaterialApp(
        title: 'Zesty',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(0xFF, 0xFE, 0xD9, 0xD9),
            foregroundColor: Colors.black,
          ),
        ),
        home: Login(currentUser: _currentUser, updateCurrentUser: updateCurrentUser),
      );
    } else {
      return MaterialApp(
        title: 'Zesty',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(0xFF, 0xFE, 0xD9, 0xD9),
            foregroundColor: Colors.black,
          ),
        ),
        home: BottomNav(currentUser: _currentUser!, updateCurrentUser: updateCurrentUser),
      );
    }
  }
}
