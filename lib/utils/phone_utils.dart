/// Utility functions for phone number operations
class PhoneUtils {
  static const int minPhoneDigits = 6;

  /// Strips all non-digit characters from a phone number string.
  static String sanitizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'\D'), '');
  }

  /// Whether [phoneNumber] contains at least [minPhoneDigits] digits.
  static bool hasMinimumDigits(String phoneNumber) {
    return sanitizePhoneNumber(phoneNumber).length >= minPhoneDigits;
  }

  /// Calculate color value from phone number
  /// Takes the last 6 digits and converts them to a hex color value
  static int colorFromPhoneNumber(String phoneNumber) {
    final digits = sanitizePhoneNumber(phoneNumber);
    if (digits.isEmpty) return 0;

    final hexDigits = digits.length >= 6
        ? digits.substring(digits.length - 6)
        : digits.padLeft(6, '0');

    return int.tryParse(hexDigits, radix: 16) ?? 0;
  }
}
