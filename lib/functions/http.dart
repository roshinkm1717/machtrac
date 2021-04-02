import 'package:http/http.dart' as http;

Future<bool> checkFetchLink(String fetchLink) async {
  try {
    var response = await http.get(Uri.parse(fetchLink));
    if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
      //link invalid
      return false;
    } else {
      return true;
    }
  } catch (e) {
    print("Error occurred while parsing Url");
    return false;
  }
}
