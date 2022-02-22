import 'package:flutter/material.dart';

class recipeCard extends StatelessWidget{
  const recipeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Center(
        child: Card(
            child: InkWell(
              splashColor: Colors.indigo,
              onTap: (){
                debugPrint('Card tapped');
              },
            child: const SizedBox(
              width: 300,
              height: 100,
              child: Text('insert recipe name here'),
            )
            ),
        ),
    );
  }

}