import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zesty/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:english_words/english_words.dart';
import 'package:zesty/main.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email'
    ]
);
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Login> {

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: _buildWidget(),
      ),
    );
  }

  Widget _buildWidget(){
    GoogleSignInAccount? user = _currentUser;

    if(user != null){
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      usersCollection.doc(user.email).set({ 'displayName': user.displayName });
      return MyApp();
    }else{
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
                const SizedBox(height: 20,),
                const Text(
                  'You are not signed in',
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                    onPressed: signIn,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Sign in', style: TextStyle(fontSize: 30)),
                    )
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void signOut(){
    _googleSignIn.disconnect();
  }

  Future<void> signIn() async {
    try{
      print("Hello");
      await _googleSignIn.signIn();
    }catch (e){
      print('Error signing in $e');
    }
  }

}
// class Login extends StatelessWidget {
//   const Login({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Zesty'),
//         ),
//         body: Center(
//             child: ElevatedButton(
//                 child: const Text("go to home"),
//                 onPressed: () {
//                   print("HERE!");
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const MyApp()),
//                   );
//                 })));
//   }
// }

