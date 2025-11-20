/// Utility functions for phone number operations
class PhoneUtils {
  /// Calculate color value from phone number
  /// Takes the last 6 digits and converts them to a hex color value
  static int colorFromPhoneNumber(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 0;
    
    final hexDigits = digits.length >= 6
        ? digits.substring(digits.length - 6)
        : digits.padLeft(6, '0');
    
    return int.tryParse(hexDigits, radix: 16) ?? 0;
  }
}

