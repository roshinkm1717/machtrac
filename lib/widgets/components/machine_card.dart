import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MachineCard extends StatelessWidget {
  MachineCard({this.doc, this.status});
  final DocumentSnapshot doc;
  final AsyncSnapshot<dynamic> status;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: doc['name'],
      child: Card(
        elevation: 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: ListTile(
            tileColor: status.data == null ? Colors.red.shade800 : (status.data ? Colors.green.shade800 : Colors.yellow.shade900),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            leading: Container(
              height: 100,
              width: 100,
              child: Image(
                image: NetworkImage(doc['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              doc['name'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            subtitle: Text(
              "${status.data == null ? 'No Signal' : (status.data == false ? 'Idle' : 'Running')}",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
