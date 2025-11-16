// ignore: unused_import
import 'dart:ui';

import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale as Locale);

  @override
  String get appTitle => 'Partner Check';

  @override
  String get contactsPermissionRequired => 'Contacts permission is required';

  @override
  String get contactLimitReached => 'Contact Limit Reached';

  @override
  String get contactLimitMessage =>
      'You have reached the maximum of 10 contacts in the free version.\n\nUpgrade to PartnerCheck Pro to add unlimited contacts.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get selectedContactNoName => 'Selected contact has no name';

  @override
  String contactAlreadyInList(String contactName) {
    return '$contactName is already in the list';
  }

  @override
  String get noPhoneNumber => 'No Phone Number';

  @override
  String noPhoneNumberMessage(String contactName) {
    return '$contactName does not have a phone number. Please select a contact with a phone number.';
  }

  @override
  String errorPickingContact(String error) {
    return 'Error picking contact: $error';
  }

  @override
  String get deleteContact => 'Delete Contact';

  @override
  String deleteContactConfirm(String contactName) {
    return 'Are you sure you want to delete $contactName?';
  }

  @override
  String get addContactManually => 'Add Contact Manually';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get name => 'Name';

  @override
  String get enterContactName => 'Enter contact name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get phoneNumberOptional => 'Phone Number (optional)';

  @override
  String get enterPhoneNumberToChangeColor =>
      'Enter phone number to change color';

  @override
  String get leavePhoneEmptyKeepColor =>
      'Leave phone number empty to keep current color';

  @override
  String get addFromDevice => 'Add from device';

  @override
  String get addManually => 'Add manually';

  @override
  String get vibrations => 'Vibrations';

  @override
  String get loadContacts => 'Load Contacts';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionRequiredMessage =>
      'This app needs access to your contacts to check partner compatibility. Please grant permission in settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get contactsPermissionDenied => 'Contacts permission denied';

  @override
  String permissionDenied(String status) {
    return 'Permission denied: $status';
  }

  @override
  String errorLoadingContacts(String error) {
    return 'Error loading contacts: $error';
  }

  @override
  String get partnerCheckFree => 'PartnerCheck Free';

  @override
  String get loading => 'Loading...';
}
