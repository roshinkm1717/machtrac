import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  ActionButton({this.text, this.onPressed});
  final String text;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
