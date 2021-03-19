import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilledButton extends StatelessWidget {
  FilledButton({this.onPressed, this.text});
  final Function onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
