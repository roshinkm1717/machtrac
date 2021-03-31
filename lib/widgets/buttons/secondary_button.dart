import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  SecondaryButton({this.text, this.onPressed});
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
      style: TextButton.styleFrom(
        side: BorderSide(color: Colors.blue),
      ),
    );
  }
}
