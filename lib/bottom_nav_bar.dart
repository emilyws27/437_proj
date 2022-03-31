import 'package:flutter/material.dart';
import 'package:zesty/ingredientTypes.dart';
import 'package:zesty/recipes.dart';
import 'package:zesty/profile.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final PageController _controller = PageController(
    initialPage: 1,
    keepPage: true,
  );

  int _selectedIndex = 1;

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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zesty',
            style: TextStyle(
                fontFamily: 'Cookie', fontSize: 35, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.amber[900],
      ),
      body: PageView(
          controller: _controller,
          children: <Widget>[
            RecipeFinder(
                currentUser: widget.currentUser,
                updateCurrentUser: widget.updateCurrentUser),
            IngredientTypeChooser(
                currentUser: widget.currentUser,
                updateCurrentUser: widget.updateCurrentUser),
            profilePage(
                googleSignIn: widget.googleSignIn,
                currentUser: widget.currentUser,
                updateCurrentUser: widget.updateCurrentUser),
          ],
          onPageChanged: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
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
          onTap: (int index) {
            _onItemTapped(index);
          }),
    );
  }
}
