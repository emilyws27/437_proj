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
  final GlobalKey<AnimatedListState> _key = GlobalKey();
  List<String> myIngredientsList = [];
  List<String> bulkIngredients = [];

  @override
  Widget build(BuildContext context) {
    Future<List<String>> getMyIngredients(GoogleSignInAccount user) async {
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
        print(bulkIngredients);
        bulkIngredients.sort();
        return bulkIngredients;
      });
      return bulkIngredientsList;
    }

    Future<List<String>> getIngredients(GoogleSignInAccount user) async {
      myIngredientsList = await getMyIngredients(user);
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
          if(myIngredientsList.toSet().intersection(bulkIngredients.toSet()).length == bulkIngredients.length) {
            ingredientsToReturn = ["Remove All Common"] + ingredients;
          }
          else {
            ingredientsToReturn = ["Add All Common"] + ingredients;
          }
          if(myIngredientsList.toSet().intersection(ingredients.toSet()).length == ingredients.length){
            ingredientsToReturn = ["Remove All"] + ingredientsToReturn;
          }
          else {
            ingredientsToReturn = ["Add All"] + ingredientsToReturn;
          }


          return ingredientsToReturn;
        });
        return ingredientNames;
      } else {
        return myIngredientsList;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: widget.ingredientType,
          child: Text(widget.ingredientType,
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  fontFamily: 'Roboto')),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[900],
      ),
      body: FutureBuilder<List<String>>(
        future: getIngredients(widget.currentUser),
        // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            children = Scaffold(
                body: Scrollbar(
                    child: AnimatedList(
                        key: _key,
                        padding: const EdgeInsets.all(16.0),
                        initialItemCount: snapshot.data?.length != null
                            ? snapshot.data!.length
                            : 0,
                        itemBuilder: (_, i, animation) {
                          final ingredientName = snapshot.data![i];
                          final alreadySelected =
                              myIngredientsList.contains(snapshot.data?[i]);
                          return SizeTransition(
                              key: UniqueKey(),
                              sizeFactor: animation,
                              child: SizedBox(
                                  child: Column(
                                children: <Widget>[
                                  ListTile(
                                      title: Text(
                                        ingredientName,
                                        style: _biggerFont,
                                      ),
                                      trailing: Icon(
                                        ingredientName.contains("All") && (ingredientName.contains("Add") || ingredientName.contains("Remove"))
                                        ? (ingredientName.contains("Add") ? Icons.playlist_add : Icons.playlist_remove)
                                        :
                                            alreadySelected
                                                ? Icons.shopping_cart
                                                : Icons.add,
                                        color:
                                        ingredientName.contains("All") && (ingredientName.contains("Add") || ingredientName.contains("Remove"))
                                            ? (ingredientName.contains("Add") ? Colors.blue : Colors.red)
                                            :
                                              alreadySelected
                                                  ? Colors.lightGreen
                                                  : null,
                                        semanticLabel: alreadySelected
                                            ? "Remove From Inventory"
                                            : "Add To Inventory",
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if(ingredientName.contains("All") && (ingredientName.contains("Add") || ingredientName.contains("Remove"))) {
                                            if(ingredientName.contains("Add")) {
                                              if (ingredientName == "Add All") {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget.currentUser.email)
                                                    .update({
                                                  'ingredients':
                                                  FieldValue.arrayUnion(
                                                      snapshot.data!)
                                                });
                                              } else if (ingredientName == "Add All Common") {
                                                if (bulkIngredients.isNotEmpty) {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(
                                                      widget.currentUser.email)
                                                      .update({
                                                    'ingredients':
                                                    FieldValue.arrayUnion(
                                                        bulkIngredients)
                                                  });
                                                }
                                              }
                                            }
                                            else {
                                              if (ingredientName == "Remove All") {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(widget.currentUser.email)
                                                    .update({
                                                  'ingredients':
                                                  FieldValue.arrayRemove(
                                                      snapshot.data!)
                                                });
                                              } else if (ingredientName == "Remove All Common") {
                                                if (bulkIngredients.isNotEmpty) {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(
                                                      widget.currentUser.email)
                                                      .update({
                                                    'ingredients':
                                                    FieldValue.arrayRemove(
                                                        bulkIngredients)
                                                  });
                                                }
                                              }
                                            }

                                          }
                                          else {
                                            if (alreadySelected) {
                                              if (widget.myIngredients ==
                                                  true) {
                                                _key.currentState!.removeItem(i,
                                                    (_, animation) {
                                                  return SizeTransition(
                                                    key: UniqueKey(),
                                                    sizeFactor: animation,
                                                    child: SizedBox(
                                                      child: Column(children: <
                                                          Widget>[
                                                        ListTile(
                                                          title: Text(
                                                            ingredientName,
                                                            style: _biggerFont,
                                                          ),
                                                          trailing: const Icon(
                                                              Icons.add),
                                                        )
                                                      ]),
                                                    ),
                                                  );
                                                },
                                                    duration: const Duration(
                                                        milliseconds: 700));

                                                snapshot.data?.removeAt(i);

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
                                          }
                                        });
                                      }),
                                  const Divider(),
                                ],
                              )));
                        })));
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
