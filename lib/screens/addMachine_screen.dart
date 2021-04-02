import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:machtrac/models/machine.dart';
import 'package:machtrac/provider/machine_data.dart';
import 'package:machtrac/widgets/buttons/primary_button.dart';
import 'package:machtrac/widgets/components/inputField.dart';
import 'package:machtrac/widgets/components/snackbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';

class AddMachineScreen extends StatelessWidget {
  final controller = TextEditingController();
  final linkController = TextEditingController();
  final Machine machine = Machine();
  final formKey = GlobalKey<FormState>();

  //validate details to submit
  void validateDetails(BuildContext context) async {
    if (formKey.currentState.validate()) {
      //fields validated successfully
      machine.imageName = Provider.of<MachineData>(context, listen: false).imageName;
      machine.image = Provider.of<MachineData>(context, listen: false).image;
      //check if image is selected
      if (machine.imageName != null) {
        //add machine
        //check if fetch link is validated
        if (Provider.of<MachineData>(context, listen: false).isFetchLinkCorrect) {
          Provider.of<MachineData>(context, listen: false).toggleSaving();
          var res = await machine.uploadMachineData(machine); //upload machine data to db
          Provider.of<MachineData>(context, listen: false).toggleSaving();
          if (res != null) {
            showSnackBar(context: context, message: "Error uploading data. Try again later");
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          }
        } else {
          showSnackBar(context: context, message: "Please check the fetch link and try again");
        }
      } else {
        showSnackBar(context: context, message: "Please select an image");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ModalProgressHUD(
        inAsyncCall: Provider.of<MachineData>(context).isSaving,
        progressIndicator: CircularProgressIndicator(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(
                          labelText: "Machine name",
                          onChanged: (value) {
                            machine.name = value;
                          },
                          validator: MultiValidator([RequiredValidator(errorText: "Cannot be empty")]),
                        ), //machine name
                        SizedBox(height: 10),
                        InputField(
                          labelText: "Machine make",
                          onChanged: (value) {
                            machine.make = value;
                          },
                          validator: MultiValidator([RequiredValidator(errorText: "Cannot be empty")]),
                        ), //machine make
                        SizedBox(height: 10),
                        InputField(
                          labelText: "Year of Manufacturing",
                          onChanged: (value) {
                            machine.manYear = int.parse(value);
                          },
                          keyboardType: TextInputType.number,
                          validator: MultiValidator([RequiredValidator(errorText: "Cannot be empty")]),
                        ), //year of manufacturing
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: InputField(
                                controller: linkController,
                                labelText: "Fetch link",
                                onChanged: (value) {
                                  machine.fetchLink = value;
                                },
                                validator: MultiValidator([RequiredValidator(errorText: "Cannot be empty")]),
                              ),
                            ), //fetch link
                            IconButton(
                              onPressed: () async {
                                if (machine.fetchLink != null) {
                                  showSnackBar(context: context, message: "Checking link...");
                                  Provider.of<MachineData>(context, listen: false).checkFetchLink(machine.fetchLink);
                                }
                              },
                              icon: Icon(
                                Icons.check_circle_outline_rounded,
                                color: (Provider.of<MachineData>(context).isFetchLinkCorrect == null)
                                    ? Colors.grey
                                    : (Provider.of<MachineData>(context).isFetchLinkCorrect
                                        ? Colors.green
                                        : Colors.red),
                                size: 32,
                              ),
                            ),
                          ],
                        ), //fetch link
                        SizedBox(height: 10),
                        Text("Or"),
                        SizedBox(height: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.blue,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () async {
                            //scan QR
                            linkController.text =
                                await Provider.of<MachineData>(context, listen: false).getLinkFromQR();
                            machine.fetchLink = linkController.text;
                          },
                          child: Text("Scan QR"),
                        ), //QR Scan button
                        InputField(
                          labelText: "Capacity",
                          onChanged: (value) {
                            machine.capacity = value;
                          },
                          validator: MultiValidator([RequiredValidator(errorText: "Cannot be empty")]),
                        ), //capacity
                        SizedBox(height: 20),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                //launch camera
                                Provider.of<MachineData>(context, listen: false).getImageFromCamera();
                              },
                            ), //image select from camera
                            SizedBox(width: 10),
                            Text("Or"),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(side: BorderSide(color: Colors.blue)),
                                onPressed: () async {
                                  //select image
                                  Provider.of<MachineData>(context, listen: false).getImageFromStorage();
                                },
                                child: Text(Provider.of<MachineData>(context).imageName ?? "Select image"),
                              ),
                            ), //image select from storage
                          ],
                        ), //image selection
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: InputField(
                                controller: controller,
                                labelText: "Location",
                                onChanged: (value) {
                                  machine.location = value;
                                },
                                validator: MultiValidator([RequiredValidator(errorText: "Cannot be empty")]),
                              ),
                            ), //location field
                            IconButton(
                              icon: Icon(Icons.location_searching),
                              onPressed: () async {
                                String loc = await Provider.of<MachineData>(context, listen: false).getLocation();
                                controller.text = loc;
                              },
                            ), //get location button
                          ],
                        ), //location
                      ],
                    ),
                    SizedBox(height: 40),
                    PrimaryButton(
                      text: "Add Machine",
                      onPressed: () {
                        validateDetails(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
