import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatelessWidget {
  final GoogleSignIn googleSignIn;
  final GoogleSignInAccount? currentUser;
  final Function updateCurrentUser;

  const Login({
    Key? key,
    required this.googleSignIn,
    required this.currentUser,
    required this.updateCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffe0274a),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to',
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset('assets/images/zestyLogo.png'),
                const Center(
                    child: Text('Zesty',
                        style: TextStyle(
                            fontFamily: 'Cookie',
                            fontSize: 70,
                            color: Colors.black)))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: signIn,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Sign in', style: TextStyle(fontSize: 30)),
                )),
            const SizedBox(
              height: 20,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: 'About this app',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      showAboutDialog(context: context,
                      applicationName: "Zesty",
                      applicationVersion: "0.2b",
                      applicationIcon: Image.asset('assets/images/zestyLogo.png',
                          height: 110, width: 110),
                      applicationLegalese: "Zesty does not have ownership of any of the recipes provided through the app. "
                          "All recipes from this platform were scraped from Food.com where full credit is given to the "
                          "authors of each recipe. Zesty is not responsible for any illness, injury, or even deaths that "
                          "may come from the use of the app and recipes provided.");
                    }),
            ]))
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    try {
      GoogleSignInAccount? newUser = await googleSignIn.signIn();
      GoogleSignInAuthentication? userAuth = await newUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: userAuth?.accessToken,
        idToken: userAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      FirebaseFirestore.instance
          .collection('users')
          .doc(newUser!.email)
          .get()
          .then((user) {
        if (!user.exists) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(newUser.email)
              .set({
            'displayName': newUser.displayName,
            'ingredients': [],
            'savedRecipes': [],
          });
        }
      });
      updateCurrentUser(newUser);
    } catch (e) {
      print('Error signing in $e');
    }
  }
}
