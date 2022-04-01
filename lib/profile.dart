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
    String imageurl;
    if (currentUser.photoUrl == null) {
      imageurl =
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf8xdLG78TMYzKtF09m3yqmzo8-NmjgdxR3g&usqp=CAU";
    } else {
      imageurl = currentUser.photoUrl!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            foregroundImage: NetworkImage(imageurl),
            radius: 50,
          ),
          ListTile(
            title: Text(
              currentUser.displayName ?? '',
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            subtitle: Text(currentUser.email,
                style: const TextStyle(fontSize: 22),
                textAlign: TextAlign.center),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'No'),
                          child: const Text('No', style: TextStyle(fontSize: 16.0)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, "Yes");
                            signOut();
                          },
                          child: const Text('Yes',style: TextStyle(fontSize: 16.0)),
                        ),
                      ],
                    ),
                  ),
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
