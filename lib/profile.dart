import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class profilePage extends StatelessWidget {
  final GoogleSignIn googleSignIn;
  final GoogleSignInAccount currentUser;
  final Function updateCurrentUser;

  const profilePage({
    Key? key,
    required this.googleSignIn,
    required this.currentUser,
    required this.updateCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GoogleUserCircleAvatar(identity: currentUser),
          ListTile(
            title: Text(
              currentUser.displayName ?? '',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            subtitle: Text(currentUser.email,
                style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: signOut,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Sign Out', style: TextStyle(fontSize: 30)),
              ))
        ],
      ),
    );
  }

  Future<void> signOut() async {
    updateCurrentUser(await googleSignIn.signOut());
  }
}
