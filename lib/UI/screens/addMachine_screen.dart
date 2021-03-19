import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:machtrac/Backend/machine.dart';
import 'package:machtrac/UI/widgets/filled_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart';

import 'home_screen.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class AddMachineScreen extends StatefulWidget {
  @override
  _AddMachineScreenState createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  getImage() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        machine.image = File(result.paths[0]);
        print(machine.image);
        machine.imageName = basename(result.paths[0]);
      });
    }
  }

  var controller = TextEditingController();
  bool _isSaving = false;
  Machine machine = Machine();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    bool loc = false;
    return Scaffold(
      appBar: AppBar(),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        progressIndicator: CircularProgressIndicator(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Machine name",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              machine.name = value;
                            });
                          },
                          validator: RequiredValidator(errorText: "Cannot be empty"),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Machine make",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {
                              machine.make = value;
                            });
                          },
                          validator: RequiredValidator(errorText: "Cannot be empty"),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Year of Manufacturing",
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              machine.manYear = int.parse(value);
                            });
                          },
                          validator: RequiredValidator(errorText: "Cannot be empty"),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Fetch link",
                          ),
                          onChanged: (value) {
                            setState(() {
                              machine.fetchLink = value;
                            });
                          },
                          validator: RequiredValidator(errorText: "Cannot be empty"),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Capacity",
                          ),
                          onChanged: (value) {
                            setState(() {
                              machine.capacity = value;
                            });
                          },
                          validator: RequiredValidator(errorText: "Cannot be empty"),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          style: TextButton.styleFrom(side: BorderSide(color: Colors.blue)),
                          onPressed: () {
                            //select image
                            getImage();
                          },
                          child: Text(machine.imageName == null ? "Select image" : machine.imageName),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: "Location",
                                ),
                                keyboardType: TextInputType.streetAddress,
                                onChanged: (value) {
                                  setState(() {
                                    machine.location = value;
                                  });
                                },
                                validator: RequiredValidator(errorText: "Cannot be empty"),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.location_searching),
                              onPressed: () async {
                                Position location = await _determinePosition();
                                List<Placemark> placeMarks = await placemarkFromCoordinates(location.latitude, location.longitude);
                                print(placeMarks[0].locality);
                                setState(() {
                                  loc = true;
                                  machine.location = placeMarks[0].locality + "," + placeMarks[0].administrativeArea + "," + placeMarks[0].country;
                                  controller.text = machine.location;
                                  print(machine.location);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Hero(
                      tag: 'button',
                      child: FilledButton(
                        text: "Add Machine",
                        onPressed: () async {
                          if (formKey.currentState.validate()) {
                            if (machine.imageName != null) {
                              //add machine
                              setState(() {
                                _isSaving = true;
                              });
                              var res = await machine.uploadMachineData(machine);
                              setState(() {
                                _isSaving = false;
                              });
                              if (res != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error uploading data. Try again"),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please select an image"),
                                ),
                              );
                            }
                          }
                        },
                      ),
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
