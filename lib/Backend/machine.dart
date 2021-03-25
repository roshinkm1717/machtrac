import 'dart:convert' as convert;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class Machine {
  String name;
  String fetchLink;
  int manYear;
  String capacity;
  String imageName;
  String location;
  var image;
  String make;

  Future uploadMachineData(Machine machine) async {
    String email = FirebaseAuth.instance.currentUser.email;
    String downloadUrl;
    try {
      print("trying to upload machine data!");
      DocumentReference documentReference = FirebaseFirestore.instance.collection('users').doc(email).collection('machines').doc();
      await documentReference.set({
        'name': machine.name,
        'fetchLink': machine.fetchLink,
        'manYear': machine.manYear,
        'imageName': machine.imageName,
        'capacity': machine.capacity,
        'make': machine.make,
        'location': machine.location,
        'timestamp': DateTime.now(),
      });
      Reference ref = FirebaseStorage.instance.ref("$email/${documentReference.id}/${machine.imageName}");
      await ref.putFile(machine.image);
      downloadUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(email).collection('machines').doc(documentReference.id).update(
        {'imageUrl': downloadUrl},
      );
      print("uploaded!");
      return null;
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<bool> getMachineStatus(String link) async {
    var response = await http.get(Uri.parse(link));
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var machStatus = jsonResponse[0]['value'];
      return machStatus == '10' ? Future.value(true) : Future.value(false);
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return Future.value(false);
    }
  }

  Future updateMachine(Machine machine, String oldName, String oldImageName) async {
    print("updating...");
    String email = FirebaseAuth.instance.currentUser.email;
    String downloadUrl;
    var snapshots = await FirebaseFirestore.instance.collection('users').doc(email).collection('machines').where('name', isEqualTo: oldName).get();
    try {
      DocumentSnapshot doc = snapshots.docs.first;
      print(doc.id);
      if (machine.imageName != null) {
        Reference photoRef = FirebaseStorage.instance.ref(email).child("${doc.id}/$oldImageName");
        await photoRef.delete();
        print("\n\ndeleted!");
        Reference ref = FirebaseStorage.instance.ref("$email/${doc.id}/${machine.imageName}");
        await ref.putFile(machine.image);
        downloadUrl = await ref.getDownloadURL();
        doc.reference.update({
          'location': machine.location,
          'imageName': machine.imageName,
          'name': machine.name,
          'make': machine.make,
          'manYear': machine.manYear,
          'fetchLink': machine.fetchLink,
          'capacity': machine.capacity,
          'imageUrl': downloadUrl,
        });
      } else {
        doc.reference.update({
          'location': machine.location,
          'name': machine.name,
          'make': machine.make,
          'manYear': machine.manYear,
          'fetchLink': machine.fetchLink,
          'capacity': machine.capacity,
        });
      }
    } catch (e) {
      print(e);
      return e;
    }
  }
}
