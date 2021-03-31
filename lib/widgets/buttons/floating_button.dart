import 'package:flutter/material.dart';
import 'package:machtrac/screens/addMachine_screen.dart';

class AddMachineFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        //go to add machine screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddMachineScreen(),
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }
}
