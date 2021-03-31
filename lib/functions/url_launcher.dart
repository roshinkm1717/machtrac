import 'package:url_launcher/url_launcher.dart';

Future<void> launchPhone(int phone) async {
  try {
    launch('tel: $phone');
  } catch (e) {
    print(e);
  }
}

Future<void> launchEmail(String email, String subject) async {
  final Uri _emailLaunchUri = Uri(
    scheme: 'mailto',
    path: '$email',
    query: 'subject=$subject', //add subject and body here
  );
  try {
    await launch(_emailLaunchUri.toString());
  } catch (e) {
    print(e);
  }
}

Future<void> launchUrl(String url) async {
  try {
    await launch(url);
  } catch (e) {
    print(e);
  }
}
