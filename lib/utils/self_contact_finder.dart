import 'package:flutter_contacts/flutter_contacts.dart';

import '../models.dart';
import 'phone_utils.dart';

/// Finds a stored contact that matches the device owner / picked "self" contact.
class SelfContactFinder {
  static int? findIndexInList(
    List<StoredContact> contacts, {
    String? name,
    String? phoneNumber,
  }) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final color = PhoneUtils.colorFromPhoneNumber(phoneNumber);
      final byColor = contacts.indexWhere((c) => c.color == color);
      if (byColor >= 0) return byColor;
    }

    if (name != null && name.isNotEmpty) {
      final lower = name.toLowerCase().trim();
      final byName = contacts.indexWhere(
        (c) => c.name.toLowerCase().trim() == lower,
      );
      if (byName >= 0) return byName;
    }

    return null;
  }

  static int? findIndexForContact(
    List<StoredContact> contacts,
    Contact contact,
  ) {
    final phone =
        contact.phones.isNotEmpty ? contact.phones.first.number : null;
    return findIndexInList(
      contacts,
      name: contact.displayName,
      phoneNumber: phone,
    );
  }
}
