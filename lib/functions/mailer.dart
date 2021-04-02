import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

sendReportRequestToMachtrac(
    {String machineName, String machineMake, String fetchLink, String currentUser, bool isDaily}) async {
  var currentTime = DateTime.now();
  String username = 'machtracorg@gmail.com';
  String password = 'machtrac@google';
  // ignore: deprecated_member_use
  final smtpServer = gmail(username, password);
  final message = Message()
    ..from = Address(username, 'Machtrac')
    ..recipients.add('machtrac.kmt@outlook.com')
    ..subject = 'Request For' + (isDaily ? "Daily" : "7 Day") + "Report"
    ..text =
        ' MailID : $currentUser \n Machine Name : $machineName \n Machine make : $machineMake \n Fetch link : $fetchLink \n $currentTime';
  try {
    await send(message, smtpServer);
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

sendTopUpRequestToMachtrac({bool isDaily, String currentUser}) async {
  var currentTime = DateTime.now();
  String username = 'machtracorg@gmail.com';
  String password = 'machtrac@google';
  // ignore: deprecated_member_use
  final smtpServer = gmail(username, password);
  final message = Message()
    ..from = Address(username, 'Machtrac')
    ..recipients.add('machtrac.kmt@outlook.com')
    ..subject = 'Request For' + (isDaily ? "Daily" : "7 Day") + "Report Boost"
    ..text = ' MailID : $currentUser';
  try {
    await send(message, smtpServer);
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}
