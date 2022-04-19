import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zesty/recipe_details.dart';

class RecipeFinder extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final bool mySaved;

  const RecipeFinder({
    Key? key,
    required this.currentUser,
    required this.mySaved,
  }) : super(key: key);

  @override
  _RecipeFinderState createState() => _RecipeFinderState();
}

class _RecipeFinderState extends State<RecipeFinder> {
  var _recipePaths = <DocumentReference>[];
  var _myIngredients = <String>[];
  List<DocumentSnapshot> userSavedRecipes = [];
  List<DocumentSnapshot> allRecipes = [];
  late bool alreadySaved;

  Future<List<DocumentSnapshot>> getSavedRecipes(GoogleSignInAccount user) {
    Future<List<DocumentSnapshot>> savedRecipes = FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .get()
        .then((DocumentSnapshot data) async {
      _myIngredients = List.from(data.get('ingredients'));

      List<DocumentSnapshot> mySavedRecipes = [];
      _recipePaths = List.from(data.get('savedRecipes'));
      for (DocumentReference path in _recipePaths) {
        await path.get().then((DocumentSnapshot recipeData) {
          mySavedRecipes.add(recipeData);
        });
      }
      return mySavedRecipes;
    });
    return savedRecipes;
  }

  Future<List<DocumentSnapshot>> getAllRecipes(GoogleSignInAccount user) {
    Future<List<DocumentSnapshot>> allRecipes = FirebaseFirestore.instance
        .collection('recipes')
        .get()
        .then((QuerySnapshot querySnapShot) {
      List<DocumentSnapshot> recipeMatch = [];

      querySnapShot.docs.forEach((recipe) {
        if (recipe['ingredients'].every((ingredient) =>
            _myIngredients.contains(ingredient['ingredient']))) {
          recipeMatch.add(recipe);
        }
      });

      return recipeMatch;
    });

    return allRecipes;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<DocumentSnapshot>> FindRecipes(
        GoogleSignInAccount? user) async {
      userSavedRecipes = await getSavedRecipes(user!);

      if (widget.mySaved == true) {
        return userSavedRecipes;
      } else {
        allRecipes = await getAllRecipes(user);
        return allRecipes;
      }
    }

    return FutureBuilder<List<DocumentSnapshot>>(
      future: FindRecipes(widget.currentUser),
      // a previously-obtained Future<String> or null
      builder: (BuildContext context,
          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        Widget children;
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            children = Scaffold(
                body: Scrollbar(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, i) {
                          final String imageUrl = snapshot.data?[i]
                                  ['imageUrl'] ??
                              "Could not load image";
                          final String recipeName = snapshot.data?[i]
                                  ['title'] ??
                              "Could not load recipe";
                          var alreadySaved = _recipePaths
                              .contains(snapshot.data![i].reference);

                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 700),
                                    pageBuilder: (_, __, ___) => viewRecipe(
                                        currentUser: widget.currentUser,
                                        recipe: snapshot.data![i],
                                        number: i),
                                    transitionsBuilder: (BuildContext context,
                                        Animation<double> animation,
                                        Animation<double> secondaryAnimation,
                                        Widget child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffff9b9b),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 1.0, // soften the shadow
                                        //spreadRadius: 5.0, //extend the shadow
                                        offset: Offset(
                                          2.0, // Move to right 10  horizontally
                                          2.0, // Move to bottom 10 Vertically
                                        ),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Hero(
                                        tag: 'recipe' + i.toString(),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              topLeft: Radius.circular(20)),
                                          child: Image.network(imageUrl,
                                              fit: BoxFit.contain),
                                        ),
                                      ),
                                      ListTile(
                                          title: Text(
                                            recipeName,
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                                fontFamily: 'Roboto'),
                                            textAlign: TextAlign.left,
                                          ),
                                          trailing: StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter setState) {
                                            return IconButton(
                                              icon: alreadySaved
                                                  ? const Icon(Icons.bookmark)
                                                  : const Icon(
                                                      Icons.bookmark_border),
                                              iconSize: 40,
                                              color: alreadySaved
                                                  ? Color(0xffe0274a)
                                                  : null,
                                              onPressed: () {
                                                setState(() {
                                                  if (alreadySaved) {
                                                    alreadySaved = false;
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(widget
                                                            .currentUser.email)
                                                        .update({
                                                      'savedRecipes': FieldValue
                                                          .arrayRemove([
                                                        snapshot
                                                            .data![i].reference
                                                      ])
                                                    });
                                                  } else {
                                                    alreadySaved = true;
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(widget
                                                            .currentUser.email)
                                                        .update({
                                                      'savedRecipes': FieldValue
                                                          .arrayUnion([
                                                        snapshot
                                                            .data![i].reference
                                                      ])
                                                    });
                                                  }
                                                });
                                              },
                                            );
                                          })),
                                    ],
                                  )));
                        })));
          } else {
            if (widget.mySaved == true) {
              return const Center(
                  child: Text('You have not saved any recipes yet',
                      style: TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center));
            } else {
              return const Center(
                  child: Text(
                      'No recipes match your ingredients. Please add some more ingredients',
                      style: TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center));
            }
          }
        } else if (snapshot.hasError) {
          children = Scaffold(
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Color(0xffe0274a),
                  size: 60,
                ),
                Center(
                  child: Text('Error: Please Reload Page'),
                )
              ]));
        } else {
          children = Scaffold(
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Center(
                  child: Text('Loading...', style: TextStyle(fontSize: 20.0)),
                )
              ]));
        }
        return children;
      },
    );
  }
}
