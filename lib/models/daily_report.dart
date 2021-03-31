import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machtrac/functions/mailer.dart';

class DailyReport {
  var lastRequestedTime; // daily time
  int reportsRemaining; //remDaily
  DailyReport() {
    lastRequestedTime = 0;
    reportsRemaining = 0;
  }

  Future<List> getReportDataFromDatabase() async {
    String email = FirebaseAuth.instance.currentUser.email;
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('users').doc(email).get();
    int reportsRemaining = document.data()['remDaily'];
    DateTime lastRequestedTime = DateTime.fromMillisecondsSinceEpoch(document.data()['dailyTime']);
    return [reportsRemaining, lastRequestedTime];
  }

  updateReportData(DailyReport dailyReport) async {
    String email = FirebaseAuth.instance.currentUser.email;
    dailyReport.reportsRemaining--;
    dailyReport.lastRequestedTime = DateTime.now().millisecondsSinceEpoch;
    try {
      await FirebaseFirestore.instance.collection('users').doc(email).update({
        'remDaily': dailyReport.reportsRemaining,
        'dailyTime': dailyReport.lastRequestedTime,
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
      isDaily: true,
    );
  }

  bool checkIfAlreadyRequested(DailyReport dailyReport) {
    if (dailyReport.lastRequestedTime != 0) {
      if (dailyReport.lastRequestedTime == null || DateTime.now().difference(dailyReport.lastRequestedTime).inDays == 0) {
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

  bool checkIfReportsRemaining(DailyReport dailyReport) {
    if (dailyReport.reportsRemaining > 0) {
      return true;
    } else {
      return false;
    }
  }
}
