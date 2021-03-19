import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/UI/screens/updateMachine_screen.dart';
import 'package:machtrac/UI/widgets/filled_button.dart';
import 'package:url_launcher/url_launcher.dart';

class MachineInfo extends StatefulWidget {
  MachineInfo({this.doc, this.status});
  final QueryDocumentSnapshot doc;
  final AsyncSnapshot<dynamic> status;
  @override
  _MachineInfoState createState() => _MachineInfoState();
}

class _MachineInfoState extends State<MachineInfo> {
  void _launchMail(bool isDaily) async {
    var now = DateTime.now();
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'harikrishnakv@outlook.com',
      query:
          'subject=Request For ${isDaily ? 'Daily' : 'Weekly'} Report  &body= Machine Name : ${widget.doc['name']} \n Machine make : ${widget.doc['make']} \n Fetch link : ${widget.doc['fetchLink']} \n $now', //add subject and body here
    );
    if (await canLaunch(_emailLaunchUri.toString())) {
      await launch(_emailLaunchUri.toString());
    } else {
      throw 'could not mail';
    }
  }

  @override
  void initState() {
    super.initState();
    getReportData();
  }

  getReportData() async {
    String email = FirebaseAuth.instance.currentUser.email;
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('users').doc(email).get();
    print(document.data());
    setState(() {
      remDaily = document.data()['remDaily'];
      remWeekly = document.data()['remWeekly'];
    });
  }

  updateReportData(bool isDaily) async {
    String email = FirebaseAuth.instance.currentUser.email;
    if (isDaily) {
      remDaily--;
    } else {
      remWeekly--;
    }
    await FirebaseFirestore.instance.collection('users').doc(email).update({
      'remDaily': remDaily,
      "remWeekly": remWeekly,
    });
  }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: widget.doc['name'],
                child: Card(
                  elevation: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: ListTile(
                      tileColor:
                          widget.status.data == null ? Colors.red.shade800 : (widget.status.data ? Colors.green.shade800 : Colors.yellow.shade800),
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
                        "${widget.status.data == null ? 'Error' : (widget.status.data == false ? 'Idle' : 'Running')}",
                        style: TextStyle(color: Colors.white),
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
              Text("Daily: $remDaily\nWeekly: $remWeekly"),
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
                                updateReportData(true);
                                remDaily + 1 > 0 ? _launchMail(true) : Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text("Weekly"),
                              onPressed: () {
                                //weekly report
                                updateReportData(false);
                                remWeekly + 1 > 0 ? _launchMail(false) : Navigator.pop(context);
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
            ],
          ),
        ),
      ),
    );
  }
}
