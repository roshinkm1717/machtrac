import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:machtrac/models/machine.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/buttons/primary_button.dart';

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
  openCamera() async {
    PickedFile pickedFile = await ImagePicker.platform.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        machine.image = File(pickedFile.path);
        machine.imageName = basename(pickedFile.path);
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
        machine.image = File(result.paths[0]);
        print(machine.image);
        machine.imageName = basename(result.paths[0]);
      });
    }
  }

  var controller = TextEditingController();
  var linkController = TextEditingController();
  bool _isSaving = false;
  Machine machine = Machine();
  final formKey = GlobalKey<FormState>();
  bool _link = false;
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: linkController,
                                decoration: InputDecoration(
                                  labelText: "Fetch link",
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    machine.fetchLink = value;
                                  });
                                },
                                validator: RequiredValidator(
                                  errorText: "Cannot be empty",
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (machine.fetchLink != null) {
                                  try {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Checking link"),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    var response = await http.get(Uri.parse(machine.fetchLink));
                                    if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
                                      setState(() {
                                        _link = false;
                                      });
                                    } else
                                      setState(() {
                                        _link = true;
                                      });
                                  } catch (e) {
                                    setState(() {
                                      _link = false;
                                    });
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.check_circle_outline_rounded,
                                color: (_link ?? false) ? Colors.green : Colors.red,
                                size: 32,
                              ),
                              focusColor: (_link ?? false) ? Colors.green : Colors.red,
                              color: (_link ?? false) ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
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
                            String cameraScanResult = await scanner.scan();
                            setState(() {
                              machine.fetchLink = cameraScanResult;
                              linkController.text = cameraScanResult;
                            });
                          },
                          child: Text("Scan QR"),
                        ),
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
                            ),
                            SizedBox(width: 10),
                            Text("Or"),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(side: BorderSide(color: Colors.blue)),
                                onPressed: () {
                                  //select image
                                  getImage();
                                },
                                child: Text(machine.imageName == null ? "Select image" : machine.imageName),
                              ),
                            ),
                          ],
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
                      child: PrimaryButton(
                          text: "Add Machine",
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              if (machine.imageName != null) {
                                //add machine
                                if (_link) {
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
                                      content: Text("Please check the fetch link and try again"),
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
                          }),
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
