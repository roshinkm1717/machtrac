import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class InputField extends StatelessWidget {
  InputField(
      {this.controller,
      this.labelText,
      this.onChanged,
      this.keyboardType,
      this.validator,
      this.obscureText,
      this.onIconTap,
      this.passwordCheckValidator});
  final String labelText;
  final TextInputType keyboardType;
  final Function onChanged;
  final MultiValidator validator;
  final Function passwordCheckValidator;
  final bool obscureText;
  final Function onIconTap;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffix: onIconTap != null
            ? GestureDetector(
                onTap: onIconTap,
                child: Icon(
                  Icons.visibility,
                  size: 18,
                  color: Colors.grey,
                ),
              )
            : SizedBox(),
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      onChanged: onChanged,
      validator: validator ?? RequiredValidator(errorText: "Cannot be empty"),
      obscureText: obscureText ?? false,
    );
  }
}
