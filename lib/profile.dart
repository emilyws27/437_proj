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
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 12),
      child: Column(
        children: [
          ListTile(
            leading: GoogleUserCircleAvatar(identity: currentUser),
            title: Text(
              currentUser.displayName ?? '',
              style: TextStyle(fontSize: 22),
            ),
            subtitle: Text(currentUser.email, style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(onPressed: signOut, child: const Text('Sign out'))
        ],
      ),
    );
  }

  Future<void> signOut() async {
    updateCurrentUser(await googleSignIn.disconnect());
  }
}
