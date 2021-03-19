import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  String email;
  String password;
  String mobile;
  String fullName;

  Future userLogin(User user) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email, password: user.password);
      return null;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      return e.code.toString();
    }
  }

  Future registerUser(User user) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: user.email, password: user.password);
      await uploadDetails(user);
      return null;
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.code.toString();
    }
  }

  Future uploadDetails(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.email).set(
        {
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
