import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zesty/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class Login extends StatelessWidget {
  final GoogleSignInAccount? currentUser;
  final Function updateCurrentUser;

  const Login({
    Key? key,
    required this.currentUser,
    required this.updateCurrentUser
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Google Sign in'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Welcome to Zesty, Please Sign In',
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: signIn,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Sign in', style: TextStyle(fontSize: 30)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
      FirebaseFirestore.instance.collection('users').doc(_googleSignIn.currentUser!.email).get().then( (user) {
        if (!user.exists) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(_googleSignIn.currentUser!.email)
              .set({
            'displayName': _googleSignIn.currentUser!.displayName,
            'ingredients': [],
            'savedRecipes': [],
          });
        }
      });
      updateCurrentUser(_googleSignIn.currentUser);
    } catch (e) {
      print('Error signing in $e');
    }
  }
}