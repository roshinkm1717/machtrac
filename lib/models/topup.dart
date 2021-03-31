import 'package:firebase_auth/firebase_auth.dart';
import 'package:machtrac/functions/mailer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopUp {
  int lastRequestedDailyTime;
  int lastRequestedWeeklyTime;

  Future<List> getTopUpData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int lastReqDailyTimeInMilSec = (preferences.getInt('dailyTime') ?? 0);
    int lastReqWeeklyTimeInMilSec = (preferences.getInt('weeklyTime') ?? 0);
    return [lastReqDailyTimeInMilSec, lastReqWeeklyTimeInMilSec];
  }

  Future<bool> ifAlreadyRequestedForDailyTopUp(TopUp topUp) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (topUp.lastRequestedDailyTime == 0) {
      //not requested yet
      preferences.setInt('dailyTime', DateTime.now().millisecondsSinceEpoch);
      return false;
    } else if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(topUp.lastRequestedDailyTime)).inDays != 0) {
      //not requested yet
      preferences.setInt('dailyTime', DateTime.now().millisecondsSinceEpoch);
      return false;
    } else {
      //already requested
      return true;
    }
  }

  Future<bool> ifAlreadyRequestedForWeeklyTopUp(TopUp topUp) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (topUp.lastRequestedWeeklyTime == 0) {
      //not requested yet
      preferences.setInt('weeklyTime', DateTime.now().millisecondsSinceEpoch);
      return false;
    } else if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(topUp.lastRequestedWeeklyTime)).inDays != 0) {
      //not requested yet
      preferences.setInt('weeklyTime', DateTime.now().millisecondsSinceEpoch);
      return false;
    } else {
      //already requested
      return true;
    }
  }

  sendRequest(bool isDaily) {
    String email = FirebaseAuth.instance.currentUser.email;
    sendTopUpRequestToMachtrac(isDaily: isDaily, currentUser: email);
  }
}
