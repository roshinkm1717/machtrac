import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/provider/machine_data.dart';
import 'package:machtrac/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MachineData(),
      child: MaterialApp(
        title: 'Machtrac',
        theme: ThemeData(
          fontFamily: 'Montserrat',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: WelcomeScreen(),
      ),
    );
  }
}
