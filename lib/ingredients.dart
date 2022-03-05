import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _ingredients.length,
            itemBuilder: (context, i) {
              final alreadySelected = _selected.contains(_ingredients[i]);

              return Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      _ingredients[i],
                      style: _biggerFont,
                    ),
                      trailing: Icon(
                          alreadySelected ? Icons.shopping_basket : Icons.add,
                          color: alreadySelected ? Colors.lightGreen : null,
                          semanticLabel: alreadySelected ? "Remove From Inventory" : "Add To Inventory",

                      ),
                    onTap: (){
                      setState(() {
                        if(alreadySelected){
                          _selected.remove(_ingredients[i]);
                        }
                        else{
                          _selected.add(_ingredients[i]);
                        }
                      });
                    }
                  ),

                  Divider(),
                ],
              );
            }));
  }
}

// class ingredientChooser extends StatefulWidget {
//   const ingredientChooser({Key? key}) : super(key: key);
//
//   @override
//   State<ingredientChooser> createState() => _ingredientChooserState();
// }
//
// class _ingredientChooserState extends State<ingredientChooser> {
//   var selected = "select ingredients";
//   var myIngredients = <String>[];
//
//   Scaffold _displayMyIngredients() {
//     final tiles = myIngredients.map(
//       (ingredient) {
//         return ListTile(
//           title: Text(
//             ingredient,
//           ),
//         );
//       },
//     );
//
//     final divided = tiles.isNotEmpty
//         ? ListTile.divideTiles(
//             context: context,
//             tiles: tiles,
//           ).toList()
//         : <Widget>[];
//
//     return Scaffold(
//       body: ListView(children: divided),
//     );
//   }

// Widget build(BuildContext context) {
//   return Scaffold(
//     body: Center(
//       child: Column(
//         children: [
//           DropdownButton<String>(
//             value: selected,
//             icon: const Icon(Icons.arrow_downward),
//             style: const TextStyle(color: Colors.deepPurple),
//             underline: Container(
//               height: 2,
//               color: Colors.deepPurpleAccent,
//             ),
//             onChanged: (String? newValue) {
//               setState(() {
//                 selected = newValue!;
//                 myIngredients.add(newValue);
//               });
//             },
//             items: <String>['select ingredients', 'a', 'b', 'c', 'd']
//                 .map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//           _displayMyIngredients(),
//         ],
//       ),
//     ),
//   );
