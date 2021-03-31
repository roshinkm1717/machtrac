import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/models/daily_report.dart';
import 'package:machtrac/models/weekly_report.dart';
import 'package:machtrac/widgets/components/snackbar.dart';

AlertDialog buildGenerateReportDialog(
    BuildContext context, DailyReport dailyReport, WeeklyReport weeklyReport, DocumentSnapshot doc, Function getData) {
  return AlertDialog(
    title: Text("Which report to request?"),
    actions: [
      TextButton(
        child: Text("Daily"),
        onPressed: () {
          //daily report
          if (dailyReport.checkIfAlreadyRequested(dailyReport)) {
            //already requested
            showSnackBar(context: context, message: "Already Requested for today");
            Navigator.pop(context);
          } else {
            //not requested for today
            if (dailyReport.checkIfReportsRemaining(dailyReport)) {
              //reports are remaining
              dailyReport.updateReportData(dailyReport);
              dailyReport.requestReport(doc);
              getData();
              showSnackBar(context: context, message: "The Request has been sent to Machtrac");
              Navigator.pop(context);
            } else {
              //no reports remaining
              showSnackBar(context: context, message: "Please top up report balance to request");
              Navigator.pop(context);
            }
          }
        },
      ), //daily report button
      TextButton(
        child: Text("7 Day Report"),
        onPressed: () {
          //weekly report
          if (weeklyReport.checkIfAlreadyRequested(weeklyReport)) {
            //already requested
            showSnackBar(context: context, message: "Already Requested for today");
            Navigator.pop(context);
          } else {
            //not requested for today
            if (weeklyReport.checkIfReportsRemaining(weeklyReport)) {
              //reports are remaining
              weeklyReport.updateReportData(weeklyReport);
              weeklyReport.requestReport(doc);
              getData();
              showSnackBar(context: context, message: "The Request has been sent to Machtrac");
              Navigator.pop(context);
            } else {
              //no reports remaining
              showSnackBar(context: context, message: "Please top up report balance to request");
              Navigator.pop(context);
            }
          }
        },
      ), //weekly report button
      TextButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.pop(context);
        },
      ), //cancel button
    ],
  );
}
