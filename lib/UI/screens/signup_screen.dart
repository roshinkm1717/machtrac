import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:machtrac/Backend/user.dart';
import 'package:machtrac/UI/screens/home_screen.dart';
import 'package:machtrac/UI/screens/login_screen.dart';
import 'package:machtrac/UI/widgets/filled_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../constants.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  User user = User();
  final formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool pass = true, confirmPass = true;
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
            padding: EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Builder(
                builder: (context) => Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Let's Get Started",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Sign up",
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(height: 60),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                        ),
                        onChanged: (value) {
                          setState(() {
                            user.email = value;
                          });
                        },
                        validator: emailValidator,
                      ),
                      SizedBox(height: 10),
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
                      TextFormField(
                        obscureText: confirmPass,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          suffix: GestureDetector(
                            onTap: () {
                              setState(() {
                                confirmPass = !confirmPass;
                              });
                            },
                            child: Icon(
                              Icons.visibility,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        onChanged: (value) {},
                        validator: (val) => MatchValidator(errorText: 'Passwords do not match').validateMatch(val, user.password),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Mobile",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            user.mobile = value;
                          });
                        },
                        validator: MinLengthValidator(10, errorText: "Minimum 10 number"),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Full Name",
                        ),
                        onChanged: (value) {
                          setState(() {
                            user.fullName = value;
                          });
                        },
                        validator: RequiredValidator(errorText: "Name cannot be empty"),
                      ),
                      SizedBox(height: 60),
                      Hero(
                        tag: 'button',
                        child: FilledButton(
                          text: "Sign up",
                          onPressed: () async {
                            //sign up
                            if (formKey.currentState.validate()) {
                              print("validated");
                              setState(() {
                                _isSaving = true;
                              });
                              var res = await user.registerUser(user);
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
                                  SnackBar(
                                    content: Text(res),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          //login page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text('Already have an account? Log in'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }
}