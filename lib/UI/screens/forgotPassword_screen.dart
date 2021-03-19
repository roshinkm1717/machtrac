import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:machtrac/UI/screens/login_screen.dart';
import 'package:machtrac/UI/widgets/filled_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Enter registered email"),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  validator: RequiredValidator(errorText: "Cannot be empty"),
                ),
                SizedBox(height: 40),
                Hero(
                  tag: 'button',
                  child: FilledButton(
                    text: "Submit",
                    onPressed: () async {
                      if (formKey.currentState.validate()) {
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Email has been sent. Check Inbox"),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.code),
                            ),
                          );
                        }
                      }
                      //forgot password
                    },
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  child: Text("Go back"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
