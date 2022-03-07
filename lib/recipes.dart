import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zesty/user.dart';

List<String> myIngredients = <String>[];
getIngredients(GoogleSignInAccount? user) async {
  print("got to getIngredients method");
  if (user != null) {
    await FirebaseFirestore.instance.collection('users').doc(user.email)
        .get()
        .then((value) {
          myIngredients = List.from(value.get('ingredients'));
    });
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email'
    ]
);

class recipeFinder extends StatefulWidget {
  const recipeFinder({Key? key}) : super(key: key);

  @override
  _recipeFinderState createState() => _recipeFinderState();
}

class _recipeFinderState extends State<recipeFinder> {
  final _ingredients = <String>[
    "Apples",
    "Avocado",
    "Asparagus",
    "Bananas",
    "Bread",
    "Bacon",
    "Blueberries",
    "Chicken",
    "Cheddar Cheese",
    "Chips Ahoy",
    "Carrots",
  ];
  var _selected = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      getIngredients(user);
      print(myIngredients);

      return Scaffold(
          body: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _ingredients.length,
              itemBuilder: (context, i) {

                return Column(
                  children: <Widget>[
                    ListTile(
                        title: Text(
                          _ingredients[i],
                          style: _biggerFont,
                        ),

                    )
                    //Divider(),
                  ],
                );
              }));
    }
    else {
      return Scaffold(
          body: Text(
            "Loading...",
          )
      );
    }
  }
}
