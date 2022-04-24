import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class viewRecipe extends StatefulWidget {
  final GoogleSignInAccount currentUser;
  final DocumentSnapshot<Object?> recipe;
  final int number;
  final String num_missing_ingr;

  const viewRecipe({
    Key? key,
    required this.currentUser,
    required this.recipe,
    required this.number,
    required this.num_missing_ingr,
  }) : super(key: key);

  @override
  State<viewRecipe> createState() => _viewRecipeState();
}

class _viewRecipeState extends State<viewRecipe> {
  Widget header(String title) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 10,
            bottom: 5,
          ),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline)),
        ));
  }

  Widget servingsAndTime(Icon ic, String normal, double topPad, double botPad) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: topPad,
              bottom: botPad,
            ),
            child: Row(
              children: <Widget>[
                ic,
                Text(normal, style: const TextStyle(fontSize: 20.0))
              ],
            )));
  }

  Widget source() {
    Future<void> _onOpen(LinkableElement link) async {
      launch(link.url);
    }

    Map<String, dynamic> recipeMap =
        widget.recipe.data() as Map<String, dynamic>;

    return Align(
        alignment: Alignment.centerLeft,
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Linkify(
                      onOpen: _onOpen,
                      text: "View this recipe on Food.com: " +
                          "\n" +
                          widget.recipe["url"],
                      style: const TextStyle(fontSize: 20.0)),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Linkify(
                        onOpen: _onOpen,
                        text: recipeMap.containsKey("authorUrl") &&
                                recipeMap.containsKey("author")
                            ? "Recipe uploaded to Food.com by user " +
                                widget.recipe["author"] +
                                ":\n" +
                                widget.recipe["authorUrl"]
                            : "",
                        style: const TextStyle(fontSize: 20.0)),
                  )
                ],
              )),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset('assets/images/zestyLogo.png',
                    height: 110, width: 110),
                const Center(
                    child: Text('Zesty',
                        style: TextStyle(
                            fontFamily: 'Cookie',
                            fontSize: 35,
                            color: Colors.black)))
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xffe0274a),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Text(
              widget.recipe['title'],
              style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  color: Colors.black54,
                  fontFamily: 'Dosis'),
              textAlign: TextAlign.center,
            ),
          ),
          Hero(
            tag: 'recipe' + widget.number.toString(),
            child: Container(
              margin: const EdgeInsets.only(
                left: 30,
                right: 30,
                bottom: 10,
              ),
              child:
                  Image.network(widget.recipe['imageUrl'], fit: BoxFit.contain),
            ),
          ),
          servingsAndTime((const Icon(Icons.people)),
              ": " + widget.recipe['servings'] + " servings", 10, 5),
          servingsAndTime(const Icon(Icons.timer),
              ": " + widget.recipe['time'] + " cook time", 5, 10),
          servingsAndTime((const Icon(Icons.warning)),
              ": ${widget.num_missing_ingr}", 5, 10),
          header("Ingredients"),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.recipe['ingredients'].length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text("• ", style: TextStyle(fontSize: 30.0)),
                          Expanded(
                              child: Text(
                                  widget.recipe['ingredients'][index]
                                          ['quantity'] +
                                      " " +
                                      widget.recipe['ingredients'][index]
                                          ['ingredient'],
                                  style: const TextStyle(fontSize: 20.0))),
                          IconButton(
                              icon: Icon(Icons.remove_shopping_cart_outlined),
                              color: Color(0xffe0274a),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.currentUser.email)
                                    .update({
                                  'ingredients': FieldValue.arrayRemove([
                                    widget.recipe['ingredients'][index]
                                        ['ingredient']
                                  ])
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(widget.recipe['ingredients']
                                            [index]['ingredient'] +
                                        ' was removed from your ingredients'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.currentUser.email)
                                            .update({
                                          'ingredients': FieldValue.arrayUnion([
                                            widget.recipe['ingredients'][index]
                                                ['ingredient']
                                          ])
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }),
                        ]));
              }),
          header("Directions"),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.recipe['directions'].length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text((index + 1).toString() + ") ",
                              style: const TextStyle(fontSize: 20.0)),
                          Expanded(
                              child: Text(widget.recipe['directions'][index],
                                  style: const TextStyle(fontSize: 20.0)))
                        ]));
              }),
          header("Nutrition Facts"),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Text(
                    "Amount per serving: " + widget.recipe['servingSize'],
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w500))),
          ),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.recipe['nutritionInformation'].length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Row(children: <Widget>[
                      Text(
                          widget.recipe['nutritionInformation'][index]
                                  ['nutritionItem'] +
                              ": ",
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w500)),
                      Text(
                          widget.recipe['nutritionInformation'][index]
                              ['amount'],
                          //Text("Daily Value:" + recipe['nutritionInformation'][index]['dailyValue'],
                          //recipe['nutritionInformation'][index]['']
                          style: const TextStyle(fontSize: 20.0))
                    ]));
              }),
          header("Source"),
          source(),
        ],
      )),
    );
  }
}
