import 'package:flutter/material.dart';
import 'package:machtrac/functions/url_launcher.dart';

import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/buttons/primary_button.dart';
import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/buttons/secondary_button.dart';

class ContactInfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("KMT, Bangalore"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Harikrishna K V",
            style: TextStyle(fontSize: 16),
          ), //Name
          SecondaryButton(
            text: "9663330007",
            onPressed: () async {
              //launch phone to machtrac
              await launchPhone(9663330007);
            },
          ), //phone button
          SecondaryButton(
            text: "machtrac.kmt@outlook.com",
            onPressed: () async {
              //launch mail to machtrac
              await launchEmail("machtrac.kmt@outlook.com", "Report Issues");
            },
          ),
          PrimaryButton(
            text: "Report Issues",
            onPressed: () async {
              //report issue to machtrac
              await launchEmail("machtrac.kmt@outlook.com", "Report Issues");
            },
          ),
        ],
      ),
    );
  }
}
