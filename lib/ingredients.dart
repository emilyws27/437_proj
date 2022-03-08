import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zesty/main.dart';
import 'package:zesty/user.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class IngredientChooser extends StatefulWidget {
  const IngredientChooser({Key? key}) : super(key: key);

  @override
  _IngredientChooserState createState() => _IngredientChooserState();
}

class _IngredientChooserState extends State<IngredientChooser> {
  final _ingredients = <String>[
    "Apples",
    "Avocado",
    "Asparagus",
    "Bananas",
    "Bread",
    "Bacon",
    "Blueberries",
    "Chicken",
    "Cheddar Cheese",
    "Chips Ahoy",
    "Carrots",
  ];
  var _selected = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _googleSignIn.currentUser;
    if (_currentUser == null) {
      _googleSignIn.signInSilently().then((value) {
        _currentUser = _googleSignIn.currentUser;
      });
    }
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<List<String>> myIngredients(GoogleSignInAccount? user) {
      Future<List<String>> ingredients = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.email)
          .get()
          .then((DocumentSnapshot data) {
        _selected = List.from(data.get('ingredients'));
        return List.from(data.get('ingredients'));
      });
      return ingredients;
    }

    GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return DefaultTextStyle(
        style: Theme.of(context).textTheme.headline2!,
        textAlign: TextAlign.center,
        child: FutureBuilder<List<String>>(
          future: myIngredients(user),
          // a previously-obtained Future<String> or null
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            Widget children;
            if (snapshot.hasData) {
              children = Scaffold(
                  body: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _ingredients.length,
                      itemBuilder: (context, i) {

                        final alreadySelected = _selected.contains(_ingredients[i]);

                        return SizedBox(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                    title: Text(
                                      _ingredients[i],
                                      style: _biggerFont,
                                    ),
                                    trailing: Icon(
                                      alreadySelected
                                          ? Icons.shopping_cart
                                          : Icons.add,
                                      color: alreadySelected ? Colors.lightGreen : null,
                                      semanticLabel: alreadySelected
                                          ? "Remove From Inventory"
                                          : "Add To Inventory",
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (alreadySelected) {
                                          _selected.remove(_ingredients[i]);
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.email)
                                              .update({
                                            'ingredients':
                                            FieldValue.arrayRemove([_ingredients[i]])
                                          });
                                        } else {
                                          _selected.add(_ingredients[i]);
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.email)
                                              .update({
                                            'ingredients':
                                            FieldValue.arrayUnion([_ingredients[i]])
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
                        Padding(
                          padding: EdgeInsets.only(top: 16),
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
    } else {
      return Scaffold(
          body: Center(
              child: Column(children: [
                Text(
                  "You're not signed in",
                  style: _biggerFont,
                ),
                const SizedBox(
                  height: 10,
                ),
                const ElevatedButton(
                    onPressed: goToLogin,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Sign in', style: TextStyle(fontSize: 30)),
                    )),
              ])));
    }
  }

    }

Future<void> signIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (e) {
    print('Error signing in $e');
  }
}

goToLogin() async {
  print("go to login");
  runApp(const LoginPage());
}
//       GoogleSignInAccount? user = _currentUser;
//       return Scaffold(
//           body: ListView.builder(
//               padding: const EdgeInsets.all(16.0),
//               itemCount: _ingredients.length,
//               itemBuilder: (context, i) {
//                 final alreadySelected = _selected.contains(_ingredients[i]);
//
//                 return Column(
//                   children: <Widget>[
//                     ListTile(
//                         title: Text(
//                           _ingredients[i],
//                           style: _biggerFont,
//                         ),
//                         trailing: Icon(
//                           alreadySelected ? Icons.shopping_basket : Icons.add,
//                           color: alreadySelected ? Colors.lightGreen : null,
//                           semanticLabel: alreadySelected
//                               ? "Remove From Inventory"
//                               : "Add To Inventory",
//                         ),
//                         onTap: () {
//                           setState(() {
//                             if (alreadySelected) {
//                               _selected.remove(_ingredients[i]);
//                               FirebaseFirestore.instance
//                                   .collection('users')
//                                   .doc(user?.email)
//                                   .update({
//                                 'ingredients':
//                                     FieldValue.arrayRemove([_ingredients[i]])
//                               });
//                             } else {
//                               _selected.add(_ingredients[i]);
//                               FirebaseFirestore.instance
//                                   .collection('users')
//                                   .doc(user?.email)
//                                   .update({
//                                 'ingredients':
//                                     FieldValue.arrayUnion([_ingredients[i]])
//                               });
//                             }
//                           });
//                         }),
//                     Divider(),
//                   ],
//                 );
//               }));
//     } else {
//       return Scaffold(
//           body: Center(
//               child: Text(
//         "Loading...",
//         style: _biggerFont,
//       )));
//     }
//   }
// }
