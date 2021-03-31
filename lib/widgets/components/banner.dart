import 'package:flutter/material.dart';
import 'package:machtrac/functions/url_launcher.dart';

class BannerAd extends StatelessWidget {
  final String url = 'http://honingworld.com/';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await launchUrl(url);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 4),
          borderRadius: BorderRadius.circular(15),
        ),
        width: double.infinity,
        height: 150,
        child: Card(
          borderOnForeground: true,
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Get to Know Us Better"),
                Text(
                  "Honing World",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                ),
                Text(
                  "From Krishna Machine Tools",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
