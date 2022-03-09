import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zesty/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    //_currentUser = _googleSignIn.currentUser;
    // if (_currentUser == null) {
    //   _googleSignIn.signInSilently().then((value) {
    //     _currentUser = _googleSignIn.currentUser;
    //   });
    // }
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently().then((value) {
      _currentUser = _googleSignIn.currentUser;
    });
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

  Widget _buildWidget() {
    if (_currentUser != null) {
      GoogleSignInAccount? user = _currentUser;
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      usersCollection.doc(user?.email).get().then((docSnapshot) => {
            if (!docSnapshot.exists)
              {
                usersCollection
                    .doc(user?.email)
                    .set({'displayName': user?.displayName})
              }
          });
      return HomePage();
    } else {
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
  }

  void signOut() {
    _googleSignIn.disconnect();
  }

  Future<void> signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      print('Error signing in $e');
    }
  }
}
