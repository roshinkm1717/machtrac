import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/models/daily_report.dart';
import 'package:machtrac/models/topup.dart';
import 'package:machtrac/models/weekly_report.dart';
import 'package:machtrac/screens/updateMachine_screen.dart';
import 'package:machtrac/widgets/buttons/primary_button.dart';
import 'package:machtrac/widgets/components/banner.dart';
import 'package:machtrac/widgets/components/machine_card.dart';
import 'package:machtrac/widgets/dialog/generateReport_dialog.dart';
import 'package:machtrac/widgets/dialog/topUpReport_dialog.dart';

class MachineInfo extends StatefulWidget {
  MachineInfo({this.doc, this.status});

  final QueryDocumentSnapshot doc;
  final AsyncSnapshot<dynamic> status;
  @override
  _MachineInfoState createState() => _MachineInfoState();
}

class _MachineInfoState extends State<MachineInfo> {
  @override
  void initState() {
    super.initState();
    getDataFromDatabase();
    setState(() {});
  }

  getDataFromDatabase() async {
    List resDaily = await dailyReport.getReportDataFromDatabase();
    List resWeekly = await weeklyReport.getReportDataFromDatabase();
    setState(() {
      dailyReport.reportsRemaining = resDaily[0];
      dailyReport.lastRequestedTime = resDaily[1];
      weeklyReport.reportsRemaining = resWeekly[0];
      weeklyReport.lastRequestedTime = resWeekly[1];
    });
    if (dailyReport.reportsRemaining == 0 || weeklyReport.reportsRemaining == 0) {
    List topUpData = await topUp.getTopUpData();
    setState(() {
      topUp.lastRequestedDailyTime = topUpData[0];
      topUp.lastRequestedWeeklyTime = topUpData[1];
    });
    print("getting data regarding reports from db...");
    }
  }

  Function p() {
    print("Inside p");
    return getDataFromDatabase();
  }

  TopUp topUp = TopUp();
  WeeklyReport weeklyReport = WeeklyReport();
  DailyReport dailyReport = DailyReport();
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
          ), //Edit Button
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MachineCard(
                  doc: widget.doc,
                  status: widget.status,
                ),
                SizedBox(height: 30),
                Text("Machine make: ${widget.doc['make']}"), //machine make
                SizedBox(height: 10),
                Text("Capacity: ${widget.doc['capacity']}"), //machine capacity
                SizedBox(height: 10),
                Text("Year of Manufacturing: ${widget.doc['manYear']}"), //machine year of manufacturing
                SizedBox(height: 10),
                Text("Location: ${widget.doc['location']}"), //machine location
                SizedBox(height: 10),
                Divider(thickness: 3),
                SizedBox(height: 10),
                Text("Reports Remaining"),
                SizedBox(height: 5),
                Text(
                    "Daily: ${dailyReport.reportsRemaining}\n7 Day Reports: ${weeklyReport.reportsRemaining}"), //reports remaining
                SizedBox(height: 40),
                PrimaryButton(
                  text: "Generate Report",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return buildGenerateReportDialog(
                            context, dailyReport, weeklyReport, widget.doc, getDataFromDatabase);
                      },
                    );
                  },
                ), //generate report button
                SizedBox(height: 10),
                if (dailyReport.reportsRemaining == 0 || weeklyReport.reportsRemaining == 0)
                  //check if any reports are empty
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return buildTopUpReportDialog(context, topUp, getDataFromDatabase);
                        },
                      );
                    },
                    child: Text("Request Report Top up"),
                  ), //report topUp button
                SizedBox(height: 20),
                BannerAd(), //Honing world banner
              ],
            ),
          ),
        ),
      ),
    );
  }
}
