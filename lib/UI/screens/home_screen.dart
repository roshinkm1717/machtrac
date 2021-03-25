import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:machtrac/UI/screens/addMachine_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../Backend/machine.dart';
import 'login_screen.dart';
import 'machine_info.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd _ad;
  bool isLoaded;

  @override
  void initState() {
    super.initState();
    getUserImage();
    MobileAds.instance.initialize();
    _ad = BannerAd(
        size: AdSize.banner,
        adUnitId: "ca-app-pub-6444959581499725/8160194844",
        listener: AdListener(onAdLoaded: (_) {
          setState(() {
            isLoaded = true;
          });
        }, onAdFailedToLoad: (_, error) {
          print("Ad failed to load with error: $error");
        }),
        request: AdRequest());
    _ad.load();
    setState(() {});
    checkReportsData();
    _timer();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Widget checkForAd() {
    if (isLoaded == true) {
      return Container(
        child: AdWidget(
          ad: _ad,
        ),
        width: _ad.size.width.toDouble(),
        height: _ad.size.height.toDouble(),
        alignment: Alignment.center,
      );
    } else {
      return Container(color: Colors.grey, child: Center(child: CircularProgressIndicator()));
    }
  }

  void _timer() {
    print("Fetch data");
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
      return;
    } catch (e) {
      print(e);
    }
    String email = FirebaseAuth.instance.currentUser.email;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();
    setState(() {
      imageUrl = snapshot.data()['imageUrl'];
    });
  }

  checkReportsData() async {
    String email = FirebaseAuth.instance.currentUser.email;
    DocumentReference reference = FirebaseFirestore.instance.collection('users').doc(email);
    DocumentSnapshot document = await reference.get();
    dailyTime = document.data()['dailyTime'];
    weeklyTime = document.data()['weeklyTime'];
    if (DateTime.now().millisecondsSinceEpoch > (dailyTime + 86400000)) {
      await reference.update({
        'remDaily': 100,
        'dailyTime': dailyTime + 86400000,
      });
    }
    if (DateTime.now().millisecondsSinceEpoch > (dailyTime + (86400000 * 7))) {
      await reference.update({
        'remWeekly': 100,
        'weeklyTime': (dailyTime + (86400000 * 7)),
      });
    }
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
                  CircleAvatar(
                    child: imageUrl == null
                        ? Icon(Icons.person)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(400),
                            child: CircleAvatar(
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
                          content: Text("Harikrishna K V | 966333007 | harikrishnakv@outlook.com"),
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
                                            "${status.data == null ? 'Error' : (status.data == false ? 'Idle' : 'Running')}",
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
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          height: 200,
                          child: checkForAd(),
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
