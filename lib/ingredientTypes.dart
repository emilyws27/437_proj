import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zesty/ingredients.dart';

class IngredientTypeList extends StatefulWidget {
  final GoogleSignInAccount currentUser;

  const IngredientTypeList({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  _IngredientTypeListState createState() => _IngredientTypeListState();
}

class _IngredientTypeListState extends State<IngredientTypeList> {
  final TextEditingController searchWord = TextEditingController();
  var myIngredientsList = <String>[];
  var ingredientTypesNames = <String>[];

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

    Future<DocumentSnapshot> getIngredientTypes(
        GoogleSignInAccount user) async {
      myIngredientsList = await getMyIngredients(user);

      await FirebaseFirestore.instance
          .collection('ingredients')
          .doc('all_ingredients')
          .get()
          .then((DocumentSnapshot snapshot) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        ingredientTypesNames.clear();
        for (String key in data.keys) {
          ingredientTypesNames.add(key);
        }
        ingredientTypesNames.sort();
      });

      return FirebaseFirestore.instance
          .collection('ingredients')
          .doc('all_ingredients')
          .get();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: getIngredientTypes(widget.currentUser),
      // a previously-obtained Future<String> or null
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget children;
        if (snapshot.hasData) {
          if (searchWord.text.isEmpty) {
            children = Scaffold(
                body: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: TextField(
                  controller: searchWord,
                  decoration: InputDecoration(
                    labelText: 'Search Ingredient',
                    labelStyle: TextStyle(fontSize: 18),
                    suffixIcon: searchWord.text.isEmpty
                        ? Icon(Icons.search)
                        : IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              searchWord.clear();
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchWord.text = value;
                    });
                  },
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: ingredientTypesNames.length,
                      itemBuilder: (context, i) {
                        return SizedBox(
                            child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Hero(
                                tag: ingredientTypesNames[i],
                                child: Text(
                                  ingredientTypesNames[i],
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontFamily: 'Roboto'),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(milliseconds: 700),
                                      pageBuilder: (_, __, ___) =>
                                          IngredientList(
                                        currentUser: widget.currentUser,
                                        ingredientType: ingredientTypesNames[i],
                                        myIngredients: false,
                                      ),
                                      transitionsBuilder: (BuildContext context,
                                          Animation<double> animation,
                                          Animation<double> secondaryAnimation,
                                          Widget child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ));
                              },
                            ),
                            const Divider(),
                          ],
                        ));
                      })),
            ]));
          } else {
            List<String> filteredIngredients = [];

            Map<String, dynamic> ingredientMap =
                snapshot.data?.data() as Map<String, dynamic>;

            ingredientMap.forEach((key, value) {
              filteredIngredients += List<String>.from(value
                  .where((ingredient) => ingredient
                      .toString()
                      .toLowerCase()
                      .contains(searchWord.text))
                  .toList());
            });

            return children = Scaffold(
              body: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: TextField(
                    controller: searchWord,
                    decoration: InputDecoration(
                      labelText: 'Search Ingredient',
                      labelStyle: TextStyle(fontSize: 18),
                      suffixIcon: searchWord.text.isEmpty
                          ? Icon(Icons.search)
                          : IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                searchWord.clear();
                                setState(() {});
                              },
                            ),
                    ),
                    onChanged: (value) {
                      setState(() {
                      });
                    },
                  ),
                ),
                Expanded(
                    child: Scrollbar(
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
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    trailing: StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setStateIcon) {
                                      return IconButton(
                                        icon: alreadySelected
                                            ? Icon(Icons.shopping_cart)
                                            : Icon(Icons.add),
                                        color: alreadySelected
                                            ? Color(0xffffba97)
                                            : null,
                                        onPressed: () {
                                          setStateIcon(() {
                                            if (alreadySelected) {
                                              alreadySelected = false;
                                              myIngredientsList
                                                  .remove(ingredientName);
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(widget.currentUser.email)
                                                  .update({
                                                'ingredients':
                                                    FieldValue.arrayRemove(
                                                        [ingredientName])
                                              });
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
                                        },
                                      );
                                    }),
                                  ),
                                  const Divider(),
                                ],
                              ));
                            }))),
              ]),
            );
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
                  child: Text('Loading...', style: TextStyle(fontSize: 18)),
                )
              ]));
        }
        return children;
      },
    );
  }
}
