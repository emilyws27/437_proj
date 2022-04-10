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
  List<List<DocumentSnapshot>> userSavedRecipes = [];
  List<List<DocumentSnapshot>> allRecipes = [];
  late bool alreadySaved;

  Future<List<List<DocumentSnapshot>>> getSavedRecipes(
      GoogleSignInAccount user) {
    Future<List<List<DocumentSnapshot>>> savedRecipes = FirebaseFirestore
        .instance
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
      List<List<DocumentSnapshot>> toReturn = [];
      toReturn.add(mySavedRecipes);
      return toReturn;
    });
    return savedRecipes;
  }

  Future<List<List<DocumentSnapshot>>> getAllRecipes(
      GoogleSignInAccount user, int numRecipesToReturn) {
    Future<List<List<DocumentSnapshot>>> allRecipes = FirebaseFirestore.instance
        .collection('recipes')
        .get()
        .then((QuerySnapshot querySnapShot) {
      // List<List<DocumentSnapshot>> recipeMatches = new List.filled(4, new List.empty());
      List<DocumentSnapshot> matches0 = [];
      List<DocumentSnapshot> matches1 = [];
      List<DocumentSnapshot> matches2 = [];
      List<DocumentSnapshot> matches3 = [];

      querySnapShot.docs.forEach((recipe) {
        // print("Now checking match for: " + recipe["title"]);
        Set<String> recipeIngredientsSet = new Set();
        for (dynamic x in recipe["ingredients"]) {
          recipeIngredientsSet.add(x["ingredient"]!);
        }
        int intersectionSize =
            _myIngredients.toSet().intersection(recipeIngredientsSet).length;
        // print("Missing " + (recipeIngredientsSet.length - intersectionSize).toString() + " ingredients");
        for (int x in [0, 1, 2, 3]) {
          if (recipeIngredientsSet.length - intersectionSize == x) {
            if (x == 0) matches0.add(recipe);
            if (x == 1) matches1.add(recipe);
            if (x == 2) matches2.add(recipe);
            if (x == 3) matches3.add(recipe);
          }
        }
      });
      List<List<DocumentSnapshot>> recipeMatches = [];
      recipeMatches.addAll([matches0, matches1, matches2, matches3]);
      for (int i in [0, 1, 2, 3]) {
        if (recipeMatches[i].length > numRecipesToReturn) {
          recipeMatches[i] = recipeMatches[i].sublist(0, numRecipesToReturn);
          numRecipesToReturn = 0;
        } else {
          numRecipesToReturn -= recipeMatches[i].length;
        }
      }
      return recipeMatches;
    });
    return allRecipes;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<List<DocumentSnapshot>>> FindRecipes(
        GoogleSignInAccount? user) async {
      userSavedRecipes = await getSavedRecipes(user!);
      if (widget.mySaved == true) {
        return userSavedRecipes;
      } else {
        allRecipes = await getAllRecipes(user, 20);
        return allRecipes;
      }
    }

    return FutureBuilder<List<List<DocumentSnapshot>>>(
        future: FindRecipes(widget.currentUser),
        // a previously-obtained Future<String> or null
        builder: (BuildContext context,
            AsyncSnapshot<List<List<DocumentSnapshot>>> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            // print(snapshot.data);

            List<List<DocumentSnapshot>> data = snapshot.data!;
            children = Scaffold(
                body: Scrollbar(
              child: createList(data[0]),
            ));
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
        });
  }

  Widget createList(List<DocumentSnapshot> data) {
    return
      ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: data.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            // print(i);
            // print(data[i].data());
            final String imageUrl =
                data[i]['imageUrl'] ?? "Could not load image";
            final String recipeName =
                data[i]['title'] ?? "Could not load recipe";
            var alreadySaved = _recipePaths.contains(data[i].reference);

            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 700),
                      pageBuilder: (_, __, ___) => viewRecipe(
                          currentUser: widget.currentUser,
                          recipe: data[i],
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
                      horizontal: 10,
                      vertical: 15,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xffff9b9b),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 5.0, // soften the shadow
                          //spreadRadius: 5.0, //extend the shadow
                          offset: Offset(
                            5.0, // Move to right 10  horizontally
                            5.0, // Move to bottom 10 Vertically
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
                            child: Image.network(imageUrl, fit: BoxFit.contain),
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
                                (BuildContext context, StateSetter setState) {
                              return IconButton(
                                icon: alreadySaved
                                    ? const Icon(Icons.bookmark)
                                    : const Icon(Icons.bookmark_border),
                                iconSize: 40,
                                color:
                                    alreadySaved ? Colors.yellowAccent : null,
                                onPressed: () {
                                  setState(() {
                                    if (alreadySaved) {
                                      alreadySaved = false;
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.currentUser.email)
                                          .update({
                                        'savedRecipes': FieldValue.arrayRemove(
                                            [data[i].reference])
                                      });
                                    } else {
                                      alreadySaved = true;
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.currentUser.email)
                                          .update({
                                        'savedRecipes': FieldValue.arrayUnion(
                                            [data[i].reference])
                                      });
                                    }
                                  });
                                },
                              );
                            })),
                      ],
                    )));
          });
  }
}
