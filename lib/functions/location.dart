import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  return await Geolocator.getCurrentPosition();
}

Future<String> getNameFromPosition(Position location) async {
  String locationName;
  List<Placemark> placeMarks = await placemarkFromCoordinates(location.latitude, location.longitude);
  locationName = placeMarks[0].locality + "," + placeMarks[0].administrativeArea + "," + placeMarks[0].country;
  return locationName;
}
