import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class RecipeFinder extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final Function updateCurrentUser;

  const RecipeFinder({
    Key? key,
    required this.currentUser,
    required this.updateCurrentUser,
  }) : super(key: key);

  @override
  _RecipeFinderState createState() => _RecipeFinderState();
}

class _RecipeFinderState extends State<RecipeFinder> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  var _savedRecipes = <String>[];
  var _myIngredients = <String>[];

  @override
  Widget build(BuildContext context) {
    // Future<List<String>> myIngredients(GoogleSignInAccount? user) {
    //   Future<List<String>> ingredients = FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(user?.email)
    //       .get()
    //       .then((DocumentSnapshot data) {
    //     _savedRecipes = List.from(data.get('savedRecipes'));
    //     return List.from(data.get('ingredients'));
    //   });
    //   return ingredients;
    // }

    Future<List<String>> FindRecipes(GoogleSignInAccount? user) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get()
          .then((DocumentSnapshot data) {
        _savedRecipes = List.from(data.get('savedRecipes'));
        _myIngredients = List.from(data.get('ingredients'));
      });
      Future<List<String>> recipes = FirebaseFirestore.instance
          .collection('Recipes')
          .get()
          .then((QuerySnapshot querySnapShot) {
        List<String> toRet = [];
        querySnapShot.docs.forEach((doc) {
          toRet.add(doc['title']);
        });
        return toRet;
      });
      return recipes;
    }

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2!,
      textAlign: TextAlign.center,
      child: FutureBuilder<List<String>>(
        future: FindRecipes(widget.currentUser),
        // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            if (_myIngredients.isNotEmpty) {
              children = Scaffold(
                  body: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, i) {
                        final String recipeName =
                            snapshot.data?[i] ?? "Could not load recipe";
                        final alreadySelected =
                            _savedRecipes.contains(recipeName);

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
                                      _savedRecipes.remove(recipeName);
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.currentUser.email)
                                          .update({
                                        'savedRecipes':
                                            FieldValue.arrayRemove([recipeName])
                                      });
                                    } else {
                                      _savedRecipes.add(recipeName);
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.currentUser.email)
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
            } else {
              return Center(
                  child:
                      Text('Please Add Some Ingredients', style: _biggerFont));
            }
          } else if (snapshot.hasError) {
            children = Scaffold(
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
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
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
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
  }
}
