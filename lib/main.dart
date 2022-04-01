// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'package:zesty/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zesty/bottom_nav_bar.dart';
import 'package:zesty/login.dart';
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

final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleSignInAccount? currentUser;
  void updateCurrentUser(GoogleSignInAccount? newUser) {
    setState(() {
      currentUser = newUser;
    });
  }

  Future<void> checkIfSignedIn() async {
    await googleSignIn.signInSilently();
    if (googleSignIn.currentUser != null) {
      updateCurrentUser(googleSignIn.currentUser);
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return MaterialApp(
        home: Login(
            googleSignIn: googleSignIn,
            currentUser: currentUser,
            updateCurrentUser: updateCurrentUser),
      );
    } else {
      return MaterialApp(
        home: BottomNav(
            googleSignIn: googleSignIn,
            currentUser: currentUser!,
            updateCurrentUser: updateCurrentUser),
      );
    }
  }
}
