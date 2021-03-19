import 'package:form_field_validator/form_field_validator.dart';

final emailValidator = MultiValidator([
  EmailValidator(errorText: "Enter a valid Email"),
  RequiredValidator(errorText: "Email is required"),
]);
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: "Password is required"),
  MinLengthValidator(8, errorText: 'Password must be at least 8 digits long'),
]);
