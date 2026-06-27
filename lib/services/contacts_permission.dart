import 'package:flutter_contacts/flutter_contacts.dart';

const contactsNameAndPhoneProperties = {
  ContactProperty.name,
  ContactProperty.phone,
};

Future<bool> ensureContactsReadPermission() async {
  final status = await FlutterContacts.permissions.request(PermissionType.read);
  return status == PermissionStatus.granted ||
      status == PermissionStatus.limited;
}

Future<Contact?> pickContactWithNameAndPhone() {
  return FlutterContacts.native.showPicker(
    properties: contactsNameAndPhoneProperties,
  );
}
