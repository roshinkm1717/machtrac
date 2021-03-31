import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:machtrac/models/user.dart';
import 'package:machtrac/screens/home_screen.dart';
import 'package:machtrac/widgets/components/snackbar.dart';


class GoogleButton extends StatelessWidget {
  final User user = User();
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      icon: Icon(FontAwesomeIcons.google),
      onPressed: () async {
        //login with google
        var res = await user.loginWithGoogle();
        if (res == null) {
          //login successful
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
              (Route<dynamic> route) => false);
        } else {
          //login failed
          showSnackBar(context: context, message: "Error occurred. Try using email or try again later");
        }
      },
      label: Text("Login with Google"),
    );
  }
}
