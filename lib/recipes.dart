import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class RecipeFinder extends StatefulWidget {
  const RecipeFinder({Key? key}) : super(key: key);

  @override
  _RecipeFinderState createState() => _RecipeFinderState();
}

class _RecipeFinderState extends State<RecipeFinder> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    print('reached initState');
    print(_currentUser);
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        print('user changed');
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently().then((value) => print("signed in silently"));
  }

  @override
  Widget build(BuildContext context) {
    print(_currentUser);
    GoogleSignInAccount? user = _currentUser;

    if (user != null) {
      List<String> myIngredients = <String>[];
      bool dataRead = false;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get()
          .then((DocumentSnapshot data) {
        dataRead = true;
        myIngredients = List.from(data.get('ingredients'));
      });

      if (myIngredients.isNotEmpty) {
        List<String> recipes = <String>[];
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .get()
            .then((DocumentSnapshot data) {
          recipes = List.from(data.get('title'));
        });

        return Scaffold(
            body: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: recipes.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          recipes[i],
                          style: _biggerFont,
                        ),
                      )
                      //Divider(),
                    ],
                  );
                }));
      } else {
        return Scaffold(
            body: Center(
                child: Text(
          "Please select some recipes",
          style: _biggerFont,
        )));
      }
    } else {
      return Scaffold(
          body: Center(
              child: Text(
        "You're not signed in",
        style: _biggerFont,
      )));
    }
  }
}
