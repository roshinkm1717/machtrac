import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machtrac/functions/mailer.dart';

class WeeklyReport {
  var lastRequestedTime; // weekly time
  int reportsRemaining; //remWeekly
  WeeklyReport() {
    lastRequestedTime = 0;
    reportsRemaining = 0;
  }

  Future<List> getReportDataFromDatabase() async {
    String email = FirebaseAuth.instance.currentUser.email;
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('users').doc(email).get();
    int reportsRemaining = document.data()['remWeekly'];
    DateTime lastRequestedTime = DateTime.fromMillisecondsSinceEpoch(document.data()['weeklyTime']);
    return [reportsRemaining, lastRequestedTime];
  }

  updateReportData(WeeklyReport weeklyReport) async {
    String email = FirebaseAuth.instance.currentUser.email;
    weeklyReport.reportsRemaining--;
    weeklyReport.lastRequestedTime = DateTime.now().millisecondsSinceEpoch;
    try {
      await FirebaseFirestore.instance.collection('users').doc(email).update({
        'remWeekly': weeklyReport.reportsRemaining,
        'weeklyTime': weeklyReport.lastRequestedTime,
      });
    } catch (e) {
      print(e);
    }
  }

  requestReport(QueryDocumentSnapshot doc) async {
    String email = FirebaseAuth.instance.currentUser.email;
    sendReportRequestToMachtrac(
      machineName: doc['name'],
      machineMake: doc['make'],
      fetchLink: doc['fetchLink'],
      currentUser: email,
      isDaily: false,
    );
  }

  bool checkIfAlreadyRequested(WeeklyReport weeklyReport) {
    if (weeklyReport.lastRequestedTime != 0) {
      if (weeklyReport.lastRequestedTime == null || DateTime.now().difference(weeklyReport.lastRequestedTime).inDays == 0) {
        //Already requested for today
        return true;
      } else {
        return false;
        //Not requested for today
      }
    } else {
      return false;
      //not requested for today
    }
  }

  bool checkIfReportsRemaining(WeeklyReport weeklyReport) {
    if (weeklyReport.reportsRemaining > 0) {
      return true;
    } else {
      return false;
    }
  }
}
