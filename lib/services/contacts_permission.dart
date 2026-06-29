import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../utils/platform_info.dart';
import '../widgets/device_contact_picker_dialog.dart';

const contactsNameAndPhoneProperties = {
  ContactProperty.name,
  ContactProperty.phone,
};

Future<bool> ensureContactsReadPermission() async {
  if (!supportsDeviceContacts) {
    return false;
  }

  final status = await FlutterContacts.permissions.request(PermissionType.read);
  return status == PermissionStatus.granted ||
      status == PermissionStatus.limited;
}

Future<Contact?> pickContactWithNameAndPhone(BuildContext context) {
  if (isAndroid || isIOS) {
    return FlutterContacts.native.showPicker(
      properties: contactsNameAndPhoneProperties,
    );
  }
  if (isMacOS) {
    return showDeviceContactPickerDialog(context);
  }
  return Future.value(null);
}

/// Opens the platform contacts-permission settings page.
Future<void> openContactsSettings() {
  if (!supportsDeviceContacts) {
    return Future.value();
  }
  return FlutterContacts.permissions.openSettings();
}
