import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/UI/screens/login_screen.dart';
import 'package:machtrac/UI/widgets/filled_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  initState() {
    super.initState();
    checkIfLoggedIn();
  }

  checkIfLoggedIn() async {
    setState(() {
      _isSaving = true;
    });
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        User user = auth.currentUser;
        if (user != null) {
          print('User is signed in!');
          User user = FirebaseAuth.instance.currentUser;
          print(user.email);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),),);
        }
      }
    });
    setState(() {
      _isSaving = false;
    });
  }

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return DoubleBack(
      message: "Tap again to close app",
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _isSaving,
          progressIndicator: CircularProgressIndicator(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image(
                      image: AssetImage('assets/welcome_image.png'),
                    ),
                  ),
                  SizedBox(height: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Machtrac',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        SizedBox(height: 0),
                        Text(
                          'From KMCT, Banglore',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Get your machine\'s live status wherever you are.\nGet weekly and daily reports',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 40),
                        Hero(
                          tag: 'button',
                          child: FilledButton(
                            text: "Get Started",
                            onPressed: () {
                              //goto login page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
