class ProfileValidationService {
  String? validateName(String input) {
    final text = input.trim();
    if (text.isEmpty) {
      return 'Name is required';
    }
    if (text.length < 2) {
      return 'Enter a valid name';
    }
    return null;
  }

  String? validateGender(String? input) {
    final text = (input ?? '').trim();
    if (text.isEmpty) {
      return 'Gender is required';
    }
    return null;
  }

  String? validateEmail(String input) {
    final text = input.trim();
    if (text.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[A-Za-z0-9._+\-]+@[A-Za-z0-9\-]+\.[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(text)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validateEmergency(String input) {
    final text = input.trim();
    if (text.isEmpty) {
      return 'Emergency contact is required';
    }
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Enter 10-digit emergency contact';
    }
    if (RegExp(r'^(\d)\1{9}$').hasMatch(digits)) {
      return 'Invalid emergency contact';
    }
    return null;
  }

  String normalizeEmergency(String input) {
    return input.replaceAll(RegExp(r'\s+'), '');
  }
}
