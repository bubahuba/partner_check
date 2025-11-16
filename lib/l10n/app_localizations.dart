import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('cs'),
  ];

  // Translations
  String get appTitle => _localizedValues[locale.languageCode]?['appTitle'] ?? 'Partner Check';
  String get contactsPermissionRequired => _localizedValues[locale.languageCode]?['contactsPermissionRequired'] ?? 'Contacts permission is required';
  String get contactLimitReached => _localizedValues[locale.languageCode]?['contactLimitReached'] ?? 'Contact Limit Reached';
  String get contactLimitMessage => _localizedValues[locale.languageCode]?['contactLimitMessage'] ?? 'You have reached the maximum of 10 contacts in the free version.\n\nUpgrade to PartnerCheck Pro to add unlimited contacts.';
  String get ok => _localizedValues[locale.languageCode]?['ok'] ?? 'OK';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get add => _localizedValues[locale.languageCode]?['add'] ?? 'Add';
  String get close => _localizedValues[locale.languageCode]?['close'] ?? 'Close';
  String get selectedContactNoName => _localizedValues[locale.languageCode]?['selectedContactNoName'] ?? 'Selected contact has no name';
  String contactAlreadyInList(String contactName) => (_localizedValues[locale.languageCode]?['contactAlreadyInList'] ?? '{contactName} is already in the list').replaceAll('{contactName}', contactName);
  String get noPhoneNumber => _localizedValues[locale.languageCode]?['noPhoneNumber'] ?? 'No Phone Number';
  String noPhoneNumberMessage(String contactName) => (_localizedValues[locale.languageCode]?['noPhoneNumberMessage'] ?? '{contactName} does not have a phone number. Please select a contact with a phone number.').replaceAll('{contactName}', contactName);
  String errorPickingContact(String error) => (_localizedValues[locale.languageCode]?['errorPickingContact'] ?? 'Error picking contact: {error}').replaceAll('{error}', error);
  String errorAddingContact(String error) => (_localizedValues[locale.languageCode]?['errorAddingContact'] ?? 'Error adding contact: {error}').replaceAll('{error}', error);
  String get deleteContact => _localizedValues[locale.languageCode]?['deleteContact'] ?? 'Delete Contact';
  String deleteContactConfirm(String contactName) => (_localizedValues[locale.languageCode]?['deleteContactConfirm'] ?? 'Are you sure you want to delete {contactName}?').replaceAll('{contactName}', contactName);
  String get addContactManually => _localizedValues[locale.languageCode]?['addContactManually'] ?? 'Add Contact Manually';
  String get editContact => _localizedValues[locale.languageCode]?['editContact'] ?? 'Edit Contact';
  String get name => _localizedValues[locale.languageCode]?['name'] ?? 'Name';
  String get enterContactName => _localizedValues[locale.languageCode]?['enterContactName'] ?? 'Enter contact name';
  String get phoneNumber => _localizedValues[locale.languageCode]?['phoneNumber'] ?? 'Phone Number';
  String get enterPhoneNumber => _localizedValues[locale.languageCode]?['enterPhoneNumber'] ?? 'Enter phone number';
  String get phoneNumberOptional => _localizedValues[locale.languageCode]?['phoneNumberOptional'] ?? 'Phone Number (optional)';
  String get enterPhoneNumberToChangeColor => _localizedValues[locale.languageCode]?['enterPhoneNumberToChangeColor'] ?? 'Enter phone number to change color';
  String get leavePhoneEmptyKeepColor => _localizedValues[locale.languageCode]?['leavePhoneEmptyKeepColor'] ?? 'Leave phone number empty to keep current color';
  String get addFromDevice => _localizedValues[locale.languageCode]?['addFromDevice'] ?? 'Add from device';
  String get addManually => _localizedValues[locale.languageCode]?['addManually'] ?? 'Add manually';
  String get vibrations => _localizedValues[locale.languageCode]?['vibrations'] ?? 'Vibrations';
  String get loadContacts => _localizedValues[locale.languageCode]?['loadContacts'] ?? 'Load Contacts';
  String get addContact => _localizedValues[locale.languageCode]?['addContact'] ?? 'Add Contact';
  String get adding => _localizedValues[locale.languageCode]?['adding'] ?? 'Adding...';
  String get permissionRequired => _localizedValues[locale.languageCode]?['permissionRequired'] ?? 'Permission Required';
  String get permissionRequiredMessage => _localizedValues[locale.languageCode]?['permissionRequiredMessage'] ?? 'This app needs access to your contacts to check partner compatibility. Please grant permission in settings.';
  String get openSettings => _localizedValues[locale.languageCode]?['openSettings'] ?? 'Open Settings';
  String get contactsPermissionDenied => _localizedValues[locale.languageCode]?['contactsPermissionDenied'] ?? 'Contacts permission denied';
  String permissionDenied(String status) => (_localizedValues[locale.languageCode]?['permissionDenied'] ?? 'Permission denied: {status}').replaceAll('{status}', status);
  String errorLoadingContacts(String error) => (_localizedValues[locale.languageCode]?['errorLoadingContacts'] ?? 'Error loading contacts: {error}').replaceAll('{error}', error);
  String get partnerCheckFree => _localizedValues[locale.languageCode]?['partnerCheckFree'] ?? 'PartnerCheck Free';
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get aboutTitle => _localizedValues[locale.languageCode]?['aboutTitle'] ?? 'About';
  String get aboutText => _localizedValues[locale.languageCode]?['aboutText'] ?? 'every person has a phone (or more)\n\nevery phone has the last 6 digits\n\nevery 6 digits has a color (in hexadecimal code)\n\nevery color has a person (?)\n\nThere is no coincidence!\n\nThis app brings you a unique opportunity to take a different look at the world of phone numbers belonging to specific people. Go through all the possible combinations and find out that coincidence does not exist.';

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Contacts permission is required',
      'contactLimitReached': 'Contact Limit Reached',
      'contactLimitMessage': 'You have reached the maximum of 10 contacts in the free version.\n\nUpgrade to PartnerCheck Pro to add unlimited contacts.',
      'ok': 'OK',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'save': 'Save',
      'add': 'Add',
      'close': 'Close',
      'selectedContactNoName': 'Selected contact has no name',
      'contactAlreadyInList': '{contactName} is already in the list',
      'noPhoneNumber': 'No Phone Number',
      'noPhoneNumberMessage': '{contactName} does not have a phone number. Please select a contact with a phone number.',
      'errorPickingContact': 'Error picking contact: {error}',
      'errorAddingContact': 'Error adding contact: {error}',
      'deleteContact': 'Delete Contact',
      'deleteContactConfirm': 'Are you sure you want to delete {contactName}?',
      'addContactManually': 'Add Contact Manually',
      'editContact': 'Edit Contact',
      'name': 'Name',
      'enterContactName': 'Enter contact name',
      'phoneNumber': 'Phone Number',
      'enterPhoneNumber': 'Enter phone number',
      'phoneNumberOptional': 'Phone Number (optional)',
      'enterPhoneNumberToChangeColor': 'Enter phone number to change color',
      'leavePhoneEmptyKeepColor': 'Leave phone number empty to keep current color',
      'addFromDevice': 'Add from device',
      'addManually': 'Add manually',
      'vibrations': 'Vibrations',
      'loadContacts': 'Load Contacts',
      'addContact': 'Add Contact',
      'adding': 'Adding...',
      'permissionRequired': 'Permission Required',
      'permissionRequiredMessage': 'This app needs access to your contacts to check partner compatibility. Please grant permission in settings.',
      'openSettings': 'Open Settings',
      'contactsPermissionDenied': 'Contacts permission denied',
      'permissionDenied': 'Permission denied: {status}',
      'errorLoadingContacts': 'Error loading contacts: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Loading...',
      'aboutTitle': 'About',
      'aboutText': 'Every person has a phone (or more)\n\nevery phone has the last 6 digits\n\nevery 6 digits has a color (in hexadecimal code)\n\nevery color has a person (?)\n\nThere is no coincidence!\n\nThis app brings you a unique opportunity to take a different look at the world of phone numbers belonging to specific people. Go through all the possible combinations and find out that coincidence does not exist.\n\nDoes it match or not?',
    },
    'cs': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Je vyžadováno oprávnění ke kontaktům',
      'contactLimitReached': 'Dosažen limit kontaktů',
      'contactLimitMessage': 'Dosáhli jste maximálního počtu 10 kontaktů ve verzi zdarma.\n\nUpgradujte na PartnerCheck Pro pro přidání neomezeného počtu kontaktů.',
      'ok': 'OK',
      'cancel': 'Zrušit',
      'delete': 'Smazat',
      'save': 'Uložit',
      'add': 'Přidat',
      'close': 'Zavřít',
      'selectedContactNoName': 'Vybraný kontakt nemá jméno',
      'contactAlreadyInList': '{contactName} je již v seznamu',
      'noPhoneNumber': 'Bez telefonního čísla',
      'noPhoneNumberMessage': '{contactName} nemá telefonní číslo. Prosím vyberte kontakt s telefonním číslem.',
      'errorPickingContact': 'Chyba při výběru kontaktu: {error}',
      'errorAddingContact': 'Chyba při přidávání kontaktu: {error}',
      'deleteContact': 'Smazat kontakt',
      'deleteContactConfirm': 'Opravdu chcete smazat {contactName}?',
      'addContactManually': 'Přidat kontakt ručně',
      'editContact': 'Upravit kontakt',
      'name': 'Jméno',
      'enterContactName': 'Zadejte jméno kontaktu',
      'phoneNumber': 'Telefonní číslo',
      'enterPhoneNumber': 'Zadejte telefonní číslo',
      'phoneNumberOptional': 'Telefonní číslo (volitelné)',
      'enterPhoneNumberToChangeColor': 'Zadejte telefonní číslo pro změnu barvy',
      'leavePhoneEmptyKeepColor': 'Ponechte telefonní číslo prázdné pro zachování současné barvy',
      'addFromDevice': 'Přidat ze zařízení',
      'addManually': 'Přidat ručně',
      'vibrations': 'Vibrace',
      'loadContacts': 'Načíst kontakty',
      'addContact': 'Přidat kontakt',
      'adding': 'Přidávání...',
      'permissionRequired': 'Vyžadováno oprávnění',
      'permissionRequiredMessage': 'Tato aplikace potřebuje přístup ke kontaktům pro kontrolu kompatibility partnerů. Prosím udělte oprávnění v nastavení.',
      'openSettings': 'Otevřít nastavení',
      'contactsPermissionDenied': 'Oprávnění ke kontaktům zamítnuto',
      'permissionDenied': 'Oprávnění zamítnuto: {status}',
      'errorLoadingContacts': 'Chyba při načítání kontaktů: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Načítání...',
      'aboutTitle': 'O aplikaci',
      'aboutText': 'Každý člověk má telefon (nebo více)\n\nkaždý telefon má posledních 6 číslic\n\nkaždých 6 číslic má barvu (v hexadecimálním kódu)\n\nkaždá barva má člověka (?)\n\nNáhoda neexistuje!\n\nTato aplikace vám přináší jedinečnou příležitost podívat se jinak na svět telefonních čísel patřících konkrétním lidem. Projděte všechny možné kombinace a zjistěte, že náhoda neexistuje.\n\nLadí tedy? Neladí?',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'cs'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

