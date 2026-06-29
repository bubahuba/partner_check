import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../widgets/device_contact_picker_dialog.dart';

const contactsNameAndPhoneProperties = {
  ContactProperty.name,
  ContactProperty.phone,
};

Future<bool> ensureContactsReadPermission() async {
  final status = await FlutterContacts.permissions.request(PermissionType.read);
  return status == PermissionStatus.granted ||
      status == PermissionStatus.limited;
}

Future<Contact?> pickContactWithNameAndPhone(BuildContext context) {
  if (Platform.isAndroid || Platform.isIOS) {
    return FlutterContacts.native.showPicker(
      properties: contactsNameAndPhoneProperties,
    );
  }
  if (Platform.isMacOS) {
    return showDeviceContactPickerDialog(context);
  }
  return Future.value(null);
}

/// Opens the platform contacts-permission settings page.
Future<void> openContactsSettings() {
  return FlutterContacts.permissions.openSettings();
}
