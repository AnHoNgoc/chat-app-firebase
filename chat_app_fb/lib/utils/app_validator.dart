class AppValidator{

  static String? validateUser(value) {
    if (value!.isEmpty) {
      return "Please enter an user";
    }
    if (value.length > 30) {
      return "Email must be less than 30 characters";
    }

    return null;
  }

  static String? validateEmail(value) {
    if (value!.isEmpty) {
      return "Please enter an email";
    }
    RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }


  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    if (value.length < 6 || value.length > 30) {
      return "Password must be between 6 and 30 characters";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String newPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != newPassword) {
      return 'Passwords do not match';
    }
    if (value.length < 6 || value.length > 30) {
      return "Confirm password must be between 6 and 30 characters";
    }
    return null;
  }

  static String? validateNewPassword(String? value, String oldPassword) {
    if (value == null || value.isEmpty) {
      return 'Please enter your new password';
    }
    if (value.length < 6 || value.length > 30) {
      return "New password must be between 6 and 30 characters";
    }
    if (value == oldPassword) {
      return 'New password cannot be the same as the old password';
    }
    return null;
  }

  static String? isEmptyCheck(String? value) {
    if (value == null || value.isEmpty) {
      return "Please fill details";
    }
    return null;
  }

}