import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

Future<bool> statusRequest(String machId) async {
  var userName = 'Harikrishnakv';
  var feedId = 'kmt-cnc-lathe';
  var response =
      await http.get(Uri.parse('https://io.adafruit.com/api/v2/$userName/feeds/$feedId/data/$machId?x-aio-key=aio_PJWb22QPEjy31tEUFS3MQdxAIGGn'));

  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    var machStatus = jsonResponse['value'];

    print('status Value : $machStatus');
    print("Status : ${machStatus == '10'}");

    return machStatus == '10' ? Future.value(true) : Future.value(false);
  } else {
    print('Request failed with status: ${response.statusCode}.');
    return Future.value(false);
  }
}

//  bool test = await statusRequest('0ENXZNQQPA6CVAQYZYTJ7F8X9J');
//   print(test);

//use this id for testing every mach is idle so it will return false

//0ENXZNQQPA6CVAQYZYTJ7F8X9J
//0ENXZNQ403TBCKYZBG2DDNPSX8
//0ENXZNPG8XYZAHRGN85S4QBJQB

//when mach is running : returns true
