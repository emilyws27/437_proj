import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class viewRecipe extends StatelessWidget {
  final DocumentSnapshot snapshot;
  const viewRecipe({Key? key, required this.snapshot}) : super(key: key);

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
        body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Text(
                  snapshot['title'].toLowerCase(),
                  style: const TextStyle(
                      fontSize: 28.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Text('Ingredients',
                        style: TextStyle(
                            fontSize: 25.0,
                            decoration: TextDecoration.underline)),
                  )),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot['ingredients'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Text(
                            snapshot['ingredients'][index]['quantity'] +
                                " " +
                                snapshot['ingredients'][index]['ingredient'],
                            style: const TextStyle(fontSize: 20.0)));
                  }),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Text('Directions',
                        style: TextStyle(
                            fontSize: 25.0,
                            decoration: TextDecoration.underline)),
                  )),
            ],
          ),
        );
  }
}
