import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class IngredientList extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final String ingredientType;
  final List<String> myIngredientsList;

  const IngredientList({
    Key? key,
    required this.currentUser,
    required this.ingredientType,
    required this.myIngredientsList,
  }) : super(key: key);

  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    Future<List<String>> getIngredients(GoogleSignInAccount user) async {
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

        return ingredients;
      });

      return ingredientNames;
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
                    child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, i) {
                          final alreadySelected =
                              widget.myIngredientsList.contains(snapshot.data?[i]);

                          return SizedBox(
                              child: Column(
                            children: <Widget>[
                              ListTile(
                                  title: Text(
                                    snapshot.data![i],
                                    style: _biggerFont,
                                  ),
                                  trailing: Icon(
                                    alreadySelected
                                        ? Icons.shopping_cart
                                        : Icons.add,
                                    color: alreadySelected
                                        ? Colors.lightGreen
                                        : null,
                                    semanticLabel: alreadySelected
                                        ? "Remove From Inventory"
                                        : "Add To Inventory",
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (alreadySelected) {
                                        widget.myIngredientsList
                                            .remove(snapshot.data![i]);
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.currentUser.email)
                                            .update({
                                          'ingredients': FieldValue.arrayRemove(
                                              [snapshot.data![i]])
                                        });
                                      } else {
                                        widget.myIngredientsList
                                            .add(snapshot.data![i]);
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.currentUser.email)
                                            .update({
                                          'ingredients': FieldValue.arrayUnion(
                                              [snapshot.data![i]])
                                        });
                                      }
                                    });
                                  }),
                              const Divider(),
                            ],
                          ));
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
