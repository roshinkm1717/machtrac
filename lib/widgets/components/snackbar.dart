import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showSnackBar({BuildContext context, String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      duration: Duration(seconds: 1, milliseconds: 500),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      content: Text(
        message,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
  );
}
