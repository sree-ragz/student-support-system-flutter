class Validator {
  static String? validateName({required String? name}) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = RegExp(patttern);

    if (name!.isEmpty) {
      return 'Name can\'t be empty';
    } else if (!regExp.hasMatch(name)) {
      return "Invalid Username";
    } else {
      return null;
    }
  }

  static String? validateEmail({required String? email}) {
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)$");
    if (email!.isEmpty) {
      return 'Email cant be empty';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Enter a correct email';
    }
    return null;
  }

  static String? validatePassword({required String? password}) {
    RegExp regExp = RegExp(r"^[a-zA-Z0-9.!#$%&'+/=?^_`{|}~-]");

    if (password == null) {
      return null;
    }
    if (password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 6) {
      return 'Enter a passsword with atleast 6 characters';
    } else if (!regExp.hasMatch(password)) {
      return 'Enter a Strong password';
    }
    return null;
  }
}
