import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zesty/main.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Zesty'),
        ),
        body: Center(
            child: ElevatedButton(
                child: const Text("go to home"),
                onPressed: () {
                  print("HERE!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp2()),
                  );
                })));
  }
}
