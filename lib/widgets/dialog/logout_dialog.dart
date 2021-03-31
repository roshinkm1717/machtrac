import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:machtrac/screens/login_screen.dart';

class LogOutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("You sure to logout?"),
      actions: [
        TextButton(
          onPressed: () async {
            //log out
            try {
              GoogleSignIn _googleSignIn;
              await _googleSignIn.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (Route<dynamic> route) => false);
            } catch (e) {
              print(e);
            }
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
                (Route<dynamic> route) => false);
          },
          child: Text("Logout"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        )
      ],
    );
  }
}
