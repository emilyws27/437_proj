import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zesty/main.dart';
import 'package:zesty/user.dart';

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
    _currentUser = _googleSignIn.currentUser;
    if (_currentUser == null) {
      _googleSignIn.signInSilently().then((value) {
        _currentUser = _googleSignIn.currentUser;
      });
    }
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
  }

  var _selected = <String>[];

  @override
  Widget build(BuildContext context) {
    Future<List<String>> myIngredients(GoogleSignInAccount? user) {
      Future<List<String>> ingredients = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get()
          .then((DocumentSnapshot data) {
        _selected = List.from(data.get('savedRecipes'));
        print(_selected);
        return List.from(data.get('ingredients'));
      });
      return ingredients;
    }

    Future<List<String>> FindRecipes(GoogleSignInAccount? user) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get()
          .then((DocumentSnapshot data) {
        _selected = List.from(data.get('savedRecipes'));
        print(_selected);
      });
      Future<List<String>> recipes = FirebaseFirestore.instance
          .collection('Recipes')
          .get()
          .then((QuerySnapshot querySnapShot) {
        List<String> toRet = [];
        querySnapShot.docs.forEach((doc) {
          print(doc['title']);
          toRet.add(doc['title']);
        });
        return toRet;
      });
      return recipes;
    }

    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return DefaultTextStyle(
        style: Theme.of(context).textTheme.headline2!,
        textAlign: TextAlign.center,
        child: FutureBuilder<List<String>>(
          future: FindRecipes(user),
          // a previously-obtained Future<String> or null
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            Widget children;
            if (snapshot.hasData) {
              children = Scaffold(
                  body: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, i) {
                        final String recipeName =
                            snapshot.data?[i] ?? "Could not load recipe";
                        final alreadySelected = _selected.contains(recipeName);

                        return SizedBox(
                            child: Column(
                          children: <Widget>[
                            ListTile(
                                title: Text(
                                  recipeName,
                                  style: _biggerFont,
                                ),
                                trailing: Icon(
                                  alreadySelected
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: alreadySelected ? Colors.red : null,
                                  semanticLabel: alreadySelected
                                      ? "Remove From Favorites"
                                      : "Add To Favorites",
                                ),
                                onTap: () {
                                  setState(() {
                                    if (alreadySelected) {
                                      _selected.remove(recipeName);
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.email)
                                          .update({
                                        'savedRecipes':
                                            FieldValue.arrayRemove([recipeName])
                                      });
                                    } else {
                                      _selected.add(recipeName);
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.email)
                                          .update({
                                        'savedRecipes':
                                            FieldValue.arrayUnion([recipeName])
                                      });
                                    }
                                  });
                                }),
                            const Divider(),
                          ],
                        ));
                      }));
            } else if (snapshot.hasError) {
              children = Scaffold(
                  body: Column(children: const <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Error: Please Reload Page'),
                )
              ]));
            } else {
              children = Scaffold(
                  body: Column(children: <Widget>[
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Center(
                  child: Text('Loading...', style: _biggerFont),
                )
              ]));
            }
            return children;
          },
        ),
      );
    } else {
      return Scaffold(
          body: Center(
              child: Column(children: [
        Text(
          "You're not signed in",
          style: _biggerFont,
        ),
        const SizedBox(
          height: 10,
        ),
        const ElevatedButton(
            onPressed: goToLogin,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Sign in', style: TextStyle(fontSize: 30)),
            )),
      ])));
    }
  }
}

Future<void> signIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (e) {
    print('Error signing in $e');
  }
}

goToLogin() async {
  print("go to login");
  runApp(const LoginPage());
}
