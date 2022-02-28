String? validateEmail(String? value){
  if (value==null || value.isEmpty) {
    return 'This field is required';
  }

  // using regular expression
  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
    return "Please enter a valid email address";
  }

  // the email is valid
  return null;
}


String? validatePassword(String? value){
  //Function used to validate password
  if (value==null|| value.isEmpty) {
    return 'This field is required';
  }

  // using regular expression
  if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!,;:-_?!@#\$&*~]).{8,}$').hasMatch(value)) {
    return "Must be 8 chars long with at least 1 upper and 1 symbol";
  }

  // the email is valid
  return null;
}

String? simpleValidation(String? value){
  //Function used to validate password
  if (value==null|| value.isEmpty) {
    return 'This field is required';
  }
  return null;
}
