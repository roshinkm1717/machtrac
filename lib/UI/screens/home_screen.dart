import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:machtrac/UI/screens/addMachine_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Backend/machine.dart';
import 'login_screen.dart';
import 'machine_info.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoaded;

  @override
  void initState() {
    super.initState();
    getUserImage();
    setState(() {});
    _timer();
  }

  void _timer() {
    Future.delayed(Duration(seconds: 3)).then((_) {
      setState(() {});
      _timer();
    });
  }

  getUserImage() async {
    try {
      User user = FirebaseAuth.instance.currentUser;
      setState(() {
        imageUrl = user.photoURL;
      });
      if (imageUrl != null) {
        return;
      }
    } catch (e) {
      print(e);
    }
    String email = FirebaseAuth.instance.currentUser.email;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();
    setState(() {
      imageUrl = snapshot.data()['imageUrl'];
    });
  }

  GoogleSignIn _googleSignIn;
  String imageUrl;
  bool _isSaving = false;
  var dailyTime, weeklyTime;
  String email = FirebaseAuth.instance.currentUser.email;
  List<QueryDocumentSnapshot> docs;
  Machine machine = Machine();
  @override
  Widget build(BuildContext context) {
    return DoubleBack(
      message: "Tap again to close app",
      child: ModalProgressHUD(
        inAsyncCall: _isSaving,
        progressIndicator: CircularProgressIndicator(),
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            elevation: 4,
            heroTag: 'button',
            child: Icon(Icons.add),
            onPressed: () {
              //add a machine
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMachineScreen(),
                ),
              );
            },
          ),
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      child: imageUrl == null
                          ? Icon(Icons.person)
                          : Container(
                              height: 35,
                              width: 35,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Machtrac",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("KMT, Bangalore"),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("  Harikrishna K V"),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    launch('tel: 9663330007');
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: Text(
                                  'Ph: 9663330007',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final Uri _emailLaunchUri = Uri(
                                    scheme: 'mailto',
                                    path: 'harikrishnakv@outlook.com',
                                    query: 'subject=Report Issues', //add subject and body here
                                  );
                                  try {
                                    await launch(_emailLaunchUri.toString());
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: Text(
                                  'harikrishnakv@outlook.com',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final Uri _emailLaunchUri = Uri(
                                    scheme: 'mailto',
                                    path: 'harikrishnakv@outlook.com',
                                    query: 'subject=Report Issues', //add subject and body here
                                  );
                                  try {
                                    await launch(_emailLaunchUri.toString());
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: Text('Report Issues'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel")),
                          ],
                        );
                      });
                },
                child: Text(
                  "Contact us",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  //logout
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("You sure to sign out?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel")),
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  _isSaving = true;
                                });
                                try {
                                  await _googleSignIn.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                      (Route<dynamic> route) => false);
                                } catch (e) {
                                  print(e);
                                }
                                await FirebaseAuth.instance.signOut();
                                setState(() {
                                  _isSaving = false;
                                });
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                    (Route<dynamic> route) => false);
                              },
                              child: Text("Logout"),
                            ),
                          ],
                        );
                      });
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(email).collection('machines').orderBy('timestamp', descending: true).get(),
                // ignore: missing_return
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> documents = snapshot.data.docs;
                    return Column(
                      children: [
                        Expanded(
                          child: ListView(
                              children: documents.map((doc) {
                            return FutureBuilder(
                              future: machine.getMachineStatus(doc['fetchLink']),
                              builder: (context, status) {
                                return GestureDetector(
                                  onTap: () {
                                    //machine info
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MachineInfo(
                                          doc: doc,
                                          status: status,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: doc['name'],
                                    child: Card(
                                      elevation: 5,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: ListTile(
                                          tileColor: status.data == null
                                              ? Colors.red.shade800
                                              : (status.data ? Colors.green.shade800 : Colors.yellow.shade800),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          leading: Container(
                                            height: 100,
                                            width: 100,
                                            child: Image(
                                              image: NetworkImage(doc['imageUrl']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          title: Text(
                                            doc['name'],
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            "${status.data == null ? 'No Signal' : (status.data == false ? 'Idle' : 'Running')}",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList()),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Its Error!');
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
