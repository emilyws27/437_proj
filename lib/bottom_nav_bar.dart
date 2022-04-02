import 'package:flutter/material.dart';
import 'package:zesty/ingredientTypes.dart';
import 'package:zesty/main.dart';
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
  bool get wantKeepAlive => true;

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
                    transitionDuration:
                    const Duration(seconds: 1),
                    pageBuilder: (_, __, ___) =>
                        profilePage(
                          googleSignIn: widget.googleSignIn,
                          currentUser: widget.currentUser,
                          updateCurrentUser:
                          widget.updateCurrentUser,
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
                  ),)
            )),
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
            mySaved: true),
            RecipeFinder(
                currentUser: widget.currentUser, mySaved: false),
            IngredientTypeChooser(
                currentUser: widget.currentUser),
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
              label: 'Saved Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: 'Find Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Find Ingredients',
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
