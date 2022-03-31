import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class IngredientChooser extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final Function updateCurrentUser;
  final String ingredientType;
  final List<String> myIngredients;

  const IngredientChooser({
    Key? key,
    required this.currentUser,
    required this.updateCurrentUser,
    required this.ingredientType,
    required this.myIngredients,
  }) : super(key: key);

  @override
  _IngredientChooserState createState() => _IngredientChooserState();
}

class _IngredientChooserState extends State<IngredientChooser> {
  var ingredients = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    Future<DocumentSnapshot> getIngredients(GoogleSignInAccount user) {
      FirebaseFirestore.instance
          .collection('ingredients')
          .doc('all_ingredients')
          .get()
          .then((DocumentSnapshot snapshot) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        ingredients.clear();
        ingredients += List.from(data[widget.ingredientType]);
        ingredients.sort();
      });

      return FirebaseFirestore.instance
          .collection('ingredients')
          .doc('all_ingredients')
          .get();
    }

    return Scaffold(
        appBar: AppBar(
          title: Hero(
        tag: widget.ingredientType,
        child: Text(widget.ingredientType,
              style: const TextStyle(
                   fontSize: 25, color: Colors.black, fontWeight: FontWeight.normal, decoration: TextDecoration.none, fontFamily: 'Roboto')),),
          centerTitle: true,
          backgroundColor: Colors.amber[900],
        ),
        body: DefaultTextStyle(
          style: Theme.of(context).textTheme.headline2!,
          textAlign: TextAlign.center,
          child: FutureBuilder<DocumentSnapshot>(
            future: getIngredients(widget.currentUser),
            // a previously-obtained Future<String> or null
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              Widget children;
              if (snapshot.hasData) {
                children = Scaffold(
                    body: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: ingredients.length,
                        itemBuilder: (context, i) {
                          final alreadySelected =
                              widget.myIngredients.contains(ingredients[i]);

                          return SizedBox(
                              child: Column(
                            children: <Widget>[
                              ListTile(
                                  title: Text(
                                    ingredients[i],
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
                                        widget.myIngredients
                                            .remove(ingredients[i]);
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.currentUser.email)
                                            .update({
                                          'ingredients': FieldValue.arrayRemove(
                                              [ingredients[i]])
                                        });
                                      } else {
                                        widget.myIngredients
                                            .add(ingredients[i]);
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.currentUser.email)
                                            .update({
                                          'ingredients': FieldValue.arrayUnion(
                                              [ingredients[i]])
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
        ));
  }
}
