import 'package:cloud_firestore/cloud_firestore.dart';
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

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.asset('assets/images/zestyLogo.png',
                      height: 110, width: 110),
                  const Center(
                      child: Text('Zesty',
                          style: TextStyle(
                              fontFamily: 'Cookie',
                              fontSize: 35,
                              color: Colors.black)))
                ],
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Color(0xffe0274a),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "profilePic",
                child: CircleAvatar(
                  foregroundImage: NetworkImage(imageurl),
                  radius: 50,
                ),
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
                          content:
                              const Text('Are you sure you want to sign out?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'No'),
                              child: const Text('No',
                                  style: TextStyle(fontSize: 16.0)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                                signOut();
                              },
                              child: const Text('Yes',
                                  style: TextStyle(fontSize: 16.0)),
                            ),
                          ],
                        ),
                      ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Sign Out', style: TextStyle(fontSize: 30)),
                  )),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                              'Are you sure you want to delete your account? '
                                  'All data associated with Zesty will be deleted including your profile.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'No'),
                              child: const Text('No',
                                  style: TextStyle(fontSize: 16.0)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.email)
                                    .delete();
                                signOut();
                              },
                              child: const Text('Yes',
                                  style: TextStyle(fontSize: 16.0)),
                            ),
                          ],
                        ),
                      ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text('Delete Account', style: TextStyle(fontSize: 20)),
                  ))
            ],
          ),
        ));
  }

  Future<void> signOut() async {
    updateCurrentUser(await googleSignIn.signOut());
  }
}
