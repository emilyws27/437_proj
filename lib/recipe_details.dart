import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class viewRecipe extends StatelessWidget {
  final DocumentSnapshot snapshot;
  const viewRecipe({Key? key, required this.snapshot}) : super(key: key);
  final _biggerFont = const TextStyle(fontSize: 18.0);

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
      body: ListView(
        children: <Widget>[
          Text(snapshot['title'], style: _biggerFont, textAlign: TextAlign.center,),
          const Text('Ingredients', style: TextStyle(fontSize: 16.0), textAlign: TextAlign.left),
          Text(snapshot['ingredients'], style: TextStyle(fontSize: 14.0),textAlign: TextAlign.left )
        ],
      ),
    );
  }
}
