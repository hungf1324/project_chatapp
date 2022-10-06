import 'package:form_field_validator/form_field_validator.dart';

class FormValidators {
  static RequiredValidator requiredValidator = RequiredValidator(
    errorText: 'This field is required',
  );
  static EmailValidator emailValidator = EmailValidator(
    errorText: 'Please enter a valid email',
  );
  static MultiValidator passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(6, errorText: 'Password need at least 6 digits long'),
    MaxLengthValidator(12, errorText: 'Password only upto 12 digits long'),
  ]);
}
