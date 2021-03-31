import 'package:flutter/material.dart';
import 'package:machtrac/models/topup.dart';
import 'package:machtrac/widgets/components/snackbar.dart';

AlertDialog buildTopUpReportDialog(BuildContext context, TopUp topUp, Function getData) {
  return AlertDialog(
    title: Text("Which reports to top up?"),
    actions: [
      TextButton(
        onPressed: () async {
          if (await topUp.ifAlreadyRequestedForDailyTopUp(topUp)) {
            //already requested for daily top up
            showSnackBar(context: context, message: "Already requested for Today. Please wait for the response");
          } else {
            //requested top up
            topUp.sendRequest(true);
            getData();
            showSnackBar(context: context, message: "Request sent to Machtrac");
          }
          Navigator.pop(context);
        },
        child: Text("Daily"),
      ), //Daily Report top up Button
      TextButton(
        onPressed: () async {
          if (await topUp.ifAlreadyRequestedForWeeklyTopUp(topUp)) {
            //already requested for weekly to up
            showSnackBar(context: context, message: "Already requested for . Please wait for the response");
          } else {
            //requested for top up
            topUp.sendRequest(false);
            getData();
            showSnackBar(context: context, message: "Request sent to Machtrac");
          }
          Navigator.pop(context);
        },
        child: Text("7 Day Report"),
      ), //Weekly report top up button
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Cancel"),
      ), //cancel button
    ],
  );
}
