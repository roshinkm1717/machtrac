import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/constants.dart';
import 'package:machtrac/models/user.dart';
import 'package:machtrac/provider/machine_data.dart';
import 'package:machtrac/screens/forgotPassword_screen.dart';
import 'package:machtrac/screens/signup_screen.dart';
import 'package:machtrac/widgets/buttons/google_button.dart';
import 'package:machtrac/widgets/buttons/primary_button.dart';
import 'package:machtrac/widgets/components/inputField.dart';
import 'package:machtrac/widgets/components/snackbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

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
          inAsyncCall: Provider.of<MachineData>(context).isSaving,
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
                        InputField(
                          labelText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          validator: emailValidator,
                          onChanged: (value) {
                            user.email = value;
                          },
                        ), //email input
                        SizedBox(height: 20),
                        InputField(
                          labelText: "Password",
                          obscureText: pass,
                          onChanged: (value) {
                            user.password = value;
                          },
                          validator: passwordValidator,
                          onIconTap: () {
                            setState(() {
                              pass = !pass;
                            });
                          },
                        ), // password input
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
                        ), // forgot password
                        SizedBox(height: 60),
                        PrimaryButton(
                          text: "Login",
                          onPressed: () async {
                            //login
                            if (formKey.currentState.validate()) {
                              print("Validated!");
                              Provider.of<MachineData>(context, listen: false).toggleSaving();
                              var res = await user.userLogin(user);
                              Provider.of<MachineData>(context, listen: false).toggleSaving();
                              if (res == null) {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                    (Route<dynamic> route) => false);
                              } else {
                                showSnackBar(context: context, message: res);
                              }
                            }
                          },
                        ), // login button
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
                        GoogleButton(), // login with google button
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
