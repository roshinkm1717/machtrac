import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:machtrac/Backend/machine.dart';
import 'package:machtrac/UI/widgets/filled_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path/path.dart';

import 'home_screen.dart';

class UpdateMachineScreen extends StatefulWidget {
  UpdateMachineScreen({this.doc});
  final QueryDocumentSnapshot doc;
  @override
  _UpdateMachineScreenState createState() => _UpdateMachineScreenState();
}

class _UpdateMachineScreenState extends State<UpdateMachineScreen> {
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

  initState() {
    super.initState();
    setState(() {
      machine.name = widget.doc['name'];
      machine.manYear = widget.doc['manYear'];
      machine.capacity = widget.doc['capacity'];
      machine.make = widget.doc['make'];
      machine.fetchLink = widget.doc['fetchLink'];
      oldName = machine.name;
      oldImageName = widget.doc['imageName'];
      machine.location = widget.doc['location'];
      controller.text = machine.location;
    });
  }

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

  openCamera() async {
    PickedFile pickedFile = await ImagePicker.platform.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        machine.image = File(pickedFile.path);
        machine.imageName = basename(pickedFile.path);
      });
    }
  }

  var controller = TextEditingController();
  String oldName, oldImageName;
  bool _isSaving = false;
  Machine machine = Machine();
  final formKey = GlobalKey<FormState>();
  bool _link = true;
  @override
  Widget build(BuildContext context) {
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
                          initialValue: machine.name,
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
                          initialValue: machine.make,
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
                          initialValue: machine.manYear.toString(),
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
                                initialValue: machine.fetchLink,
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
                          },
                          child: Text("Scan QR"),
                        ),
                        TextFormField(
                          initialValue: machine.capacity,
                          decoration: InputDecoration(
                            labelText: "Capacity",
                          ),
                          onFieldSubmitted: (value) {
                            print(value);
                          },
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
                        text: "Update",
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirm changes?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        //update
                                        if (formKey.currentState.validate()) {
                                          //add machine
                                          setState(() {
                                            _isSaving = true;
                                          });
                                          var res = await machine.updateMachine(machine, oldName, oldImageName);
                                          setState(() {
                                            _isSaving = false;
                                          });
                                          if (res != null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Error updating data. Try again"),
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
                                        }
                                      },
                                      child: Text("Update"),
                                    ),
                                  ],
                                );
                              });
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
