import 'package:atpl_flashing_app/utils/strings.dart';

String? requiredValidation(val) {
  if (val == null || val.isEmpty) {
    return Strings.errorMsgRequired;
  }
  return null;
}

String? requiredPasswordValidation(val) {
  if (val == null || val.isEmpty) {
    return "Please Enter Your Password";
  }
  return null;
}

String? requiredEmailValidation(val) {
  if (val == null || val == "") {
    return 'Please Enter Email Address';
  } else if (!val.contains('@') || !val.contains('.')) {
    return 'Please Enter valid Email Address';
  }
  return null;
}

String? loginMobileNumberValidator(val) {
  if (val == null) {
    return Strings.errorMsgRequired;
  } else if (val!.length != 10) {
    return Strings.errorMsglength10;
  }
  return null;
}

String? loginMobileNumberValidator2(val) {
  if (val == null) {
    return Strings.errorMsgRequired; // Return error if value is null
  } else {
    // Use the regular expression for mobile number validation
    RegExp regex = RegExp(r'^[6-9]\d{9}$');
    if (!regex.hasMatch(val)) {
      return Strings.errorMsglength10;
    }
  }
  return null;
}

String? loginEmailOrMobileValidator(String? val) {
  if (val == null || val.isEmpty) {
    return Strings.errorMsgRequired;
  } else {
    if (RegExp(r'^\d+$').hasMatch(val)) {
      RegExp mobileRegex = RegExp(r'^[6-9]\d{9}$');
      if (!mobileRegex.hasMatch(val)) {
        return Strings.errorMsglength10;
      }
    } else if (val.contains('.')) {
      RegExp emailRegex =
          RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
      if (!emailRegex.hasMatch(val)) {
        return "Please Enter valid Email Address";
      }
    } else {
      return null;
    }
  }
  return null;
}

String? otpValidation(val) {
  if (val == "") {
    return Strings.errorMsgRequired;
  } else if (val!.length != 6) {
    return Strings.errorMsglength4;
  }
  return null;
}
