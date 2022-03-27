import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class IngredientChooser extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final Function updateCurrentUser;

  const IngredientChooser({
    Key? key,
    required this.currentUser,
    required this.updateCurrentUser,
  }) : super(key: key);

  @override
  _IngredientChooserState createState() => _IngredientChooserState();
}

class _IngredientChooserState extends State<IngredientChooser> {

  var _selected = <String>[];
  var allIngredients = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    Future<List<String>> myIngredients(GoogleSignInAccount user) {
      Future<List<String>> ingredients = FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get()
          .then((DocumentSnapshot data) {
        _selected = List.from(data.get('ingredients'));
        return List.from(data.get('ingredients'));
      });
      return ingredients;
    }

    // Future<DocumentSnapshot<Map<String, dynamic>>> allIngredients(GoogleSignInAccount user) {
    //   return FirebaseFirestore.instance
    //       .collection('ingredients')
    //       .doc('all_ingredients')
    //       .get();
    // }

    Future<List<String>> getAllIngredients(GoogleSignInAccount user) {
      myIngredients(user);

      Future<List<String>> ingredients = FirebaseFirestore.instance
          .collection('ingredients')
          .doc('all_ingredients')
          .get()
          .then((DocumentSnapshot snapshot) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        for (String key in data.keys) {
          allIngredients += List.from(data[key]);
        }
        return allIngredients;
      });

      return ingredients;
    }

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2!,
      textAlign: TextAlign.center,
      child: FutureBuilder<List<String>>(
        future: getAllIngredients(widget.currentUser),
        // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            children = Scaffold(
                body: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: allIngredients.length,
                    itemBuilder: (context, i) {
                      final alreadySelected =
                          _selected.contains(allIngredients[i]);

                      return SizedBox(
                          child: Column(
                        children: <Widget>[
                          ListTile(
                              title: Text(
                                allIngredients[i],
                                style: _biggerFont,
                              ),
                              trailing: Icon(
                                alreadySelected
                                    ? Icons.shopping_cart
                                    : Icons.add,
                                color:
                                    alreadySelected ? Colors.lightGreen : null,
                                semanticLabel: alreadySelected
                                    ? "Remove From Inventory"
                                    : "Add To Inventory",
                              ),
                              onTap: () {
                                setState(() {
                                  if (alreadySelected) {
                                    _selected.remove(allIngredients[i]);
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.currentUser.email)
                                        .update({
                                      'ingredients': FieldValue.arrayRemove(
                                          [allIngredients[i]])
                                    });
                                  } else {
                                    _selected.add(allIngredients[i]);
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.currentUser.email)
                                        .update({
                                      'ingredients': FieldValue.arrayUnion(
                                          [allIngredients[i]])
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
    );
  }
}
