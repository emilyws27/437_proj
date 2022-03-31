import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zesty/ingredients.dart';

class IngredientTypeChooser extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final Function updateCurrentUser;

  const IngredientTypeChooser({
    Key? key,
    required this.currentUser,
    required this.updateCurrentUser,
  }) : super(key: key);

  @override
  _IngredientTypeChooserState createState() => _IngredientTypeChooserState();
}

class _IngredientTypeChooserState extends State<IngredientTypeChooser> {
  var myIngredients = <String>[];
  var ingredientTypesNames = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    getMyIngredients(GoogleSignInAccount user) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get()
          .then((DocumentSnapshot data) {
        myIngredients = List.from(data.get('ingredients'));
      });
    }

    // Future<List<String>> getAllIngredients(GoogleSignInAccount user) {
    //   myIngredients(user);
    //
    //   Future<List<String>> ingredients = FirebaseFirestore.instance
    //       .collection('ingredients')
    //       .doc('all_ingredients')
    //       .get()
    //       .then((DocumentSnapshot snapshot) {
    //     Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    //
    //     for (String key in data.keys) {
    //       allIngredients += List.from(data[key]);
    //     }
    //     return allIngredients;
    //   });
    //
    //   return ingredients;
    // }

    Future<DocumentSnapshot> getIngredientTypes(GoogleSignInAccount user) async {
      getMyIngredients(user);

      ingredientTypesNames.clear();
      await FirebaseFirestore.instance
          .collection('ingredients')
          .doc('all_ingredients')
          .get()
          .then((DocumentSnapshot snapshot) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

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

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2!,
      textAlign: TextAlign.center,
      child: FutureBuilder<DocumentSnapshot>(
        future: getIngredientTypes(widget.currentUser),
        // a previously-obtained Future<String> or null
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            children = Scaffold(
                body: ListView.builder(
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
                              style: const TextStyle(fontSize: 18.0, decoration: TextDecoration.none, fontWeight: FontWeight.normal, color: Colors.black, fontFamily: 'Roboto'),
                            ),),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(seconds: 1),
                                    pageBuilder: (_, __, ___) =>
                                        IngredientChooser(
                                            currentUser: widget.currentUser,
                                            updateCurrentUser:
                                                widget.updateCurrentUser,
                                            ingredientType:
                                                ingredientTypesNames[i],
                                            myIngredients: myIngredients),
                                  ));
                            },
                          ),
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
