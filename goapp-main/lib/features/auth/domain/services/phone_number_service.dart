class PhoneNumberService {
  String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String formatIndian(String digits) {
    if (digits.length <= 5) {
      return digits;
    }
    return '${digits.substring(0, 5)} ${digits.substring(5)}';
  }

  String? validateIndian(String input) {
    final digits = digitsOnly(input);
    if (digits.isEmpty) {
      return 'Mobile number is required';
    }
    if (digits.length != 10) {
      return 'Enter 10-digit mobile number';
    }
    if (_isAllSameDigits(digits)) {
      return 'Invalid mobile number';
    }
    if (_isSequential(digits)) {
      return 'Invalid mobile number';
    }
    return null;
  }

  String? toE164(String input) {
    final error = validateIndian(input);
    if (error != null) return null;
    final digits = digitsOnly(input);
    return '+91$digits';
  }

  bool _isAllSameDigits(String digits) {
    if (digits.isEmpty) return false;
    return digits.split('').every((d) => d == digits[0]);
  }

  bool _isSequential(String digits) {
    if (digits.length < 2) return false;
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < digits.length; i += 1) {
      final prev = int.tryParse(digits[i - 1]);
      final curr = int.tryParse(digits[i]);
      if (prev == null || curr == null) return false;
      if (curr != prev + 1) ascending = false;
      if (curr != prev - 1) descending = false;
    }
    return ascending || descending;
  }
}
