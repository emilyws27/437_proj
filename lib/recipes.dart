import 'dart:async';
// import 'dart:collection';
// import 'dart:html';
// import 'dart:math';

// import 'dart:html';
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
  final matchSectionTitles = [
    "Ready to Make",
    "Missing 1 Ingredient",
    "Missing 2 Ingredients",
    "Missing 3 Ingredients",
    "Popular Recipes"
  ];
  bool shouldFilterByDishType = true;
  String dishType = "Main Course";
  final dishTypes = [
    "Appetizer",
    "Beverage",
    "Bread",
    "Dessert",
    "Main Course",
    "Other",
    "Salad",
    "Soup"
  ];
  bool shouldTruncateByMaxResults = true;
  int maxRecipesToReturn = 20;
  bool shouldFilterByServings = false;
  int minServings = 10;
  bool shouldFilterByCalories = false;
  int maxCalories = 500;
  bool isCaloriesFilterApplied = false;
  bool isDishTypeFilterApplied = false;
  bool isServingsFilterApplied = false;
  double _currentCaloriesSliderValue = 2000;
  double _currentServingsSliderValue = 12;

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

  List<List<DocumentSnapshot>> filterRecipesByDishType(
      List<List<DocumentSnapshot>> recipes) {
    List<List<DocumentSnapshot>> toReturn = List.generate(4, (index) => []);
    for (int i = 0; i < recipes.length; ++i) {
      for (int j = 0; j < recipes[i].length; ++j) {
        if (recipes[i][j].get("dishType") == dishType) {
          toReturn[i].add(recipes[i][j]);
        }
      }
    }
    return toReturn;
  }

  List<List<DocumentSnapshot>> truncateRecipesByMaxResults(
      List<List<DocumentSnapshot>> recipes) {
    // bool testIncompleteMatches = false;
    // if(testIncompleteMatches){
    //   recipes[0] = recipes[0].sublist(0, min(3, recipes[0].length));
    //   recipes[1] = recipes[1].sublist(0, min(3, recipes[1].length));
    //   recipes[2] = recipes[2].sublist(0, min(3, recipes[2].length));
    //   recipes[3] = recipes[3].sublist(0, min(3, recipes[3].length));
    // }
    int numRecipesToReturn = maxRecipesToReturn;
    for (int i in [0, 1, 2, 3]) {
      //, 4]) {
      if (recipes[i].length > numRecipesToReturn) {
        recipes[i] = recipes[i].sublist(0, numRecipesToReturn);
        numRecipesToReturn = 0;
      } else {
        numRecipesToReturn -= recipes[i].length;
      }
    }
    return recipes;
  }

  List<List<DocumentSnapshot>> filterRecipesByServings(
      List<List<DocumentSnapshot>> recipes) {
    List<List<DocumentSnapshot>> toReturn = List.generate(4, (index) => []);
    for (int i = 0; i < recipes.length; ++i) {
      for (int j = 0; j < recipes[i].length; ++j) {
        if (int.parse(recipes[i][j].get("servings")) >= minServings) {
          toReturn[i].add(recipes[i][j]);
        }
      }
    }
    return toReturn;
  }

  List<List<DocumentSnapshot>> filterRecipesByCalories(
      List<List<DocumentSnapshot>> recipes) {
    List<List<DocumentSnapshot>> toReturn = List.generate(4, (index) => []);
    for (int i = 0; i < recipes.length; ++i) {
      for (int j = 0; j < recipes[i].length; ++j) {
        String calories = "";
        dynamic nutritionInfo = recipes[i][j].get("nutritionInformation");
        for (int k = 0; k < nutritionInfo.length; k++) {
          if (nutritionInfo[k].containsValue("Calories")) {
            calories = nutritionInfo[k]["amount"]!;
          }
        }
        if (calories != "") {
          if (double.parse(calories) <= maxCalories) {
            toReturn[i].add(recipes[i][j]);
          }
        }
      }
    }
    return toReturn;
  }

  // List<DocumentSnapshot> sortRecipesByPopularity(List<DocumentSnapshot> recipes){
  //   recipes.sort((a, b)=> int.parse(a.get("likes")) - int.parse(b.get("likes")));
  //   return recipes;
  // }

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
      return recipeMatches;
    });
    return allRecipes;
  }

  Future<List<DocumentSnapshot>> getPopularRecipes() {
    Future<List<DocumentSnapshot>> popularRecipes = FirebaseFirestore.instance
        .collection('recipes')
        .get()
        .then((QuerySnapshot querySnapShot) {
      List<DocumentSnapshot> data = querySnapShot.docs;
      data.sort((a, b) => b.get("likes").compareTo(a.get("likes"))); //{
      return data.sublist(0, maxRecipesToReturn);
    });
    return popularRecipes;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<List<DocumentSnapshot>>> FindRecipes(
        GoogleSignInAccount? user) async {
      userSavedRecipes = await getSavedRecipes(user!);
      List<List<DocumentSnapshot>> toReturn;
      if (widget.mySaved == true) {
        toReturn = userSavedRecipes;
      } else {
        allRecipes = await getAllRecipes(user, maxRecipesToReturn);
        toReturn = allRecipes;
      }
      if (shouldFilterByDishType) {
        toReturn = filterRecipesByDishType(toReturn);
      }
      if (shouldFilterByServings) {
        toReturn = filterRecipesByServings(toReturn);
      }
      if (shouldFilterByCalories) {
        toReturn = filterRecipesByCalories(toReturn);
      }

      if (!widget.mySaved) {
        toReturn.add([]);
        toReturn[4] = await getPopularRecipes();
      }
      //truncate to max results should always be last
      if (shouldTruncateByMaxResults) {
        toReturn = truncateRecipesByMaxResults(toReturn);
      }
      return toReturn;
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
            children = SingleChildScrollView(
                child: createLists(data, matchSectionTitles));
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

  Widget createLists(
      List<List<DocumentSnapshot>> data, List<String> sectionTitles) {
    Widget toReturn = Column(children: [
      Filters(),
      data[0].length > 0
          ? createList(data[0], sectionTitles[0], "0")
          : Container(),
      !widget.mySaved
          ? data[1].length > 0
              ? createList(data[1], sectionTitles[1], "1")
              : Container()
          : Container(),
      !widget.mySaved
          ? data[2].length > 0
              ? createList(data[2], sectionTitles[2], "2")
              : Container()
          : Container(),
      !widget.mySaved
          ? data[3].length > 0
              ? createList(data[3], sectionTitles[3], "3")
              : Container()
          : Container(),
      !widget.mySaved
          ? data[4].length > 0
              ? createList(data[4], sectionTitles[4], "4+")
              : Container()
          : Container(),
    ]);
    return toReturn;
  }

  Widget Filters() {
    return Column(children: <Widget>[
      ExpansionTile(title: Text('Add a Filter'), children: <Widget>[
        Text("Dish Type"),
        Checkbox(
          checkColor: Colors.white,
          //fillColor: MaterialStateProperty.resolveWith(getColor),
          value: isDishTypeFilterApplied,
          onChanged: (bool? value) {
            setState(() {
              isDishTypeFilterApplied = value!;
            });
          },
        ),
         Text("# of Calories"),
         Slider(
           value: _currentCaloriesSliderValue,
           max: 2000,
           divisions: 200,
           label: _currentCaloriesSliderValue.round().toString(),
           onChanged: (double value) {
             setState(() {
               _currentCaloriesSliderValue = value;
             });
           },
         ),
        Text("# of Servings"),
        Slider(
          value: _currentServingsSliderValue,
          max: 12,
          divisions: 12,
          label: _currentServingsSliderValue.round().toString(),
          onChanged: (double value) {
            setState(() {
              _currentServingsSliderValue = value;
            });
          },
        ),
      ]
          // Text("Filter by Dish Type"),



          ),
    ]);

    // return Column(children: [
  }

  Widget createHeader(String title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      padding: const EdgeInsets.all(5.0),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xffe0274a),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 1.0, // soften the shadow
            //spreadRadius: 5.0, //extend the shadow
            offset: Offset(
              1.0, // Move to right 10  horizontally
              1.0, // Move to bottom 10 Vertically
            ),
          )
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16.0,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
            color: Colors.white,
            fontFamily: 'Dosis'),
        textScaleFactor: 2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget createList(
      List<DocumentSnapshot> data, String title, String num_missing) {
    bool _expanded = false;
    Widget toReturn = Column(children: [
      !widget.mySaved ? createHeader(title) : Container(),
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          itemCount: data.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, i) {
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
                          number: i,
                          num_missing_ingr: num_missing),
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
                    margin: const EdgeInsets.fromLTRB(
                      0,
                      5,
                      0,
                      5,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xffff9b9b),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 2.0, // soften the shadow
                          //spreadRadius: 5.0, //extend the shadow
                          offset: Offset(
                            1.0, // Move to right 10  horizontally
                            1.0, // Move to bottom 10 Vertically
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
                                  fontFamily: 'Dosis'),
                              textAlign: TextAlign.left,
                            ),
                            trailing: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return IconButton(
                                icon: alreadySaved
                                    ? const Icon(Icons.bookmark)
                                    : const Icon(Icons.bookmark_border),
                                iconSize: 40,
                                color: alreadySaved ? Colors.white : null,
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
                                      String recipeDocName = data[i]
                                          .reference
                                          .toString()
                                          .split("/")[1];
                                      recipeDocName = recipeDocName.substring(
                                          0, recipeDocName.length - 1);
                                      FirebaseFirestore.instance
                                          .collection('recipes')
                                          .doc(recipeDocName)
                                          .update({
                                        "likes": FieldValue.increment(-1)
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
                                      String recipeDocName = data[i]
                                          .reference
                                          .toString()
                                          .split("/")[1];
                                      recipeDocName = recipeDocName.substring(
                                          0, recipeDocName.length - 1);
                                      FirebaseFirestore.instance
                                          .collection('recipes')
                                          .doc(recipeDocName)
                                          .update({
                                        "likes": FieldValue.increment(1)
                                      });
                                    }
                                  });
                                },
                              );
                            })),
                      ],
                    )));
          })
    ]);
    return toReturn;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  bool _expanded = false;
  var _test = "Full Screen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          margin: EdgeInsets.all(10),
          color: Colors.green,
          child: ExpansionPanelList(
            animationDuration: Duration(milliseconds: 500),
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      'Click To Expand',
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                },
                body: Text("hello!"),
                isExpanded: _expanded,
                canTapOnHeader: true,
              ),
            ],
            dividerColor: Colors.grey,
            expansionCallback: (panelIndex, isExpanded) {
              _expanded = !_expanded;
              setState(() {});
            },
          ),
        ),
      ]),
    );
  }
}
