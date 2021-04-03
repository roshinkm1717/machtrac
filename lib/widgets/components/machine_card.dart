import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:machtrac/screens/machine_info.dart';

class MachineCard extends StatelessWidget {
  MachineCard({this.doc, this.status});
  final DocumentSnapshot doc;
  final bool status;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: doc['name'],
      child: Card(
        elevation: 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MachineInfo(
                    doc: doc,
                    status: status,
                  ),
                ),
              );
            },
            tileColor: status == null ? Colors.red.shade800 : (status ? Colors.green.shade800 : Colors.yellow.shade900),
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
              "${status == null ? 'No Signal' : (status == false ? 'Idle' : 'Running')}",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
