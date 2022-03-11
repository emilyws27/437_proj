import 'package:flutter/material.dart';
import 'package:zesty/ingredients.dart';
import 'package:zesty/recipes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zesty/main.dart';
//import 'package:zesty/recipes.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class BottomNav extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final Function updateCurrentUser;

  const BottomNav({
    Key? key,
    required this.currentUser,
    required this.updateCurrentUser,
  }) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNav();
}



class _BottomNav extends State<BottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle optionStyle =
    TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    List<Widget> _widgetOptions = <Widget>[
      RecipeFinder(currentUser: widget.currentUser, updateCurrentUser: widget.updateCurrentUser),
      IngredientChooser(currentUser: widget.currentUser, updateCurrentUser: widget.updateCurrentUser),
      Text(
        'My Profile',
        style: optionStyle,
      ),
    ];


    return Scaffold(
      appBar: AppBar(
        title: const Text('Zesty'),
        backgroundColor: Colors.amber[900],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'My Ingredients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'My Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}