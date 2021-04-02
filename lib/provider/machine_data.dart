import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:machtrac/functions/http.dart' as http_fn;
import 'package:machtrac/functions/location.dart';
import 'package:machtrac/functions/storage.dart' as storage;
import 'package:path/path.dart';

class MachineData extends ChangeNotifier {
  String _imageName;
  var _image;
  String location, fetchLink;
  bool isFetchLinkCorrect;
  bool isSaving;
  MachineData({this.isSaving = false, this.location, this.isFetchLinkCorrect, this.fetchLink});

  get image => _image;
  get imageName => _imageName;

  void getImageFromCamera() async {
    String imagePath = await storage.getImageFromCamera();
    if (imagePath != null) {
      _imageName = basename(imagePath);
      _image = File(imagePath);
    }
    notifyListeners();
  }

  void getImageFromStorage() async {
    String imagePath = await storage.getImageFromStorage();
    if (imagePath != null) {
      _imageName = basename(imagePath);
      _image = File(imagePath);
    }
    notifyListeners();
  }

  Future<String> getLocation() async {
    Position coordinates = await determinePosition();
    location = await getNameFromPosition(coordinates);
    return location;
  }

  checkFetchLink(String fetchLink) async {
    print("inside check fetch link");
    bool response = await http_fn.checkFetchLink(fetchLink);
    isFetchLinkCorrect = response;
    notifyListeners();
  }

  Future<String> getLinkFromQR() async {
    String result = await storage.getLinkFromQR();
    fetchLink = result;
    notifyListeners();
    return fetchLink;
  }

  void toggleSaving() {
    isSaving = !isSaving;
    notifyListeners();
  }
}
