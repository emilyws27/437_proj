import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zesty/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

// FirebaseAuth auth = FirebaseAuth.instance;

// FirebaseAuth.instance
//   .authStateChanges()
//   .listen((User? user) {
//     if (user == null) {
//       print('User is currently signed out!');
//     } else {
//       print('User is signed in!');
//     }
//   });

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  // Future<FirebaseApp> _initializeFirebase() async {
  //   FirebaseApp firebaseApp = await Firebase.initializeApp();
  //   return firebaseApp;
  // }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Zesty'),
        ),
        body: Center(
            child: ElevatedButton(
                child: const Text("Log in with google"),
                onPressed: () {
                  print(signInWithGoogle());
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const MyApp2()),
                  // );
                })));
  }
}


// Future<UserCredential> signInWithGoogle() async {
//   // Trigger the authentication flow
//   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//   // Obtain the auth details from the request
//   final GoogleSignInAuthentication? googleAuth =
//       await googleUser?.authentication;

//   // Create a new credential
//   final credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth?.accessToken,
//     idToken: googleAuth?.idToken,
//   );

//   // Once signed in, return the UserCredential
//   return await FirebaseAuth.instance.signInWithCredential(credential);
// }
