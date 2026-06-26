import 'package:flutter_contacts/flutter_contacts.dart';

import '../models.dart';
import '../services/contact_storage_service.dart';
import 'phone_utils.dart';

/// Finds a stored contact that matches the device owner / picked "self" contact.
class SelfContactFinder {
  static int? findIndexInList(
    List<StoredContact> contacts, {
    String? name,
    String? phoneNumber,
    int? color,
  }) {
    if (color != null) {
      final byColor = contacts.indexWhere((c) => c.color == color);
      if (byColor >= 0) return byColor;
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final phoneColor = PhoneUtils.colorFromPhoneNumber(phoneNumber);
      final byPhoneColor = contacts.indexWhere((c) => c.color == phoneColor);
      if (byPhoneColor >= 0) return byPhoneColor;
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

  static int? findIndexForStoredSelf(
    List<StoredContact> contacts,
    StoredSelfContact self,
  ) {
    return findIndexInList(
      contacts,
      name: self.name,
      color: self.color,
    );
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
