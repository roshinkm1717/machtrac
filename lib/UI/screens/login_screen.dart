import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:machtrac/Backend/user.dart';
import 'package:machtrac/UI/screens/forgotPassword_screen.dart';
import 'package:machtrac/UI/screens/signup_screen.dart';
import 'package:machtrac/UI/widgets/filled_button.dart';
import 'package:machtrac/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  User user = User();
  bool _isSaving = false;
  bool pass = true;
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
              padding: const EdgeInsets.all(30.0),
              child: SingleChildScrollView(
                child: Builder(
                  builder: (context) => Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Welcome back",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Let's Login",
                          style: TextStyle(fontSize: 22),
                        ),
                        SizedBox(height: 60),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Email",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              user.email = value;
                            });
                          },
                          validator: emailValidator,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          obscureText: pass,
                          decoration: InputDecoration(
                            labelText: "Password",
                            suffix: GestureDetector(
                              onTap: () {
                                setState(() {
                                  pass = !pass;
                                });
                              },
                              child: Icon(
                                Icons.visibility,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              user.password = value;
                            });
                          },
                          validator: passwordValidator,
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.grey),
                          ),
                          onPressed: () {
                            //forgot password
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                          },
                        ),
                        SizedBox(height: 60),
                        Hero(
                          tag: 'button',
                          child: FilledButton(
                            text: "Login",
                            onPressed: () async {
                              //login
                              if (formKey.currentState.validate()) {
                                print("Validated!");
                                setState(() {
                                  _isSaving = true;
                                });
                                var res = await user.userLogin(user);
                                setState(() {
                                  _isSaving = false;
                                });
                                if (res == null) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(),
                                      ),
                                      (Route<dynamic> route) => false);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(res)),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            //sign up page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: Text('Create a new account?'),
                        ),
                        SizedBox(height: 40),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () async {
                            //login with Google
                            var res = await user.loginWithGoogle();
                            if (res == null) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                  (Route<dynamic> route) => false);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(res.toString())),
                              );
                            }
                          },
                          icon: Icon(
                            FontAwesomeIcons.google,
                            color: Colors.blue,
                          ),
                          label: Text(
                            "Log in with Google",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
