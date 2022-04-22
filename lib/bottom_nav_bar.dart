import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zesty/ingredientTypes.dart';
import 'package:zesty/recipes.dart';
import 'package:zesty/profile.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'ingredients.dart';

class BottomNav extends StatefulWidget {
  final GoogleSignIn googleSignIn;
  final GoogleSignInAccount currentUser;
  final Function updateCurrentUser;

  const BottomNav({
    Key? key,
    required this.googleSignIn,
    required this.currentUser,
    required this.updateCurrentUser,
  }) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNav();
}

class _BottomNav extends State<BottomNav> {
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

  final PageController _controller = PageController(
    initialPage: 2,
    keepPage: true,
  );

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imageurl;
    if (widget.currentUser.photoUrl == null) {
      imageurl =
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf8xdLG78TMYzKtF09m3yqmzo8-NmjgdxR3g&usqp=CAU";
    } else {
      imageurl = widget.currentUser.photoUrl!;
    }

    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(seconds: 1),
                      pageBuilder: (_, __, ___) => profilePage(
                        googleSignIn: widget.googleSignIn,
                        currentUser: widget.currentUser,
                        updateCurrentUser: widget.updateCurrentUser,
                      ),
                    ));
              },
              child: Container(
                  margin: const EdgeInsets.only(
                    left: 10,
                    bottom: 2,
                  ),
                  child: Hero(
                    tag: "profilePic",
                    child: CircleAvatar(
                      foregroundImage: NetworkImage(imageurl),
                      radius: 30,
                    ),
                  ))),
          title: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.asset('assets/images/zestyLogo.png', height: 110, width: 110),
              const Center(
                child: Text('Zesty',
                  style: TextStyle(
                      fontFamily: 'Cookie', fontSize: 35, color: Colors.black)))
            ],
          ),
          centerTitle: true,
          backgroundColor: Color(0xffe0274a),
          actions: <Widget>[
            Container(
                margin: const EdgeInsets.only(
                  right: 10,
                  bottom: 2,
                ),
                child: IconButton(
                  icon: const Icon(Icons.kitchen),
                  color: const Color(0xffff9b9b),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 700),
                          pageBuilder: (_, __, ___) => IngredientList(
                            currentUser: widget.currentUser,
                            myIngredients: true,
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
                )),
          ]),
      body: PageView(
          controller: _controller,
          children: <Widget>[
            RecipeFinder(currentUser: widget.currentUser, mySaved: true),
            RecipeFinder(currentUser: widget.currentUser, mySaved: false),
            IngredientTypeList(currentUser: widget.currentUser),
          ],
          onPageChanged: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Ingredients',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xffff9b9b),
          onTap: (int index) {
            _onItemTapped(index);
          }),
    );
  }
}
