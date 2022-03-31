import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class viewRecipe extends StatelessWidget {
  final DocumentSnapshot<Object?> recipe;
  final int number;
  const viewRecipe({Key? key, required this.recipe, required this.number}) : super(key: key);

  get icon => null;

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

  Widget servingsAndTime(
      Icon ic, String normal, double topPad, double botPad) {
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
                ic,//Text(bold,
                  //  style: const TextStyle(
                       // fontSize: 20.0, fontWeight: FontWeight.bold)),
                Text(normal, style: const TextStyle(fontSize: 20.0))
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zesty',
            style: TextStyle(
                fontFamily: 'Cookie', fontSize: 35, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.lime,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Hero(
          tag: recipe['title'],
            child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Text(
              recipe['title'].toLowerCase(),
              style:
                  const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, decoration: TextDecoration.none, color: Colors.black, fontFamily: 'Roboto'),
              textAlign: TextAlign.center,
            ),
          ),),
          Hero(
            tag: 'recipe' + number.toString(),
            child: Container(
            margin: const EdgeInsets.only(
              left: 30,
              right: 30,
              bottom: 10,
            ),
            child: Image.network(recipe['imageUrl'], fit: BoxFit.contain),
          ),),
          servingsAndTime(
              (Icon(Icons.person)),
              ": " + recipe['servings'],
              10,
              5),
          servingsAndTime(Icon(Icons.timer), ": " + recipe['time'], 5, 10),
          header("Ingredients"),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recipe['ingredients'].length,
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
                                  recipe['ingredients'][index]['quantity'] +
                                      " " +
                                      recipe['ingredients'][index]
                                          ['ingredient'],
                                  style: const TextStyle(fontSize: 20.0)))
                        ]));
              }),
          header("Directions"),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recipe['directions'].length,
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
                              child: Text(recipe['directions'][index],
                                  style: const TextStyle(fontSize: 20.0)))
                        ]));
              }),
          header("Nutrition Facts"),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recipe['nutritionInformation'].length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          //const Text("• ", style: TextStyle(fontSize: 30.0)),
                          Expanded(
                              child: Text(
                                  recipe['nutritionInformation'][index]['nutritionItem'] +
                                  ": " +
                                  recipe['nutritionInformation'][index]['amount'] ,
                              //Text("Daily Value:" + recipe['nutritionInformation'][index]['dailyValue'],
                          //recipe['nutritionInformation'][index]['']
                          style: const TextStyle(fontSize: 20.0)))
    ]));
    }),

        ],
      )),
    );
  }
}
