// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'package:zesty/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zesty/bottom_nav_bar.dart';
import 'package:zesty/ingredients.dart';
import 'package:zesty/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp2());
}

// #docregion MyApp
class MyApp extends StatelessWidget {
  static final String title = 'Simulator';
  const MyApp({Key? key}) : super(key: key);

  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zesty',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(0xFF, 0xFE, 0xD9, 0xD9),
          foregroundColor: Colors.black,
        ),
      ),
      home: const BottomNav(),
    );
  }
// #enddocregion build
}

class MyApp2 extends StatelessWidget {
  static final String title = 'Simulator';
  const MyApp2({Key? key}) : super(key: key);

  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zesty',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(0xFF, 0xFE, 0xD9, 0xD9),
          foregroundColor: Colors.black,
        ),
      ),
      home: const Login(),
    );
  }
// #enddocregion build
}
// #enddocregion MyApp

// #docregion RWS-var


