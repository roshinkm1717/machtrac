import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  String email;
  String password;
  String mobile;
  String fullName;
  var image;
  String imageName;

  Future userLogin(User user) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email, password: user.password);
      return null;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return e.code.toString();
    }
  }

  signUpWithGoogle() async {}

  loginWithGoogle() async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebaseAuth.AuthCredential credential =
          firebaseAuth.GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      String email = _googleSignIn.currentUser.email;
      await firebaseAuth.FirebaseAuth.instance.signInWithCredential(credential);
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (!snapshot.exists) {
        await FirebaseFirestore.instance.collection('users').doc(email).set(
          {
            'remDaily': 100,
            'remWeekly': 25,
            'dailyTime': DateTime.now().millisecondsSinceEpoch,
            'weeklyTime': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }
      return null;
    } on PlatformException catch (e) {
      return e.message;
    }
  }

  Future registerUser(User user) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: user.email, password: user.password);
      await uploadDetails(user);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code.toString();
    }
  }

  Future uploadDetails(User user) async {
    String email = FirebaseAuth.instance.currentUser.email;
    String downloadUrl;
    Reference reference = FirebaseStorage.instance.ref('$email/${user.imageName}');
    try {
      await reference.putFile(user.image);
      downloadUrl = await reference.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user.email).set(
        {
          'imageUrl': downloadUrl,
          'fullName': user.fullName,
          'mobile': user.mobile,
          'remDaily': 100,
          'remWeekly': 25,
          'dailyTime': DateTime.now().millisecondsSinceEpoch,
          'weeklyTime': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
