import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zesty/user.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email'
    ]
);

class IngredientChooser extends StatefulWidget {
  const IngredientChooser({Key? key}) : super(key: key);

  @override
  _IngredientChooserState createState() => _IngredientChooserState();
}

class _IngredientChooserState extends State<IngredientChooser> {
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

  //GoogleSignInAccount user = (FirebaseAuth.instance.currentUser) as GoogleSignInAccount;
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
      return Scaffold(
          body: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _ingredients.length,
              itemBuilder: (context, i) {
                final alreadySelected = _selected.contains(_ingredients[i]);

                return Column(
                  children: <Widget>[
                    ListTile(
                        title: Text(
                          _ingredients[i],
                          style: _biggerFont,
                        ),
                        trailing: Icon(
                          alreadySelected ? Icons.shopping_basket : Icons.add,
                          color: alreadySelected ? Colors.lightGreen : null,
                          semanticLabel: alreadySelected
                              ? "Remove From Inventory"
                              : "Add To Inventory",

                        ),
                        onTap: () {
                          setState(() {
                            if (alreadySelected) {
                              _selected.remove(_ingredients[i]);
                              FirebaseFirestore.instance.collection('users')
                                  .doc(user.email)
                                  .update({
                                'ingredients': FieldValue.arrayRemove(
                                    [_ingredients[i]])
                              });
                            }
                            else {
                              _selected.add(_ingredients[i]);
                              FirebaseFirestore.instance.collection('users')
                                  .doc(user.email)
                                  .update({
                                'ingredients': FieldValue.arrayUnion(
                                    [_ingredients[i]])
                              });
                            }
                          });
                        }
                    ),

                    Divider(),
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