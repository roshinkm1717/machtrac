import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:machtrac/models/user.dart';
import 'package:machtrac/screens/home_screen.dart';
import 'package:machtrac/widgets/buttons/primary_button.dart';
import 'package:machtrac/widgets/components/inputField.dart';
import 'package:machtrac/widgets/components/snackbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({this.displayName});
  final String displayName;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    List res = await user.getUserDetails();
    setState(() {
      user.fullName = res[0];
      if (user.fullName == null) {
        user.fullName = widget.displayName;
      }
      user.mobile = res[1];
      print(user.fullName);
    });
  }

  final User user = User();
  bool isSaving = false;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isSaving,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade800,
                    ),
                    child: Text(
                      'roshinkm17@gmail.com',
                      style: TextStyle(color: Colors.white),
                    ),
                  ), //email badge
                  SizedBox(height: 20),
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InputField(
                          labelText: "Name",
                          onChanged: (value) {
                            user.fullName = value;
                          },
                          validator: MultiValidator([RequiredValidator(errorText: "Cannot be empty")]),
                        ), //name field
                        SizedBox(height: 20),
                        InputField(
                          labelText: "Mobile",
                          onChanged: (value) {
                            user.mobile = value;
                          },
                          validator: MultiValidator([RequiredValidator(errorText: 'Cannot be empty')]),
                        ), //mobile field
                        SizedBox(height: 40),
                        PrimaryButton(
                          onPressed: () async {
                            //update profile
                            if (formKey.currentState.validate()) {
                              setState(() {
                                isSaving = true;
                              });
                              await user.updateUserDetails(user.fullName, user.mobile);
                              setState(() {
                                isSaving = false;
                              });
                              print("name: ${user.fullName}");
                              showSnackBar(context: context, message: "Updated!");
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                            }
                          },
                          text: "Update Profile",
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
