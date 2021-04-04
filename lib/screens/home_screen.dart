import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/widgets/buttons/floating_button.dart';
import 'package:machtrac/widgets/components/machine_card.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:machtrac/widgets/components/homescreen_appbar.dart';

import '../models/machine.dart';

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
    _timer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _timer() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  getUserImage() async {
    try {
      User user = FirebaseAuth.instance.currentUser;
      setState(() {
        userName = user.displayName;
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

  Timer timer;
  String imageUrl, userName;
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
          floatingActionButton: AddMachineFloatingButton(),
          appBar: HomeScreenAppBar(imageUrl: imageUrl, displayName: userName),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(email)
                    .collection('machines')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
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
                                return MachineCard(
                                  doc: doc,
                                  status: status.data,
                                );
                              },
                            );
                          }).toList()),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Its Error!');
                  } else {
                    return Center(child: CircularProgressIndicator());
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
