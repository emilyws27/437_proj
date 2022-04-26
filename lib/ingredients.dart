import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class IngredientList extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final String ingredientType;
  final bool myIngredients;

  const IngredientList({
    Key? key,
    required this.currentUser,
    this.ingredientType = "My Ingredients",
    required this.myIngredients,
  }) : super(key: key);

  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool searching = false;
  String searchWord = "";
  List<String> myIngredientsList = [];
  List<String> bulkIngredients = [];
  final String addAll = "Add All";
  final String removeAll = "Remove All";
  final String addCommon = "Add Popular Ingredients";
  final String removeCommon = "Remove Popular Ingredients";
  Set<String> addRemoveStringsSet = {};

  //function to get all the users ingredients
  Future<List<String>> getMyIngredients() async {
    Future<List<String>> myIngredients = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUser.email)
        .get()
        .then((DocumentSnapshot snapshot) async {
      List<String> ingredients = [];
      ingredients += List.from(snapshot['ingredients']);
      ingredients.sort();

      return ingredients;
    });

    return myIngredients;
  }

  //function to get the bulk item packages for add all and add all common items capability
  Future<List<String>> getBulkIngredients() async {
    Future<List<String>> bulkIngredientsList = FirebaseFirestore.instance
        .collection('ingredientsBulkAddPackages')
        .doc('all-packages')
        .get()
        .then((DocumentSnapshot snapshot) async {
      List<String> bulkIngredients = [];
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      bulkIngredients.clear();
      if (data.containsKey("Common " + widget.ingredientType)) {
        bulkIngredients += List.from(data["Common " + widget.ingredientType]);
      } else {
        bulkIngredients = [];
      }
      bulkIngredients.sort();
      return bulkIngredients;
    });
    return bulkIngredientsList;
  }

  //function to get ingredients of a specific type and add the bulk packages option
  Future<List<String>> getIngredients(GoogleSignInAccount user) async {
    myIngredientsList = await getMyIngredients();
    bulkIngredients = await getBulkIngredients();

    if (widget.myIngredients == false) {
      Future<List<String>> ingredientNames = FirebaseFirestore.instance
          .collection('ingredients')
          .doc('all_ingredients')
          .get()
          .then((DocumentSnapshot snapshot) async {
        List<String> ingredients = [];
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        ingredients.clear();
        ingredients += List.from(data[widget.ingredientType]);
        ingredients.sort();
        List<String> ingredientsToReturn = [];
        if (bulkIngredients.length > 0) {
          if (myIngredientsList
                  .toSet()
                  .intersection(bulkIngredients.toSet())
                  .length ==
              bulkIngredients.length) {
            ingredientsToReturn = [removeCommon] + ingredients;
          } else {
            ingredientsToReturn = [addCommon] + ingredients;
          }
        } else {
          ingredientsToReturn = ingredients;
        }
        if (myIngredientsList
                .toSet()
                .intersection(ingredients.toSet())
                .length ==
            ingredients.length) {
          ingredientsToReturn = [removeAll] + ingredientsToReturn;
        } else {
          ingredientsToReturn = [addAll] + ingredientsToReturn;
        }
        return ingredientsToReturn;
      });
      return ingredientNames;
    } else {
      return myIngredientsList;
    }
  }

  @override
  Widget build(BuildContext context) {
    addRemoveStringsSet = {addAll, removeAll, addCommon, removeCommon};

    return Scaffold(
      appBar: AppBar(
        title: !searching
            ? Hero(
                tag: widget.ingredientType,
                child: Text(widget.ingredientType,
                    style: const TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        fontFamily: 'Roboto')),
              )
            : TextField(
                onChanged: (value) {
                  setState(() {
                    searchWord = value;
                    searchWord = value;
                  });
                },
                style: TextStyle(color: Color(0xffe0274a)),
                decoration: InputDecoration(
                    hintText: "Search Ingredient",
                    hintStyle: TextStyle(color: Color(0xffe0274a))),
              ),
        centerTitle: true,
        backgroundColor: Color(0xffe0274a),
        actions: <Widget>[
          searching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      searchWord = "";
                      searching = false;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searching = true;
                    });
                  },
                )
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: getIngredients(widget.currentUser),
        // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          Widget children;
          if (snapshot.hasData) {

            //check that ingredients list is not empty, specifically used for the list of ingredients the user currently has
            if (snapshot.data!.isNotEmpty) {
              List<String> filteredIngredients = [];

              //checking if the search bar is empty or not to filter ingredients the user is looking for
              if (searchWord != "") {
                filteredIngredients = snapshot.data!
                    .where((ingredient) =>
                        ingredient.toLowerCase().contains(searchWord))
                    .toList();
              } else {
                filteredIngredients = snapshot.data!;
              }
              children = Scaffold(
                  body: Scrollbar(
                      child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredIngredients.length,
                          itemBuilder: (context, i) {
                            final ingredientName = filteredIngredients[i];
                            var alreadySelected = myIngredientsList
                                .contains(filteredIngredients[i]);
                            return SizedBox(
                                child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    ingredientName,
                                    style: _biggerFont,
                                  ),
                                  trailing: StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setStateIcon) {
                                    return IconButton(
                                      icon: addRemoveStringsSet
                                              .contains(ingredientName)
                                          ? (ingredientName.contains("Add")
                                              ? Icon(Icons.playlist_add)
                                              : Icon(Icons.playlist_remove))
                                          : alreadySelected
                                              ? Icon(Icons.check)
                                              : Icon(Icons.add),
                                      color: addRemoveStringsSet
                                              .contains(ingredientName)
                                          ? (ingredientName.contains("Add")
                                              ? Color(0xffe0274a)
                                              : Color(0xffe0274a))
                                          : alreadySelected
                                              ? Color(0xffe0274a)
                                              : null,
                                      onPressed: () {

                                        //making sure add all and add all common ingredient type doesn't add to users ingredients
                                        if (addRemoveStringsSet
                                            .contains(ingredientName)) {
                                          setState(() {
                                            if (ingredientName
                                                .contains("Add")) {
                                              if (ingredientName == addAll) {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget
                                                        .currentUser.email)
                                                    .update({
                                                  'ingredients': FieldValue
                                                      .arrayUnion(snapshot.data!
                                                          .toSet()
                                                          .difference(
                                                              addRemoveStringsSet)
                                                          .toList())
                                                });
                                              } else if (ingredientName ==
                                                  addCommon) {
                                                if (bulkIngredients
                                                    .isNotEmpty) {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(widget
                                                          .currentUser.email)
                                                      .update({
                                                    'ingredients':
                                                        FieldValue.arrayUnion(
                                                            bulkIngredients)
                                                  });
                                                }
                                              }
                                            } else {
                                              if (ingredientName == removeAll) {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget
                                                        .currentUser.email)
                                                    .update({
                                                  'ingredients':
                                                      FieldValue.arrayRemove(
                                                          snapshot.data!)
                                                });
                                              } else if (ingredientName ==
                                                  removeCommon) {
                                                if (bulkIngredients
                                                    .isNotEmpty) {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(widget
                                                          .currentUser.email)
                                                      .update({
                                                    'ingredients':
                                                        FieldValue.arrayRemove(
                                                            bulkIngredients)
                                                  });
                                                }
                                              }
                                            }
                                          });
                                        } else {
                                          setStateIcon(() {
                                            if (alreadySelected) {
                                              if (widget.myIngredients ==
                                                  true) {
                                                alreadySelected = false;
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget
                                                        .currentUser.email)
                                                    .update({
                                                  'ingredients':
                                                      FieldValue.arrayRemove(
                                                          [ingredientName])
                                                });
                                              } else {
                                                alreadySelected = false;
                                                myIngredientsList
                                                    .remove(ingredientName);
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget
                                                        .currentUser.email)
                                                    .update({
                                                  'ingredients':
                                                      FieldValue.arrayRemove(
                                                          [ingredientName])
                                                });
                                              }
                                            } else {
                                              alreadySelected = true;
                                              myIngredientsList
                                                  .add(ingredientName);
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(widget.currentUser.email)
                                                  .update({
                                                'ingredients':
                                                    FieldValue.arrayUnion(
                                                        [ingredientName])
                                              });
                                            }
                                          });
                                        }
                                      },
                                    );
                                  }),
                                ),
                                const Divider(),
                              ],
                            ));
                          })));
            } else {
              return const Center(
                  child: Text('You have not added any ingredients',
                      style: TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center));
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
            children = Scaffold();
          }
          return children;
        },
      ),
    );
  }
}
