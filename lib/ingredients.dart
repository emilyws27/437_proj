import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ingredientDropDown extends StatefulWidget {
  const ingredientDropDown({Key? key}) : super(key: key);

  @override
  State<ingredientDropDown> createState() => _ingredientDropDownState();
}

class _ingredientDropDownState extends State<ingredientDropDown> {
  var selected = "select ingredients";
  var myIngredients = <String>[];

  Scaffold _displayMyIngredients() {
    final tiles = myIngredients.map(
      (ingredient) {
        return ListTile(
          title: Text(
            ingredient,
          ),
        );
      },
    );

    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
        : <Widget>[];

    return Scaffold(
      body: ListView(children: divided),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            DropdownButton<String>(
              value: selected,
              icon: const Icon(Icons.arrow_downward),
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selected = newValue!;
                  myIngredients.add(newValue);
                });
              },
              items: <String>['select ingredients', 'a', 'b', 'c', 'd']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            _displayMyIngredients(),
          ],
        ),
      ),
    );
  }
}
