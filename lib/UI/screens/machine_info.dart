import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/UI/screens/updateMachine_screen.dart';
import 'package:machtrac/UI/widgets/filled_button.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MachineInfo extends StatefulWidget {
  MachineInfo({this.doc, this.status});

  final QueryDocumentSnapshot doc;
  final AsyncSnapshot<dynamic> status;
  @override
  _MachineInfoState createState() => _MachineInfoState();
}

class _MachineInfoState extends State<MachineInfo> {
  Future<bool> checkDailyTopUpRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int milsec = (prefs.getInt('dailyTime') ?? 0);
    if (milsec == 0) {
      //no problems
      prefs.setInt('dailyTime', DateTime.now().millisecondsSinceEpoch);
      return true;
    } else if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(milsec)).inDays != 0) {
      //no problem
      prefs.setInt('dailyTime', DateTime.now().millisecondsSinceEpoch);
      return true;
    } else {
      //problem
      return false;
    }
  }

  Future<bool> checkweeklyTopUpRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int milsec = (prefs.getInt('weeklyTime') ?? 0);
    if (milsec == 0) {
      //no problems
      prefs.setInt('weeklyTime', DateTime.now().millisecondsSinceEpoch);
      return true;
    } else if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(milsec)).inDays != 0) {
      //no problem
      prefs.setInt('weeklyTime', DateTime.now().millisecondsSinceEpoch);
      return true;
    } else {
      //problem
      return false;
    }
  }

  void requestReportBoost(bool isDaily) async {
    var now = DateTime.now();

    String username = 'machtracorg@gmail.com';
    String password = 'machtrac@google';
    String email = FirebaseAuth.instance.currentUser.email;
    print(email);
    // ignore: deprecated_member_use
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Machtrac')
      ..recipients.add('machtrac.kmt@outlook.com')
      ..subject = 'Request For ${isDaily ? 'Daily' : '7 Day Report'} Report Boost'
      ..text =
          ' MailID : $email \n Machine Name : ${widget.doc['name']} \n Machine make : ${widget.doc['make']} \n Fetch link : ${widget.doc['fetchLink']} \n $now';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  void requestReport(bool isDaily) async {
    print(widget.doc.data());
    var now = DateTime.now();

    String username = 'machtracorg@gmail.com';
    String password = 'machtrac@google';
    String email = FirebaseAuth.instance.currentUser.email;
    // ignore: deprecated_member_use
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Machtrac')
      ..recipients.add('machtrac.kmt@outlook.com')
      ..subject = 'Request For ${isDaily ? 'Daily' : '7 Day'} Report'
      ..text =
          ' MailID : $email \n Machine Name : ${widget.doc['name']} \n Machine make : ${widget.doc['make']} \n Fetch link : ${widget.doc['fetchLink']} \n $now';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getReportData();
    setState(() {});
  }

  getReportData() async {
    String email = FirebaseAuth.instance.currentUser.email;
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('users').doc(email).get();
    print(document.data());
    setState(() {
      remDaily = document.data()['remDaily'];
      remWeekly = document.data()['remWeekly'];
      dailyTime = document.data()['dailyTime'];
      dailyTime = DateTime.fromMillisecondsSinceEpoch(dailyTime);
      weeklyTime = document.data()['weeklyTime'];
      weeklyTime = DateTime.fromMillisecondsSinceEpoch(weeklyTime);
      print(dailyTime);
      print(weeklyTime);
    });
  }

  updateReportData(bool isDaily) async {
    String email = FirebaseAuth.instance.currentUser.email;
    setState(() async {
      if (isDaily) {
        remDaily--;
        dailyTime = DateTime.now().millisecondsSinceEpoch;
        await FirebaseFirestore.instance.collection('users').doc(email).update({
          'remDaily': remDaily,
          "dailyTime": dailyTime,
        });
      } else {
        remWeekly--;
        weeklyTime = DateTime.now().millisecondsSinceEpoch;
        await FirebaseFirestore.instance.collection('users').doc(email).update({
          "remWeekly": remWeekly,
          "weeklyTime": weeklyTime,
        });
      }
    });
    setState(() {
      if (isDaily) {
        dailyTime = DateTime.fromMillisecondsSinceEpoch(dailyTime);
      } else {
        weeklyTime = DateTime.fromMillisecondsSinceEpoch(weeklyTime);
      }
    });
  }

  int dailyTopUpCount, weeklyTopUpCount;
  var dailyTime, weeklyTime;
  String _url = 'http://honingworld.com/';
  var remDaily = 0, remWeekly = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              //machine settings
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateMachineScreen(
                    doc: widget.doc,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: widget.doc['name'],
                  child: Card(
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        child: ListTile(
                          tileColor: widget.status.data == null
                              ? Colors.red.shade800
                              : (widget.status.data ? Colors.green.shade800 : Colors.yellow.shade800),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          leading: Container(
                            height: 100,
                            width: 100,
                            child: Image(
                              image: NetworkImage(widget.doc['imageUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            widget.doc['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "${widget.status.data == null ? 'No Signal' : (widget.status.data == false ? 'Idle' : 'Running')}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text("Machine make: ${widget.doc['make']}"),
                SizedBox(height: 10),
                Text("Capacity: ${widget.doc['capacity']}"),
                SizedBox(height: 10),
                Text("Year of Manufacturing: ${widget.doc['manYear']}"),
                SizedBox(height: 10),
                Text("Location: ${widget.doc['location']}"),
                SizedBox(height: 10),
                Divider(thickness: 3),
                SizedBox(height: 10),
                Text("Reports Remaining"),
                SizedBox(height: 5),
                Text("Daily: $remDaily\n7 Day Reports: $remWeekly"),
                SizedBox(height: 40),
                FilledButton(
                  text: "Generate Report",
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Which report to request?"),
                            actions: [
                              TextButton(
                                child: Text("Daily"),
                                onPressed: () {
                                  //daily report
                                  if (dailyTime != 0) {
                                    print(dailyTime);
                                    if (dailyTime == null || DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(dailyTime)).inDays == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Already requested for Today"),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      if (remDaily > 0) {
                                        updateReportData(true);
                                        requestReport(true);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("The request has been sent to Machtrac")),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Please Top up Report Balance to Request")),
                                        );
                                        Navigator.pop(context);
                                      }
                                    }
                                  } else {
                                    if (remDaily > 0) {
                                      updateReportData(true);
                                      requestReport(true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("The request has been sent to Machtrac")),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Please Top up Report Balance to Request")),
                                      );
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              ),
                              TextButton(
                                child: Text("7 Day Report"),
                                onPressed: () {
                                  //daily report
                                  if (weeklyTime != 0) {
                                    if (dailyTime == null || DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(weeklyTime)).inDays == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Already requested for Today"),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      if (remWeekly > 0) {
                                        updateReportData(false);
                                        requestReport(false);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("The request has been sent to Machtrac")),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Please Top up Report Balance to Request")),
                                        );
                                        Navigator.pop(context);
                                      }
                                    }
                                  } else {
                                    if (remWeekly > 0) {
                                      updateReportData(false);
                                      requestReport(false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("The request has been sent to Machtrac")),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Please Top up Report Balance to Request")),
                                      );
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              ),
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
                SizedBox(height: 10),
                if (remDaily == 0 || remWeekly == 0)
                  TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Which reports to top up?"),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    bool res = await checkDailyTopUpRequest();
                                    if (res) {
                                      requestReportBoost(true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("The request has been sent to Machtrac")),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Report has been already requested. Please wait for the response")),
                                      );
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Text("Daily"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    bool res = await checkweeklyTopUpRequest();
                                    if (res) {
                                      requestReportBoost(false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("The request has been sent to Machtrac")),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Report has been already requested. Please wait for the response")),
                                      );
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Text("7 Day Report"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel"),
                                ),
                              ],
                            );
                          });
                    },
                    child: Text("Request Report Top up"),
                  ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    try {
                      await launch(_url);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    width: double.infinity,
                    height: 150,
                    child: Card(
                      borderOnForeground: true,
                      elevation: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Get to Know Us Better"),
                            Text(
                              "Honing World",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                            ),
                            Text(
                              "From Krishna Machine Tools",
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
