import 'dart:io';

import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:machtrac/models/user.dart';
import 'package:machtrac/screens/home_screen.dart';
import 'package:machtrac/screens/login_screen.dart';
import 'package:machtrac/widgets/components/snackbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart';

import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/buttons/google_button.dart';
import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/buttons/primary_button.dart';
import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/buttons/secondary_button.dart';
import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/components/inputField.dart';

import '../constants.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  openCamera() async {
    PickedFile pickedFile = await ImagePicker.platform.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        user.image = File(pickedFile.path);
        user.imageName = basename(pickedFile.path);
      });
    }
  }

  getImage() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        user.image = File(result.paths[0]);
        user.imageName = basename(result.paths[0]);
      });
    }
  }

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
                      InputField(
                        labelText: "Email",
                        keyboardType: TextInputType.emailAddress,
                        validator: emailValidator,
                        onChanged: (value) {
                          user.email = value;
                        },
                      ), //email field
                      SizedBox(height: 10),
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
                      ), //password field
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
                      ), //confirm password field
                      SizedBox(height: 10),
                      InputField(
                        labelText: "Mobile",
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          user.mobile = value;
                        },
                      ), //mobile number field
                      SizedBox(height: 10),
                      InputField(
                        labelText: "Full Name",
                        onChanged: (value) {
                          user.fullName = value;
                        },
                      ), // full name field
                      SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              //launch camera
                              openCamera();
                            },
                          ), //camera button
                          SizedBox(width: 10),
                          Text("Or"),
                          SizedBox(width: 10),
                          Expanded(
                            child: SecondaryButton(
                              text: user.imageName ?? "Profile Picture",
                              onPressed: () {
                                //get the image
                                getImage();
                              },
                            ),
                          ), //profile picture button
                        ],
                      ),
                      SizedBox(height: 60),
                      PrimaryButton(
                        text: "Sign up",
                        onPressed: () async {
                          //sign up
                          if (formKey.currentState.validate()) {
                            print("validated");
                            setState(() {
                              _isSaving = true;
                            });
                            var res = await user.registerUser(user); // try to register the user
                            setState(() {
                              _isSaving = false;
                            });
                            if (res == null) {
                              //user registration successful
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                  (Route<dynamic> route) => false);
                            } else {
                              //user registration failed
                              showSnackBar(context: context, message: res);
                            }
                          }
                        },
                      ), //submit button
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
                      ), //login button
                      SizedBox(height: 20),
                      GoogleButton(),
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
