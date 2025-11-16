// ignore: unused_import
import 'dart:ui';

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale as Locale);

  @override
  String get appTitle => 'Partner Check';

  @override
  String get contactsPermissionRequired =>
      'Je vyžadováno oprávnění ke kontaktům';

  @override
  String get contactLimitReached => 'Dosažen limit kontaktů';

  @override
  String get contactLimitMessage =>
      'Dosáhli jste maximálního počtu 10 kontaktů ve verzi zdarma.\n\nUpgradujte na PartnerCheck Pro pro přidání neomezeného počtu kontaktů.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Zrušit';

  @override
  String get delete => 'Smazat';

  @override
  String get save => 'Uložit';

  @override
  String get add => 'Přidat';

  @override
  String get close => 'Zavřít';

  @override
  String get selectedContactNoName => 'Vybraný kontakt nemá jméno';

  @override
  String contactAlreadyInList(String contactName) {
    return '$contactName je již v seznamu';
  }

  @override
  String get noPhoneNumber => 'Bez telefonního čísla';

  @override
  String noPhoneNumberMessage(String contactName) {
    return '$contactName nemá telefonní číslo. Prosím vyberte kontakt s telefonním číslem.';
  }

  @override
  String errorPickingContact(String error) {
    return 'Chyba při výběru kontaktu: $error';
  }

  @override
  String get deleteContact => 'Smazat kontakt';

  @override
  String deleteContactConfirm(String contactName) {
    return 'Opravdu chcete smazat $contactName?';
  }

  @override
  String get addContactManually => 'Přidat kontakt ručně';

  @override
  String get editContact => 'Upravit kontakt';

  @override
  String get name => 'Jméno';

  @override
  String get enterContactName => 'Zadejte jméno kontaktu';

  @override
  String get phoneNumber => 'Telefonní číslo';

  @override
  String get enterPhoneNumber => 'Zadejte telefonní číslo';

  @override
  String get phoneNumberOptional => 'Telefonní číslo (volitelné)';

  @override
  String get enterPhoneNumberToChangeColor =>
      'Zadejte telefonní číslo pro změnu barvy';

  @override
  String get leavePhoneEmptyKeepColor =>
      'Ponechte telefonní číslo prázdné pro zachování současné barvy';

  @override
  String get addFromDevice => 'Přidat ze zařízení';

  @override
  String get addManually => 'Přidat ručně';

  @override
  String get vibrations => 'Vibrace';

  @override
  String get loadContacts => 'Načíst kontakty';

  @override
  String get permissionRequired => 'Vyžadováno oprávnění';

  @override
  String get permissionRequiredMessage =>
      'Tato aplikace potřebuje přístup ke kontaktům pro kontrolu kompatibility partnerů. Prosím udělte oprávnění v nastavení.';

  @override
  String get openSettings => 'Otevřít nastavení';

  @override
  String get contactsPermissionDenied => 'Oprávnění ke kontaktům zamítnuto';

  @override
  String permissionDenied(String status) {
    return 'Oprávnění zamítnuto: $status';
  }

  @override
  String errorLoadingContacts(String error) {
    return 'Chyba při načítání kontaktů: $error';
  }

  @override
  String get partnerCheckFree => 'PartnerCheck Free';

  @override
  String get loading => 'Načítání...';
}
