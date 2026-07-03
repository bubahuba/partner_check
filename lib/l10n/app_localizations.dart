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
    Locale('ar'),
    Locale('he'),
    Locale('cs'),
    Locale('sk'),
    Locale('zh'),
    Locale('ja'),
    Locale('nl'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('pl'),
    Locale('hu'),
    Locale('ru'),
    Locale('pt'),
    Locale('ua'),
  ];

  static bool isRtlLanguage(String languageCode) {
    return languageCode == 'ar' || languageCode == 'he';
  }

  static String normalizeLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'iw':
        return 'he';
      case 'uk':
        return 'ua';
      default:
        return languageCode;
    }
  }

  bool get isRtl => isRtlLanguage(locale.languageCode);

  // Translations
  String get appTitle =>
      _localizedValues[locale.languageCode]?['appTitle'] ?? 'Partner Check';
  String get contactsPermissionRequired =>
      _localizedValues[locale.languageCode]?['contactsPermissionRequired'] ??
      'Contacts permission is required';
  String get contactLimitReached =>
      _localizedValues[locale.languageCode]?['contactLimitReached'] ??
      'Contact Limit Reached';
  String get contactLimitMessage =>
      _localizedValues[locale.languageCode]?['contactLimitMessage'] ??
      'You have reached the maximum of 10 contacts in the free version.\n\nUpgrade to PartnerCheck Pro to add unlimited contacts.';
  String get ok => _localizedValues[locale.languageCode]?['ok'] ?? 'OK';
  String get cancel =>
      _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get delete =>
      _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get add => _localizedValues[locale.languageCode]?['add'] ?? 'Add';
  String get close =>
      _localizedValues[locale.languageCode]?['close'] ?? 'Close';
  String get selectedContactNoName =>
      _localizedValues[locale.languageCode]?['selectedContactNoName'] ??
      'Selected contact has no name';
  String contactAlreadyInList(String contactName) =>
      (_localizedValues[locale.languageCode]?['contactAlreadyInList'] ??
              '{contactName} is already in the list')
          .replaceAll('{contactName}', contactName);
  String get noPhoneNumber =>
      _localizedValues[locale.languageCode]?['noPhoneNumber'] ??
      'No Phone Number';
  String noPhoneNumberMessage(String contactName) => (_localizedValues[
              locale.languageCode]?['noPhoneNumberMessage'] ??
          '{contactName} does not have a phone number. Please select a contact with a phone number.')
      .replaceAll('{contactName}', contactName);
  String errorPickingContact(String error) =>
      (_localizedValues[locale.languageCode]?['errorPickingContact'] ??
              'Error picking contact: {error}')
          .replaceAll('{error}', error);
  String get deleteContact =>
      _localizedValues[locale.languageCode]?['deleteContact'] ??
      'Delete Contact';
  String deleteContactConfirm(String contactName) =>
      (_localizedValues[locale.languageCode]?['deleteContactConfirm'] ??
              'Are you sure you want to delete {contactName}?')
          .replaceAll('{contactName}', contactName);
  String get addContactManually =>
      _localizedValues[locale.languageCode]?['addContactManually'] ??
      'Add Contact Manually';
  String get editContact =>
      _localizedValues[locale.languageCode]?['editContact'] ?? 'Edit Contact';
  String get name => _localizedValues[locale.languageCode]?['name'] ?? 'Name';
  String get enterContactName =>
      _localizedValues[locale.languageCode]?['enterContactName'] ??
      'Enter contact name';
  String get phoneNumber =>
      _localizedValues[locale.languageCode]?['phoneNumber'] ?? 'Phone Number';
  String get enterPhoneNumber =>
      _localizedValues[locale.languageCode]?['enterPhoneNumber'] ??
      'Enter phone number';
  String get phoneNumberOptional =>
      _localizedValues[locale.languageCode]?['phoneNumberOptional'] ??
      'Phone Number (optional)';
  String get enterPhoneNumberToChangeColor =>
      _localizedValues[locale.languageCode]?['enterPhoneNumberToChangeColor'] ??
      'Enter phone number to change color';
  String get leavePhoneEmptyKeepColor =>
      _localizedValues[locale.languageCode]?['leavePhoneEmptyKeepColor'] ??
      'Leave phone number empty to keep current color';
  String get phoneNumberMinDigits =>
      _localizedValues[locale.languageCode]?['phoneNumberMinDigits'] ??
      'Enter at least 6 digits';
  String get addFromDevice =>
      _localizedValues[locale.languageCode]?['addFromDevice'] ??
      'Add from device';
  String get searchContacts =>
      _localizedValues[locale.languageCode]?['searchContacts'] ??
      'Search contacts';
  String get noDeviceContactsFound =>
      _localizedValues[locale.languageCode]?['noDeviceContactsFound'] ??
      'No contacts found on this device';
  String get addManually =>
      _localizedValues[locale.languageCode]?['addManually'] ?? 'Add manually';
  String get addContact =>
      _localizedValues[locale.languageCode]?['addContact'] ?? 'Add Contact';
  String get vibrations =>
      _localizedValues[locale.languageCode]?['vibrations'] ?? 'Vibrations';
  String get loadContacts =>
      _localizedValues[locale.languageCode]?['loadContacts'] ?? 'Load Contacts';
  String get loadAllContacts =>
      _localizedValues[locale.languageCode]?['loadAllContacts'] ??
      'Load all contacts';
  String get permissionRequired =>
      _localizedValues[locale.languageCode]?['permissionRequired'] ??
      'Permission Required';
  String get permissionRequiredMessage =>
      _localizedValues[locale.languageCode]?['permissionRequiredMessage'] ??
      'This app needs access to your contacts to check partner compatibility. Please grant permission in settings.';
  String get openSettings =>
      _localizedValues[locale.languageCode]?['openSettings'] ?? 'Open Settings';
  String get settings =>
      _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get contactsPermissionDenied =>
      _localizedValues[locale.languageCode]?['contactsPermissionDenied'] ??
      'Contacts permission denied';
  String permissionDenied(String status) =>
      (_localizedValues[locale.languageCode]?['permissionDenied'] ??
              'Permission denied: {status}')
          .replaceAll('{status}', status);
  String errorLoadingContacts(String error) =>
      (_localizedValues[locale.languageCode]?['errorLoadingContacts'] ??
              'Error loading contacts: {error}')
          .replaceAll('{error}', error);
  String get partnerCheckFree =>
      _localizedValues[locale.languageCode]?['partnerCheckFree'] ??
      'PartnerCheck Free';
  String get loading =>
      _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get loadingContactsFromDevice =>
      _localizedValues[locale.languageCode]?['loadingContactsFromDevice'] ??
      'Reading contacts from device...';
  String loadingContactsProgress(int current, int total) =>
      (_localizedValues[locale.languageCode]?['loadingContactsProgress'] ??
              '{current} of {total}')
          .replaceAll('{current}', '$current')
          .replaceAll('{total}', '$total');
  String get aboutTitle =>
      _localizedValues[locale.languageCode]?['aboutTitle'] ?? 'About';
  String get aboutText =>
      _localizedValues[locale.languageCode]?['aboutText'] ??
      'Every person has a phone (or more)\n\nevery phone has the last 6 digits\n\nevery 6 digits has a color (in hexadecimal code)\n\nevery color has a person (?)\n\nThere is no coincidence!\n\nThis app brings an unique opportunity to take a different look at the world of phone numbers belonging to specific people. Go through all the possible combinations and find out that coincidence does not exist.\n\nDoes it match or not?';
  String get heartIconDescription =>
      _localizedValues[locale.languageCode]?['heartIconDescription'] ??
      'Mark contact as favorite';
  String get chartIconDescription =>
      _localizedValues[locale.languageCode]?['chartIconDescription'] ??
      'Reorder contacts by match count';
  String get trashIconDescription =>
      _localizedValues[locale.languageCode]?['trashIconDescription'] ??
      'Delete contact';
  String get tetrisIconDescription =>
      _localizedValues[locale.languageCode]?['tetrisIconDescription'] ??
      'Play Tetris with your colors';
  String get plasmaIconDescription =>
      _localizedValues[locale.languageCode]?['plasmaIconDescription'] ??
      'Watch plasma in your colors';
  String get tetrisLinkCopied =>
      _localizedValues[locale.languageCode]?['tetrisLinkCopied'] ??
      'Link copied';
  String get deleteAllContacts =>
      _localizedValues[locale.languageCode]?['deleteAllContacts'] ??
      'Delete all contacts';
  String get deleteAllContactsConfirm =>
      _localizedValues[locale.languageCode]?['deleteAllContactsConfirm'] ??
      'Are you sure you want to delete all contacts? This action cannot be undone.';
  String get pickYourselfTitle =>
      _localizedValues[locale.languageCode]?['pickYourselfTitle'] ??
      'Select yourself';
  String get pickYourselfMessage =>
      _localizedValues[locale.languageCode]?['pickYourselfMessage'] ??
      'Choose your contact so you can start with your colors. iOS cannot detect this automatically.\n\nYou can also tap and hold a contact on either pane to set yourself as "me".';
  String get pickYourselfButton =>
      _localizedValues[locale.languageCode]?['pickYourselfButton'] ??
      'Choose contact';
  String get notNow =>
      _localizedValues[locale.languageCode]?['notNow'] ?? 'Not now';
  String pickYourselfNotInList(String contactName) => (_localizedValues[
              locale.languageCode]?['pickYourselfNotInList'] ??
          '{contactName} was not found in your loaded contacts. Pick someone who is in the list.')
      .replaceAll('{contactName}', contactName);
  String get setMeWithLongPressHint =>
      _localizedValues[locale.languageCode]?['setMeWithLongPressHint'] ??
      'Tap and hold a contact on this pane to set yourself as "me".';
  String selfContactSelectedToast(String contactName) =>
      (_localizedValues[locale.languageCode]?['selfContactSelectedToast'] ??
              '{contactName} is now selected as "me".')
          .replaceAll('{contactName}', contactName);
  String get doubleTapSelfDescription =>
      _localizedValues[locale.languageCode]?['doubleTapSelfDescription'] ??
      'Double-tap a pane to scroll to yourself';
  String get longPressSelfDescription =>
      _localizedValues[locale.languageCode]?['longPressSelfDescription'] ??
      'Tap and hold a contact to select a new "me"';
  String get upgradeToPro =>
      _localizedValues[locale.languageCode]?['upgradeToPro'] ??
      'Upgrade to PRO';
  String get restorePurchases =>
      _localizedValues[locale.languageCode]?['restorePurchases'] ??
      'Restore purchases';
  String get proVersion =>
      _localizedValues[locale.languageCode]?['proVersion'] ??
      'PartnerCheck Pro';
  String get proFeatureLoadAllContacts =>
      _localizedValues[locale.languageCode]?['proFeatureLoadAllContacts'] ??
      'Load all contacts from your device is a PRO feature. Upgrade to import your entire address book at once.';
  String get purchaseInProgress =>
      _localizedValues[locale.languageCode]?['purchaseInProgress'] ??
      'Purchase in progress...';
  String get purchaseSuccess =>
      _localizedValues[locale.languageCode]?['purchaseSuccess'] ??
      'PRO unlocked! Thank you for your purchase.';
  String get purchaseFailed =>
      _localizedValues[locale.languageCode]?['purchaseFailed'] ??
      'Purchase failed. Please try again.';
  String get alreadyPro =>
      _localizedValues[locale.languageCode]?['alreadyPro'] ??
      'You already have PRO.';
  String tetrisForecastWeeks(int weeks) =>
      (_localizedValues[locale.languageCode]?['tetrisForecastWeeks'] ??
              'Forecast for {weeks} weeks')
          .replaceAll('{weeks}', '$weeks');
  String tetrisNewRecord(int weeks) =>
      (_localizedValues[locale.languageCode]?['tetrisNewRecord'] ??
              'New record: {weeks} weeks!')
          .replaceAll('{weeks}', '$weeks');
  String get tetrisNeedTwoContacts =>
      _localizedValues[locale.languageCode]?['tetrisNeedTwoContacts'] ??
      'Select two contacts to play Tetris';
  String get plasmaNeedTwoContacts =>
      _localizedValues[locale.languageCode]?['plasmaNeedTwoContacts'] ??
      'Select two contacts to open plasma';
  String plasmaTitle(String name1, String name2) =>
      (_localizedValues[locale.languageCode]?['plasmaTitle'] ??
              '{name1} · {name2}')
          .replaceAll('{name1}', name1)
          .replaceAll('{name2}', name2);

  String get lavaIconDescription =>
      _localizedValues[locale.languageCode]?['lavaIconDescription'] ??
      'Watch lava in your colors';
  String get lavaNeedTwoContacts =>
      _localizedValues[locale.languageCode]?['lavaNeedTwoContacts'] ??
      'Select two contacts to open lava';
  String lavaTitle(String name1, String name2) =>
      (_localizedValues[locale.languageCode]?['lavaTitle'] ??
              '{name1} · {name2}')
          .replaceAll('{name1}', name1)
          .replaceAll('{name2}', name2);
  String tetrisWeeks(int weeks) =>
      (_localizedValues[locale.languageCode]?['tetrisWeeks'] ??
              'Weeks: {weeks}')
          .replaceAll('{weeks}', '$weeks');
  String get tetrisPlayersTitle =>
      _localizedValues[locale.languageCode]?['tetrisPlayersTitle'] ??
      'Hall of fame';
  String get tetrisNoRecords =>
      _localizedValues[locale.languageCode]?['tetrisNoRecords'] ??
      'No records yet';
  String get tetrisPause =>
      _localizedValues[locale.languageCode]?['tetrisPause'] ?? 'Pause';
  String get tetrisResume =>
      _localizedValues[locale.languageCode]?['tetrisResume'] ?? 'Resume';
  String get tetrisStartNewGame =>
      _localizedValues[locale.languageCode]?['tetrisStartNewGame'] ??
      'Start new game';
  String tetrisNewRecordCelebration(int weeks) =>
      (_localizedValues[locale.languageCode]?['tetrisNewRecordCelebration'] ??
              'New high score! {weeks} weeks!')
          .replaceAll('{weeks}', '$weeks');

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Contacts permission is required',
      'contactLimitReached': 'Contact Limit Reached',
      'contactLimitMessage':
          'You have reached the maximum of 10 contacts in the free version.\n\nUpgrade to PartnerCheck Pro to add unlimited contacts.',
      'ok': 'OK',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'save': 'Save',
      'add': 'Add',
      'close': 'Close',
      'selectedContactNoName': 'Selected contact has no name',
      'contactAlreadyInList': '{contactName} is already in the list',
      'noPhoneNumber': 'No Phone Number',
      'noPhoneNumberMessage':
          '{contactName} does not have a phone number. Please select a contact with a phone number.',
      'errorPickingContact': 'Error picking contact: {error}',
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
      'leavePhoneEmptyKeepColor':
          'Leave phone number empty to keep current color',
      'phoneNumberMinDigits': 'Enter at least 6 digits',
      'addFromDevice': 'Add from device',
      'searchContacts': 'Search contacts',
      'noDeviceContactsFound': 'No contacts found on this device',
      'addManually': 'Add manually',
      'addContact': 'Add Contact',
      'vibrations': 'Vibrations',
      'loadContacts': 'Load Contacts',
      'loadAllContacts': 'Load all contacts',
      'permissionRequired': 'Permission Required',
      'permissionRequiredMessage':
          'This app needs access to your contacts to check partner compatibility. Please grant permission in settings.',
      'openSettings': 'Open Settings',
      'settings': 'Settings',
      'contactsPermissionDenied': 'Contacts permission denied',
      'permissionDenied': 'Permission denied: {status}',
      'errorLoadingContacts': 'Error loading contacts: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Loading...',
      'loadingContactsFromDevice': 'Reading contacts from device...',
      'loadingContactsProgress': '{current} of {total}',
      'aboutTitle': 'About',
      'aboutText':
          'Every person has a phone (or more)\n\nevery phone has the last 6 digits\n\nevery 6 digits has a color (in hexadecimal code)\n\nevery color has a person (?)\n\nThere is no coincidence!\n\nThis app brings an unique opportunity to take a different look at the world of phone numbers belonging to specific people. Go through all the possible combinations and find out that coincidence does not exist.\n\nDoes it match or not?',
      'heartIconDescription': 'Mark contact as favorite',
      'chartIconDescription': 'Reorder contacts by match count',
      'trashIconDescription': 'Delete contact',
      'tetrisIconDescription': 'Play Tetris with your colors',
      'plasmaIconDescription': 'Watch plasma in your colors',
      'tetrisLinkCopied': 'Link copied',
      'deleteAllContacts': 'Delete all contacts',
      'deleteAllContactsConfirm':
          'Are you sure you want to delete all contacts? This action cannot be undone.',
      'pickYourselfTitle': 'Select yourself',
      'pickYourselfMessage':
          'Choose your contact so you can start with your colors. iOS cannot detect this automatically.\n\nYou can also tap and hold a contact on either pane to set yourself as "me".',
      'pickYourselfButton': 'Choose contact',
      'notNow': 'Not now',
      'pickYourselfNotInList':
          '{contactName} was not found in your loaded contacts. Pick someone who is in the list.',
      'setMeWithLongPressHint':
          'Tap and hold a contact on this pane to set yourself as "me".',
      'selfContactSelectedToast': '{contactName} is now selected as "me".',
      'doubleTapSelfDescription': 'Double-tap a pane to scroll to yourself',
      'longPressSelfDescription': 'Tap and hold a contact to select a new "me"',
      'upgradeToPro': 'Upgrade to PRO',
      'restorePurchases': 'Restore purchases',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Load all contacts from your device is a PRO feature. Upgrade to import your entire address book at once.',
      'purchaseInProgress': 'Purchase in progress...',
      'purchaseSuccess': 'PRO unlocked! Thank you for your purchase.',
      'purchaseFailed': 'Purchase failed. Please try again.',
      'alreadyPro': 'You already have PRO.',
      'tetrisForecastWeeks': 'Forecast for {weeks} weeks',
      'tetrisNewRecord': 'New record: {weeks} weeks!',
      'tetrisNeedTwoContacts': 'Select two contacts to play Tetris',
      'plasmaNeedTwoContacts': 'Select two contacts to open plasma',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Watch a lava in your colors',
      'lavaNeedTwoContacts': 'Select two contacts to open lava',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': 'Weeks: {weeks}',
      'tetrisPlayersTitle': 'Hall of fame',
      'tetrisNoRecords': 'No records yet',
      'tetrisPause': 'Pause',
      'tetrisResume': 'Resume',
      'tetrisStartNewGame': 'Start new game',
      'tetrisNewRecordCelebration': 'New high score! {weeks} weeks!',
    },
    'ar': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'مطلوب إذن الوصول إلى جهات الاتصال',
      'contactLimitReached': 'تم بلوغ حد جهات الاتصال',
      'contactLimitMessage':
          'لقد وصلت إلى الحد الأقصى وهو 10 جهات اتصال في النسخة المجانية.\n\nقم بالترقية إلى PartnerCheck Pro لإضافة جهات اتصال بلا حدود.',
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'save': 'حفظ',
      'add': 'إضافة',
      'close': 'إغلاق',
      'selectedContactNoName': 'جهة الاتصال المحددة ليس لها اسم',
      'contactAlreadyInList': '{contactName} موجودة بالفعل في القائمة',
      'noPhoneNumber': 'لا يوجد رقم هاتف',
      'noPhoneNumberMessage':
          '{contactName} ليس لديه رقم هاتف. يرجى اختيار جهة اتصال برقم هاتف.',
      'errorPickingContact': 'خطأ في اختيار جهة الاتصال: {error}',
      'deleteContact': 'حذف جهة الاتصال',
      'deleteContactConfirm': 'هل أنت متأكد أنك تريد حذف {contactName}؟',
      'addContactManually': 'إضافة جهة اتصال يدوياً',
      'editContact': 'تعديل جهة الاتصال',
      'name': 'الاسم',
      'enterContactName': 'أدخل اسم جهة الاتصال',
      'phoneNumber': 'رقم الهاتف',
      'enterPhoneNumber': 'أدخل رقم الهاتف',
      'phoneNumberOptional': 'رقم الهاتف (اختياري)',
      'enterPhoneNumberToChangeColor': 'أدخل رقم الهاتف لتغيير اللون',
      'leavePhoneEmptyKeepColor':
          'اترك رقم الهاتف فارغاً للاحتفاظ باللون الحالي',
      'phoneNumberMinDigits': 'أدخل 6 أرقام على الأقل',
      'addFromDevice': 'إضافة من الجهاز',
      'searchContacts': 'البحث في جهات الاتصال',
      'noDeviceContactsFound': 'لم يتم العثور على جهات اتصال على هذا الجهاز',
      'addManually': 'إضافة يدوياً',
      'addContact': 'إضافة جهة اتصال',
      'vibrations': 'الاهتزاز',
      'loadContacts': 'تحميل جهات الاتصال',
      'loadAllContacts': 'تحميل جميع جهات الاتصال',
      'permissionRequired': 'مطلوب إذن',
      'permissionRequiredMessage':
          'يحتاج هذا التطبيق إلى الوصول إلى جهات الاتصال للتحقق من توافق الشريك. يرجى منح الإذن في الإعدادات.',
      'openSettings': 'فتح الإعدادات',
      'settings': 'الإعدادات',
      'contactsPermissionDenied': 'تم رفض إذن جهات الاتصال',
      'permissionDenied': 'تم رفض الإذن: {status}',
      'errorLoadingContacts': 'خطأ في تحميل جهات الاتصال: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'جاري التحميل...',
      'loadingContactsFromDevice': 'جاري قراءة جهات الاتصال من الجهاز...',
      'loadingContactsProgress': '{current} من {total}',
      'aboutTitle': 'حول',
      'aboutText':
          'لكل شخص هاتف (أو أكثر)\n\nلكل هاتف آخر 6 أرقام\n\nلكل 6 أرقام لون (في الترميز الست عشري)\n\nلكل لون شخص (?)\n\nلا وجود للمصادفة!\n\nيوفر هذا التطبيق فرصة فريدة للنظر إلى عالم أرقام الهاتف التابعة لأشخاص محددين بمنظور مختلف. استكشف جميع التركيبات الممكنة واكتشف أن المصادفة غير موجودة.\n\nهل يتطابق أم لا؟',
      'heartIconDescription': 'تعليم جهة الاتصال كمفضلة',
      'chartIconDescription': 'إعادة ترتيب جهات الاتصال حسب عدد التطابقات',
      'trashIconDescription': 'حذف جهة الاتصال',
      'tetrisIconDescription': "العب Tetris بألوانك",
      'plasmaIconDescription': 'شاهد بلازما بألوانك',
      'tetrisLinkCopied': "تم نسخ الرابط",
      'deleteAllContacts': 'حذف جميع جهات الاتصال',
      'deleteAllContactsConfirm':
          'هل أنت متأكد أنك تريد حذف جميع جهات الاتصال؟ لا يمكن التراجع عن هذا الإجراء.',
      'pickYourselfTitle': 'اختر نفسك',
      'pickYourselfMessage':
          'اختر جهة اتصالك لبدء ألوانك. لا يمكن لـ iOS اكتشاف ذلك تلقائياً.\n\nيمكنك أيضاً الضغط مطولاً على جهة اتصال في أي لوحة لتعيين نفسك كـ "أنا".',
      'pickYourselfButton': 'اختر جهة اتصال',
      'notNow': 'ليس الآن',
      'pickYourselfNotInList':
          'لم يتم العثور على {contactName} في جهات الاتصال المحملة. اختر شخصاً موجوداً في القائمة.',
      'setMeWithLongPressHint':
          'اضغط مطولاً على جهة اتصال في هذه اللوحة لتعيين نفسك كـ "أنا".',
      'selfContactSelectedToast': 'تم اختيار {contactName} الآن كـ "أنا".',
      'doubleTapSelfDescription': 'انقر مرتين على لوحة للتمرير إلى نفسك',
      'longPressSelfDescription':
          'اضغط مطولاً على جهة اتصال لاختيار "أنا" جديد',
      'upgradeToPro': 'ترقية إلى PRO',
      'restorePurchases': 'استعادة المشتريات',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'تحميل جميع جهات الاتصال من جهازك ميزة PRO. قم بالترقية لاستيراد دفتر عناوينك بالكامل دفعة واحدة.',
      'purchaseInProgress': 'جاري الشراء...',
      'purchaseSuccess': 'تم فتح PRO! شكراً لشرائك.',
      'purchaseFailed': 'فشل الشراء. يرجى المحاولة مرة أخرى.',
      'alreadyPro': 'لديك PRO بالفعل.',
      'tetrisForecastWeeks': "توقعات لـ {weeks} أسابيع",
      'tetrisNewRecord': "رقم قياسي جديد: {weeks} أسابيع!",
      'tetrisNeedTwoContacts': "اختر جهتي اتصال للعب Tetris",
      'plasmaNeedTwoContacts': 'اختر جهتي اتصال لفتح البلازما',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'شاهد تأثير الحمم بألوانك',
      'lavaNeedTwoContacts': 'اختر جهتي اتصال لفتح الحمم',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "أسابيع: {weeks}",
      'tetrisPlayersTitle': "قاعة المشاهير",
      'tetrisNoRecords': "لا توجد سجلات بعد",
      'tetrisPause': "إيقاف مؤقت",
      'tetrisResume': "متابعة",
      'tetrisStartNewGame': "بدء لعبة جديدة",
      'tetrisNewRecordCelebration': "رقم قياسي جديد! {weeks} أسابيع!",
    },
    'he': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'נדרשת הרשאה לגישה לאנשי קשר',
      'contactLimitReached': 'הגעת למגבלת אנשי קשר',
      'contactLimitMessage':
          'הגעת למקסימום של 10 אנשי קשר בגרסה החינמית.\n\nשדרג ל-PartnerCheck Pro כדי להוסיף אנשי קשר ללא הגבלה.',
      'ok': 'אישור',
      'cancel': 'ביטול',
      'delete': 'מחק',
      'save': 'שמור',
      'add': 'הוסף',
      'close': 'סגור',
      'selectedContactNoName': 'לאנשי הקשר שנבחר אין שם',
      'contactAlreadyInList': '{contactName} כבר נמצא ברשימה',
      'noPhoneNumber': 'אין מספר טלפון',
      'noPhoneNumberMessage':
          'ל-{contactName} אין מספר טלפון. בחר איש קשר עם מספר טלפון.',
      'errorPickingContact': 'שגיאה בבחירת איש קשר: {error}',
      'deleteContact': 'מחק איש קשר',
      'deleteContactConfirm': 'האם אתה בטוח שברצונך למחוק את {contactName}?',
      'addContactManually': 'הוסף איש קשר ידנית',
      'editContact': 'ערוך איש קשר',
      'name': 'שם',
      'enterContactName': 'הזן שם איש קשר',
      'phoneNumber': 'מספר טלפון',
      'enterPhoneNumber': 'הזן מספר טלפון',
      'phoneNumberOptional': 'מספר טלפון (אופציונלי)',
      'enterPhoneNumberToChangeColor': 'הזן מספר טלפון כדי לשנות צבע',
      'leavePhoneEmptyKeepColor':
          'השאר את מספר הטלפון ריק כדי לשמור על הצבע הנוכחי',
      'phoneNumberMinDigits': 'הזן לפחות 6 ספרות',
      'addFromDevice': 'הוסף מהמכשיר',
      'searchContacts': 'חיפוש אנשי קשר',
      'noDeviceContactsFound': 'לא נמצאו אנשי קשר במכשיר זה',
      'addManually': 'הוסף ידנית',
      'addContact': 'הוסף איש קשר',
      'vibrations': 'רטט',
      'loadContacts': 'טען אנשי קשר',
      'loadAllContacts': 'טען את כל אנשי הקשר',
      'permissionRequired': 'נדרשת הרשאה',
      'permissionRequiredMessage':
          'האפליקציה זקוקה לגישה לאנשי הקשר שלך כדי לבדוק התאמה בין בני זוג. אנא הענק הרשאה בהגדרות.',
      'openSettings': 'פתח הגדרות',
      'settings': 'הגדרות',
      'contactsPermissionDenied': 'הרשאת אנשי קשר נדחתה',
      'permissionDenied': 'ההרשאה נדחתה: {status}',
      'errorLoadingContacts': 'שגיאה בטעינת אנשי קשר: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'טוען...',
      'loadingContactsFromDevice': 'קורא אנשי קשר מהמכשיר...',
      'loadingContactsProgress': '{current} מתוך {total}',
      'aboutTitle': 'אודות',
      'aboutText':
          'לכל אדם יש טלפון (או יותר)\n\nלכל טלפון יש 6 הספרות האחרונות\n\nלכל 6 ספרות יש צבע (בקוד hexadecimal)\n\nלכל צבע יש אדם (?)\n\nאין מקריות!\n\nהאפליקציה הזו מציעה הזדמנות ייחודית להסתכל אחרת על עולם מספרי הטלפון של אנשים מסוימים. עבור על כל הצירופים האפשריים וגלה שמקריות לא קיימת.\n\nהאם זה מתאים או לא?',
      'heartIconDescription': 'סמן איש קשר כמועדף',
      'chartIconDescription': 'סדר מחדש אנשי קשר לפי מספר ההתאמות',
      'trashIconDescription': 'מחק איש קשר',
      'tetrisIconDescription': "שחקו טטריס עם הצבעים שלכם",
      'plasmaIconDescription': 'צפו בפלזמה בצבעים שלכם',
      'tetrisLinkCopied': "הקישור הועתק",
      'deleteAllContacts': 'מחק את כל אנשי הקשר',
      'deleteAllContactsConfirm':
          'האם אתה בטוח שברצונך למחוק את כל אנשי הקשר? לא ניתן לבטל פעולה זו.',
      'pickYourselfTitle': 'בחר את עצמך',
      'pickYourselfMessage':
          'בחר את איש הקשר שלך כדי להתחיל עם הצבעים שלך. iOS לא יכול לזהות זאת אוטומטית.\n\nניתן גם ללחוץ לחיצה ארוכה על איש קשר באחת הלוחות כדי לסמן את עצמך כ"אני".',
      'pickYourselfButton': 'בחר איש קשר',
      'notNow': 'לא עכשיו',
      'pickYourselfNotInList':
          '{contactName} לא נמצא באנשי הקשר שנטענו. בחר מישהו שנמצא ברשימה.',
      'setMeWithLongPressHint':
          'לחץ לחיצה ארוכה על איש קשר בלוח זה כדי לסמן את עצמך כ"אני".',
      'selfContactSelectedToast': '{contactName} נבחר/ת עכשיו כ"אני".',
      'doubleTapSelfDescription': 'הקשה כפולה על לוח כדי לגלול אליך',
      'longPressSelfDescription': 'לחיצה ארוכה על איש קשר כדי לבחור "אני" חדש',
      'upgradeToPro': 'שדרג ל-PRO',
      'restorePurchases': 'שחזר רכישות',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'טעינת כל אנשי הקשר מהמכשיר היא תכונת PRO. שדרג כדי לייבא את כל אנשי הקשר בבת אחת.',
      'purchaseInProgress': 'הרכישה מתבצעת...',
      'purchaseSuccess': 'PRO נפתח! תודה על הרכישה.',
      'purchaseFailed': 'הרכישה נכשלה. נסה שוב.',
      'alreadyPro': 'כבר יש לך PRO.',
      'tetrisForecastWeeks': "תחזית ל-{weeks} שבועות",
      'tetrisNewRecord': "שיא חדש: {weeks} שבועות!",
      'tetrisNeedTwoContacts': "בחר שני אנשי קשר כדי לשחק טטריס",
      'plasmaNeedTwoContacts': 'בחר שני אנשי קשר כדי לפתוח פלזמה',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'צפו בלבה בצבעים שלכם',
      'lavaNeedTwoContacts': 'בחר שני אנשי קשר כדי לפתוח לבה',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "שבועות: {weeks}",
      'tetrisPlayersTitle': "היכל התהילה",
      'tetrisNoRecords': "אין רשומות עדיין",
      'tetrisPause': "השהיה",
      'tetrisResume': "המשך",
      'tetrisStartNewGame': "משחק חדש",
      'tetrisNewRecordCelebration': "שיא חדש! {weeks} שבועות!",
    },
    'cs': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Je vyžadováno oprávnění ke kontaktům',
      'contactLimitReached': 'Dosažen limit kontaktů',
      'contactLimitMessage':
          'Dosáhli jste maximálního počtu 10 kontaktů ve verzi zdarma.\n\nUpgradujte na PartnerCheck Pro pro přidání neomezeného počtu kontaktů.',
      'ok': 'OK',
      'cancel': 'Zrušit',
      'delete': 'Smazat',
      'save': 'Uložit',
      'add': 'Přidat',
      'close': 'Zavřít',
      'selectedContactNoName': 'Vybraný kontakt nemá jméno',
      'contactAlreadyInList': '{contactName} je již v seznamu',
      'noPhoneNumber': 'Bez telefonního čísla',
      'noPhoneNumberMessage':
          '{contactName} nemá telefonní číslo. Prosím vyberte kontakt s telefonním číslem.',
      'errorPickingContact': 'Chyba při výběru kontaktu: {error}',
      'deleteContact': 'Smazat kontakt',
      'deleteContactConfirm': 'Opravdu chcete smazat {contactName}?',
      'addContactManually': 'Přidat kontakt ručně',
      'editContact': 'Upravit kontakt',
      'name': 'Jméno',
      'enterContactName': 'Zadejte jméno kontaktu',
      'phoneNumber': 'Telefonní číslo',
      'enterPhoneNumber': 'Zadejte telefonní číslo',
      'phoneNumberOptional': 'Telefonní číslo (volitelné)',
      'enterPhoneNumberToChangeColor':
          'Zadejte telefonní číslo pro změnu barvy',
      'leavePhoneEmptyKeepColor':
          'Ponechte telefonní číslo prázdné pro zachování současné barvy',
      'phoneNumberMinDigits': 'Zadejte alespoň 6 číslic',
      'addFromDevice': 'Přidat ze zařízení',
      'searchContacts': 'Hledat kontakty',
      'noDeviceContactsFound':
          'Na tomto zařízení nebyly nalezeny žádné kontakty',
      'addManually': 'Přidat ručně',
      'addContact': 'Přidat kontakt',
      'vibrations': 'Vibrace',
      'loadContacts': 'Načíst kontakty',
      'loadAllContacts': 'Načíst všechny kontakty',
      'permissionRequired': 'Vyžadováno oprávnění',
      'permissionRequiredMessage':
          'Tato aplikace potřebuje přístup ke kontaktům pro kontrolu kompatibility partnerů. Prosím udělte oprávnění v nastavení.',
      'openSettings': 'Otevřít nastavení',
      'settings': 'Nastavení',
      'contactsPermissionDenied': 'Oprávnění ke kontaktům zamítnuto',
      'permissionDenied': 'Oprávnění zamítnuto: {status}',
      'errorLoadingContacts': 'Chyba při načítání kontaktů: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Načítání...',
      'loadingContactsFromDevice': 'Načítání kontaktů ze zařízení...',
      'loadingContactsProgress': '{current} z {total}',
      'aboutTitle': 'O aplikaci',
      'aboutText':
          'Každý člověk má telefon (nebo více)\n\nkaždý telefon má posledních 6 číslic\n\nkaždých 6 číslic má barvu (v hexadecimálním kódu)\n\nkaždá barva má člověka (?)\n\nNáhoda neexistuje!\n\nTato aplikace přináší jedinečnou příležitost podívat se jinak na svět telefonních čísel patřících konkrétním lidem. Projděte všechny možné kombinace a zjistěte, že náhoda neexistuje.\n\nLadí tedy? Neladí?',
      'heartIconDescription': 'Označit kontakt jako oblíbený',
      'chartIconDescription': 'Seřadit kontakty podle počtu shod',
      'trashIconDescription': 'Smazat kontakt',
      'tetrisIconDescription': "Hrajte Tetris se svými barvami",
      'plasmaIconDescription': 'Sledujte plazmu ve svých barvách',
      'tetrisLinkCopied': "Odkaz zkopírován",
      'deleteAllContacts': 'Smazat všechny kontakty',
      'deleteAllContactsConfirm':
          'Opravdu chcete smazat všechny kontakty? Tuto akci nelze vrátit zpět.',
      'pickYourselfTitle': 'Vyberte sebe',
      'pickYourselfMessage':
          'Vyberte svůj kontakt, abyste mohli začít se svými barvami. iOS to nemůže zjistit automaticky.\n\nMůžete také podržet prst na kontaktu v libovolném panelu a nastavit se jako "já".',
      'pickYourselfButton': 'Vybrat kontakt',
      'notNow': 'Teď ne',
      'pickYourselfNotInList':
          '{contactName} nebyl nalezen ve vašich načtených kontaktech. Vyberte někoho, kdo je v seznamu.',
      'setMeWithLongPressHint':
          'Podržte prst na kontaktu v tomto panelu a nastavte se jako "já".',
      'selfContactSelectedToast': '{contactName} je nyní vybrán/a jako "já".',
      'doubleTapSelfDescription': 'Dvojitým klepnutím na panel přejdete k sobě',
      'longPressSelfDescription':
          'Podržením prstu na kontaktu vyberete nové "já"',
      'upgradeToPro': 'Upgradovat na PRO',
      'restorePurchases': 'Obnovit nákupy',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Načtení všech kontaktů ze zařízení je funkce PRO. Upgradujte pro import celého adresáře najednou.',
      'purchaseInProgress': 'Nákup probíhá...',
      'purchaseSuccess': 'PRO odemčeno! Děkujeme za nákup.',
      'purchaseFailed': 'Nákup se nezdařil. Zkuste to znovu.',
      'alreadyPro': 'Již máte PRO.',
      'tetrisForecastWeeks': "Prognóza na {weeks} týdnů",
      'tetrisNewRecord': "Nový rekord: {weeks} týdnů!",
      'tetrisNeedTwoContacts': "Vyberte dva kontakty pro hru Tetris",
      'plasmaNeedTwoContacts': 'Vyberte dva kontakty pro plazmu',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Sledujte láva efekt ve svých barvách',
      'lavaNeedTwoContacts': 'Vyberte dva kontakty pro lávu',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Týdny: {weeks}",
      'tetrisPlayersTitle': "Síň slávy",
      'tetrisNoRecords': "Zatím žádné záznamy",
      'tetrisPause': "Pauza",
      'tetrisResume': "Pokračovat",
      'tetrisStartNewGame': "Nová hra",
      'tetrisNewRecordCelebration': "Nový rekord! {weeks} týdnů!",
    },
    'sk': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Je potrebné povolenie ku kontaktom',
      'contactLimitReached': 'Dosiahnutý limit kontaktov',
      'contactLimitMessage':
          'Dosiahli ste maximálny počet 10 kontaktov vo bezplatnej verzii.\n\nInovujte na PartnerCheck Pro a pridávajte neobmedzené množstvo kontaktov.',
      'ok': 'OK',
      'cancel': 'Zrušiť',
      'delete': 'Vymazať',
      'save': 'Uložiť',
      'add': 'Pridať',
      'close': 'Zavrieť',
      'selectedContactNoName': 'Vybraný kontakt nemá meno',
      'contactAlreadyInList': '{contactName} je už v zozname',
      'noPhoneNumber': 'Bez telefónneho čísla',
      'noPhoneNumberMessage':
          '{contactName} nemá telefónne číslo. Vyberte kontakt s telefónnym číslom.',
      'errorPickingContact': 'Chyba pri výbere kontaktu: {error}',
      'deleteContact': 'Vymazať kontakt',
      'deleteContactConfirm': 'Naozaj chcete vymazať {contactName}?',
      'addContactManually': 'Pridať kontakt ručne',
      'editContact': 'Upraviť kontakt',
      'name': 'Meno',
      'enterContactName': 'Zadajte meno kontaktu',
      'phoneNumber': 'Telefónne číslo',
      'enterPhoneNumber': 'Zadajte telefónne číslo',
      'phoneNumberOptional': 'Telefónne číslo (voliteľné)',
      'enterPhoneNumberToChangeColor': 'Zadajte telefónne číslo na zmenu farby',
      'leavePhoneEmptyKeepColor':
          'Ponechajte telefónne číslo prázdne, aby sa zachovala aktuálna farba',
      'phoneNumberMinDigits': 'Zadajte aspoň 6 číslic',
      'addFromDevice': 'Pridať zo zariadenia',
      'searchContacts': 'Hľadať kontakty',
      'noDeviceContactsFound': 'Na tomto zariadení sa nenašli žiadne kontakty',
      'addManually': 'Pridať ručne',
      'addContact': 'Pridať kontakt',
      'vibrations': 'Vibrácie',
      'loadContacts': 'Načítať kontakty',
      'loadAllContacts': 'Načítať všetky kontakty',
      'permissionRequired': 'Vyžaduje sa povolenie',
      'permissionRequiredMessage':
          'Táto aplikácia potrebuje prístup ku kontaktom na kontrolu kompatibility partnerov. Udeľte povolenie v nastaveniach.',
      'openSettings': 'Otvoriť nastavenia',
      'settings': 'Nastavenia',
      'contactsPermissionDenied': 'Povolenie ku kontaktom zamietnuté',
      'permissionDenied': 'Povolenie zamietnuté: {status}',
      'errorLoadingContacts': 'Chyba pri načítaní kontaktov: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Načítava sa...',
      'loadingContactsFromDevice': 'Načítavanie kontaktov zo zariadenia...',
      'loadingContactsProgress': '{current} z {total}',
      'aboutTitle': 'O aplikácii',
      'aboutText':
          'Každý človek má telefón (alebo viac)\n\nkaždý telefón má posledných 6 číslic\n\nkaždých 6 číslic má farbu (v hexadecimálnom kóde)\n\nkaždá farba má človeka (?)\n\nNáhoda neexistuje!\n\nTáto aplikácia prináša jedinečnú príležitosť pozrieť sa inak na svet telefónnych čísel patriacich konkrétnym ľuďom. Prejdite všetky možné kombinácie a zistite, že náhoda neexistuje.\n\nSedí to teda? Nesedí?',
      'heartIconDescription': 'Označiť kontakt ako obľúbený',
      'chartIconDescription': 'Zoradiť kontakty podľa počtu zhôd',
      'trashIconDescription': 'Vymazať kontakt',
      'tetrisIconDescription': "Hrajte Tetris so svojimi farbami",
      'plasmaIconDescription': 'Sledujte plazmu vo svojich farbách',
      'tetrisLinkCopied': "Odkaz skopírovaný",
      'deleteAllContacts': 'Vymazať všetky kontakty',
      'deleteAllContactsConfirm':
          'Naozaj chcete vymazať všetky kontakty? Túto akciu nie je možné vrátiť späť.',
      'pickYourselfTitle': 'Vyberte seba',
      'pickYourselfMessage':
          'Vyberte svoj kontakt, aby ste mohli začať so svojimi farbami. iOS to nemôže zistiť automaticky.\n\nMôžete tiež podržať prst na kontakte v ľubovoľnom paneli a nastaviť sa ako "ja".',
      'pickYourselfButton': 'Vybrať kontakt',
      'notNow': 'Teraz nie',
      'pickYourselfNotInList':
          '{contactName} sa nenašiel vo vašich načítaných kontaktoch. Vyberte niekoho, kto je v zozname.',
      'setMeWithLongPressHint':
          'Podržte prst na kontakte v tomto paneli a nastavte sa ako "ja".',
      'selfContactSelectedToast': '{contactName} je teraz vybraný/á ako "ja".',
      'doubleTapSelfDescription': 'Dvojitým klepnutím na panel prejdete k sebe',
      'longPressSelfDescription':
          'Podržaním prsta na kontakte vyberiete nové "ja"',
      'upgradeToPro': 'Upgradovať na PRO',
      'restorePurchases': 'Obnoviť nákupy',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Načítanie všetkých kontaktov zo zariadenia je funkcia PRO. Upgradujte pre import celého adresára naraz.',
      'purchaseInProgress': 'Nákup prebieha...',
      'purchaseSuccess': 'PRO odomknuté! Ďakujeme za nákup.',
      'purchaseFailed': 'Nákup zlyhal. Skúste to znova.',
      'alreadyPro': 'Už máte PRO.',
      'tetrisForecastWeeks': "Prognóza na {weeks} týždňov",
      'tetrisNewRecord': "Nový rekord: {weeks} týždňov!",
      'tetrisNeedTwoContacts': "Vyberte dva kontakty na hranie Tetrisu",
      'plasmaNeedTwoContacts': 'Vyberte dva kontakty pre plazmu',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Sledujte láva efekt vo svojich farbách',
      'lavaNeedTwoContacts': 'Vyberte dva kontakty pre lávu',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Týždne: {weeks}",
      'tetrisPlayersTitle': "Sieň slávy",
      'tetrisNoRecords': "Zatiaľ žiadne záznamy",
      'tetrisPause': "Pauza",
      'tetrisResume': "Pokračovať",
      'tetrisStartNewGame': "Nová hra",
      'tetrisNewRecordCelebration': "Nový rekord! {weeks} týždňov!",
    },
    'zh': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': '需要联系人权限',
      'contactLimitReached': '达到联系人限制',
      'contactLimitMessage':
          '您已达到免费版本的最大10个联系人限制。\n\n升级到PartnerCheck Pro以添加无限联系人。',
      'ok': '确定',
      'cancel': '取消',
      'delete': '删除',
      'save': '保存',
      'add': '添加',
      'close': '关闭',
      'selectedContactNoName': '所选联系人没有名称',
      'contactAlreadyInList': '{contactName}已在列表中',
      'noPhoneNumber': '无电话号码',
      'noPhoneNumberMessage': '{contactName}没有电话号码。请选择有电话号码的联系人。',
      'errorPickingContact': '选择联系人时出错：{error}',
      'deleteContact': '删除联系人',
      'deleteContactConfirm': '您确定要删除{contactName}吗？',
      'addContactManually': '手动添加联系人',
      'editContact': '编辑联系人',
      'name': '姓名',
      'enterContactName': '输入联系人姓名',
      'phoneNumber': '电话号码',
      'enterPhoneNumber': '输入电话号码',
      'phoneNumberOptional': '电话号码（可选）',
      'enterPhoneNumberToChangeColor': '输入电话号码以更改颜色',
      'leavePhoneEmptyKeepColor': '将电话号码留空以保持当前颜色',
      'phoneNumberMinDigits': '至少输入6位数字',
      'addFromDevice': '从设备添加',
      'searchContacts': '搜索联系人',
      'noDeviceContactsFound': '此设备上未找到联系人',
      'addManually': '手动添加',
      'addContact': '添加联系人',
      'vibrations': '振动',
      'loadContacts': '加载联系人',
      'loadAllContacts': '加载所有联系人',
      'permissionRequired': '需要权限',
      'permissionRequiredMessage': '此应用需要访问您的联系人以检查伴侣兼容性。请在设置中授予权限。',
      'openSettings': '打开设置',
      'settings': '设置',
      'contactsPermissionDenied': '联系人权限被拒绝',
      'permissionDenied': '权限被拒绝：{status}',
      'errorLoadingContacts': '加载联系人时出错：{error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': '加载中...',
      'loadingContactsFromDevice': '正在从设备读取联系人...',
      'loadingContactsProgress': '{current} / {total}',
      'aboutTitle': '关于',
      'aboutText':
          '每个人都有电话（或更多）\n\n每部电话都有最后6位数字\n\n每6位数字都有一个颜色（十六进制代码）\n\n每种颜色都有一个人（？）\n\n没有巧合！\n\n此应用提供了一个独特的机会，以不同的视角看待属于特定人员的电话号码世界。浏览所有可能的组合，发现巧合并不存在。\n\n匹配还是不匹配？',
      'heartIconDescription': '将联系人标记为收藏',
      'chartIconDescription': '按匹配数重新排序联系人',
      'trashIconDescription': '删除联系人',
      'tetrisIconDescription': "用你的颜色玩俄罗斯方块",
      'plasmaIconDescription': '用你的颜色观看等离子效果',
      'tetrisLinkCopied': "链接已复制",
      'deleteAllContacts': '删除所有联系人',
      'deleteAllContactsConfirm': '您确定要删除所有联系人吗？此操作无法撤销。',
      'pickYourselfTitle': '选择你自己',
      'pickYourselfMessage':
          '选择您的联系人，以便从您的颜色开始。iOS 无法自动检测。\n\n您也可以在任一窗格中长按联系人来将自己设为"我"。',
      'pickYourselfButton': '选择联系人',
      'notNow': '以后再说',
      'pickYourselfNotInList': '在已加载的联系人中未找到 {contactName}。请选择列表中的联系人。',
      'setMeWithLongPressHint': '在此窗格中长按联系人，将自己设为"我"。',
      'selfContactSelectedToast': '{contactName} 现已选为"我"。',
      'doubleTapSelfDescription': '双击窗格可滚动到您自己',
      'longPressSelfDescription': '长按联系人可选择新的"我"',
      'upgradeToPro': '升级到 PRO',
      'restorePurchases': '恢复购买',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts': '从设备加载所有联系人是 PRO 功能。升级后可一次性导入整个通讯录。',
      'purchaseInProgress': '购买进行中...',
      'purchaseSuccess': 'PRO 已解锁！感谢您的购买。',
      'purchaseFailed': '购买失败。请重试。',
      'alreadyPro': '您已拥有 PRO。',
      'tetrisForecastWeeks': "预测 {weeks} 周",
      'tetrisNewRecord': "新纪录：{weeks} 周！",
      'tetrisNeedTwoContacts': "选择两个联系人玩俄罗斯方块",
      'plasmaNeedTwoContacts': '选择两个联系人打开等离子效果',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': '用你的颜色观看熔岩效果',
      'lavaNeedTwoContacts': '选择两个联系人打开熔岩效果',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "周数：{weeks}",
      'tetrisPlayersTitle': "名人堂",
      'tetrisNoRecords': "暂无记录",
      'tetrisPause': "暂停",
      'tetrisResume': "继续",
      'tetrisStartNewGame': "开始新游戏",
      'tetrisNewRecordCelebration': "新纪录！{weeks} 周！",
    },
    'ja': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': '連絡先の権限が必要です',
      'contactLimitReached': '連絡先の制限に達しました',
      'contactLimitMessage':
          '無料版では最大10件の連絡先に達しました。\n\nPartnerCheck Proにアップグレードして、無制限の連絡先を追加してください。',
      'ok': 'OK',
      'cancel': 'キャンセル',
      'delete': '削除',
      'save': '保存',
      'add': '追加',
      'close': '閉じる',
      'selectedContactNoName': '選択した連絡先に名前がありません',
      'contactAlreadyInList': '{contactName}は既にリストにあります',
      'noPhoneNumber': '電話番号なし',
      'noPhoneNumberMessage': '{contactName}には電話番号がありません。電話番号のある連絡先を選択してください。',
      'errorPickingContact': '連絡先の選択中にエラーが発生しました：{error}',
      'deleteContact': '連絡先を削除',
      'deleteContactConfirm': '{contactName}を削除してもよろしいですか？',
      'addContactManually': '連絡先を手動で追加',
      'editContact': '連絡先を編集',
      'name': '名前',
      'enterContactName': '連絡先の名前を入力',
      'phoneNumber': '電話番号',
      'enterPhoneNumber': '電話番号を入力',
      'phoneNumberOptional': '電話番号（オプション）',
      'enterPhoneNumberToChangeColor': '色を変更するには電話番号を入力',
      'leavePhoneEmptyKeepColor': '現在の色を保持するには電話番号を空のままにします',
      'phoneNumberMinDigits': '6桁以上入力してください',
      'addFromDevice': 'デバイスから追加',
      'searchContacts': '連絡先を検索',
      'noDeviceContactsFound': 'このデバイスに連絡先が見つかりません',
      'addManually': '手動で追加',
      'addContact': '連絡先を追加',
      'vibrations': '振動',
      'loadContacts': '連絡先を読み込む',
      'loadAllContacts': 'すべての連絡先を読み込む',
      'permissionRequired': '権限が必要です',
      'permissionRequiredMessage':
          'このアプリはパートナーの互換性をチェックするために連絡先へのアクセスが必要です。設定で権限を付与してください。',
      'openSettings': '設定を開く',
      'settings': '設定',
      'contactsPermissionDenied': '連絡先の権限が拒否されました',
      'permissionDenied': '権限が拒否されました：{status}',
      'errorLoadingContacts': '連絡先の読み込み中にエラーが発生しました：{error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': '読み込み中...',
      'loadingContactsFromDevice': 'デバイスから連絡先を読み込んでいます...',
      'loadingContactsProgress': '{current} / {total}',
      'aboutTitle': 'について',
      'aboutText':
          'すべての人が電話（またはそれ以上）を持っています\n\nすべての電話には最後の6桁があります\n\nすべての6桁には色（16進コード）があります\n\nすべての色には人がいます（？）\n\n偶然はありません！\n\nこのアプリは、特定の人に属する電話番号の世界を異なる視点で見る独特の機会を提供します。すべての可能な組み合わせを調べて、偶然が存在しないことを発見してください。\n\n一致しますか、それとも一致しませんか？',
      'heartIconDescription': '連絡先をお気に入りとしてマーク',
      'chartIconDescription': '一致数で連絡先を並べ替え',
      'trashIconDescription': '連絡先を削除',
      'tetrisIconDescription': "あなたの色でテトリスをプレイ",
      'plasmaIconDescription': 'あなたの色のプラズマを見る',
      'tetrisLinkCopied': "リンクをコピーしました",
      'deleteAllContacts': 'すべての連絡先を削除',
      'deleteAllContactsConfirm': 'すべての連絡先を削除してもよろしいですか？この操作は元に戻せません。',
      'pickYourselfTitle': '自分を選択',
      'pickYourselfMessage':
          '自分の色で始めるには、自分の連絡先を選んでください。iOS では自動検出できません。\n\nどちらかのペインで連絡先を長押しして「自分」を設定することもできます。',
      'pickYourselfButton': '連絡先を選ぶ',
      'notNow': '後で',
      'pickYourselfNotInList':
          '{contactName} は読み込んだ連絡先に見つかりませんでした。リストにある人を選んでください。',
      'setMeWithLongPressHint': 'このペインで連絡先を長押しして「自分」を設定します。',
      'selfContactSelectedToast': '{contactName} が「自分」として選択されました。',
      'doubleTapSelfDescription': 'ペインをダブルタップすると自分までスクロール',
      'longPressSelfDescription': '連絡先を長押しして新しい「自分」を選択',
      'upgradeToPro': 'PRO にアップグレード',
      'restorePurchases': '購入を復元',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'デバイスからすべての連絡先を読み込むのは PRO 機能です。アップグレードしてアドレス帳全体を一度にインポートできます。',
      'purchaseInProgress': '購入処理中...',
      'purchaseSuccess': 'PRO が解除されました！ご購入ありがとうございます。',
      'purchaseFailed': '購入に失敗しました。もう一度お試しください。',
      'alreadyPro': 'すでに PRO をお持ちです。',
      'tetrisForecastWeeks': "{weeks}週間の予測",
      'tetrisNewRecord': "新記録: {weeks}週間!",
      'tetrisNeedTwoContacts': "テトリスをプレイするには2つの連絡先を選択してください",
      'plasmaNeedTwoContacts': 'プラズマを開くには2つの連絡先を選択してください',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'あなたの色の溶岩を見る',
      'lavaNeedTwoContacts': '溶岩を開くには2つの連絡先を選択してください',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "週: {weeks}",
      'tetrisPlayersTitle': "殿堂",
      'tetrisNoRecords': "まだ記録がありません",
      'tetrisPause': "一時停止",
      'tetrisResume': "再開",
      'tetrisStartNewGame': "新しいゲーム",
      'tetrisNewRecordCelebration': "新記録! {weeks}週間!",
    },
    'nl': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Contactenmachtiging vereist',
      'contactLimitReached': 'Contactlimiet bereikt',
      'contactLimitMessage':
          'U heeft het maximum van 10 contacten in de gratis versie bereikt.\n\nUpgrade naar PartnerCheck Pro om onbeperkt contacten toe te voegen.',
      'ok': 'OK',
      'cancel': 'Annuleren',
      'delete': 'Verwijderen',
      'save': 'Opslaan',
      'add': 'Toevoegen',
      'close': 'Sluiten',
      'selectedContactNoName': 'Geselecteerd contact heeft geen naam',
      'contactAlreadyInList': '{contactName} staat al in de lijst',
      'noPhoneNumber': 'Geen telefoonnummer',
      'noPhoneNumberMessage':
          '{contactName} heeft geen telefoonnummer. Selecteer een contact met een telefoonnummer.',
      'errorPickingContact': 'Fout bij selecteren contact: {error}',
      'deleteContact': 'Contact verwijderen',
      'deleteContactConfirm':
          'Weet u zeker dat u {contactName} wilt verwijderen?',
      'addContactManually': 'Contact handmatig toevoegen',
      'editContact': 'Contact bewerken',
      'name': 'Naam',
      'enterContactName': 'Voer contactnaam in',
      'phoneNumber': 'Telefoonnummer',
      'enterPhoneNumber': 'Voer telefoonnummer in',
      'phoneNumberOptional': 'Telefoonnummer (optioneel)',
      'enterPhoneNumberToChangeColor':
          'Voer telefoonnummer in om kleur te wijzigen',
      'leavePhoneEmptyKeepColor':
          'Laat telefoonnummer leeg om huidige kleur te behouden',
      'phoneNumberMinDigits': 'Voer minimaal 6 cijfers in',
      'addFromDevice': 'Toevoegen vanaf apparaat',
      'searchContacts': 'Contacten zoeken',
      'noDeviceContactsFound': 'Geen contacten gevonden op dit apparaat',
      'addManually': 'Handmatig toevoegen',
      'addContact': 'Contact toevoegen',
      'vibrations': 'Trillingen',
      'loadContacts': 'Contacten laden',
      'loadAllContacts': 'Alle contacten laden',
      'permissionRequired': 'Machtiging vereist',
      'permissionRequiredMessage':
          'Deze app heeft toegang tot uw contacten nodig om partnercompatibiliteit te controleren. Verleen machtiging in instellingen.',
      'openSettings': 'Instellingen openen',
      'settings': 'Instellingen',
      'contactsPermissionDenied': 'Contactenmachtiging geweigerd',
      'permissionDenied': 'Machtiging geweigerd: {status}',
      'errorLoadingContacts': 'Fout bij laden contacten: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Laden...',
      'loadingContactsFromDevice': 'Contacten van apparaat lezen...',
      'loadingContactsProgress': '{current} van {total}',
      'aboutTitle': 'Over',
      'aboutText':
          'Elke persoon heeft een telefoon (of meer)\n\nelke telefoon heeft de laatste 6 cijfers\n\nelke 6 cijfers hebben een kleur (in hexadecimale code)\n\nelke kleur heeft een persoon (?)\n\nEr is geen toeval!\n\nDeze app biedt een unieke kans om anders te kijken naar de wereld van telefoonnummers die bij specifieke mensen horen. Ga door alle mogelijke combinaties en ontdek dat toeval niet bestaat.\n\nMatcht het of niet?',
      'heartIconDescription': 'Contact als favoriet markeren',
      'chartIconDescription': 'Contacten sorteren op aantal matches',
      'trashIconDescription': 'Contact verwijderen',
      'tetrisIconDescription': "Speel Tetris met je kleuren",
      'plasmaIconDescription': 'Bekijk plasma in jouw kleuren',
      'tetrisLinkCopied': "Link gekopieerd",
      'deleteAllContacts': 'Alle contacten verwijderen',
      'deleteAllContactsConfirm':
          'Weet u zeker dat u alle contacten wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.',
      'pickYourselfTitle': 'Selecteer jezelf',
      'pickYourselfMessage':
          'Kies je contact zodat je kunt beginnen met je kleuren. iOS kan dit niet automatisch detecteren.\n\nJe kunt ook een contact in een van beide panelen ingedrukt houden om jezelf als "ik" in te stellen.',
      'pickYourselfButton': 'Contact kiezen',
      'notNow': 'Niet nu',
      'pickYourselfNotInList':
          '{contactName} is niet gevonden in je geladen contacten. Kies iemand die in de lijst staat.',
      'setMeWithLongPressHint':
          'Houd een contact in dit paneel ingedrukt om jezelf als "ik" in te stellen.',
      'selfContactSelectedToast': '{contactName} is nu geselecteerd als "ik".',
      'doubleTapSelfDescription':
          'Dubbeltik op een paneel om naar jezelf te scrollen',
      'longPressSelfDescription':
          'Houd een contact ingedrukt om een nieuwe "ik" te kiezen',
      'upgradeToPro': 'Upgraden naar PRO',
      'restorePurchases': 'Aankopen herstellen',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Alle contacten van je apparaat laden is een PRO-functie. Upgrade om je hele adresboek in één keer te importeren.',
      'purchaseInProgress': 'Aankoop bezig...',
      'purchaseSuccess': 'PRO ontgrendeld! Bedankt voor je aankoop.',
      'purchaseFailed': 'Aankoop mislukt. Probeer het opnieuw.',
      'alreadyPro': 'Je hebt al PRO.',
      'tetrisForecastWeeks': "Voorspelling voor {weeks} weken",
      'tetrisNewRecord': "Nieuw record: {weeks} weken!",
      'tetrisNeedTwoContacts': "Selecteer twee contacten om Tetris te spelen",
      'plasmaNeedTwoContacts': 'Selecteer twee contacten om plasma te openen',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Bekijk lava in jouw kleuren',
      'lavaNeedTwoContacts': 'Selecteer twee contacten om lava te openen',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Weken: {weeks}",
      'tetrisPlayersTitle': "Eregalerij",
      'tetrisNoRecords': "Nog geen records",
      'tetrisPause': "Pauze",
      'tetrisResume': "Hervatten",
      'tetrisStartNewGame': "Nieuw spel starten",
      'tetrisNewRecordCelebration': "Nieuw record! {weeks} weken!",
    },
    'de': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Kontaktberechtigung erforderlich',
      'contactLimitReached': 'Kontaktlimit erreicht',
      'contactLimitMessage':
          'Sie haben das Maximum von 10 Kontakten in der kostenlosen Version erreicht.\n\nUpgraden Sie auf PartnerCheck Pro, um unbegrenzt Kontakte hinzuzufügen.',
      'ok': 'OK',
      'cancel': 'Abbrechen',
      'delete': 'Löschen',
      'save': 'Speichern',
      'add': 'Hinzufügen',
      'close': 'Schließen',
      'selectedContactNoName': 'Ausgewählter Kontakt hat keinen Namen',
      'contactAlreadyInList': '{contactName} ist bereits in der Liste',
      'noPhoneNumber': 'Keine Telefonnummer',
      'noPhoneNumberMessage':
          '{contactName} hat keine Telefonnummer. Bitte wählen Sie einen Kontakt mit einer Telefonnummer.',
      'errorPickingContact': 'Fehler beim Auswählen des Kontakts: {error}',
      'deleteContact': 'Kontakt löschen',
      'deleteContactConfirm': 'Möchten Sie {contactName} wirklich löschen?',
      'addContactManually': 'Kontakt manuell hinzufügen',
      'editContact': 'Kontakt bearbeiten',
      'name': 'Name',
      'enterContactName': 'Kontaktname eingeben',
      'phoneNumber': 'Telefonnummer',
      'enterPhoneNumber': 'Telefonnummer eingeben',
      'phoneNumberOptional': 'Telefonnummer (optional)',
      'enterPhoneNumberToChangeColor':
          'Telefonnummer eingeben, um Farbe zu ändern',
      'leavePhoneEmptyKeepColor':
          'Telefonnummer leer lassen, um aktuelle Farbe beizubehalten',
      'phoneNumberMinDigits': 'Mindestens 6 Ziffern eingeben',
      'addFromDevice': 'Vom Gerät hinzufügen',
      'searchContacts': 'Kontakte suchen',
      'noDeviceContactsFound': 'Keine Kontakte auf diesem Gerät gefunden',
      'addManually': 'Manuell hinzufügen',
      'addContact': 'Kontakt hinzufügen',
      'vibrations': 'Vibrationen',
      'loadContacts': 'Kontakte laden',
      'loadAllContacts': 'Alle Kontakte laden',
      'permissionRequired': 'Berechtigung erforderlich',
      'permissionRequiredMessage':
          'Diese App benötigt Zugriff auf Ihre Kontakte, um die Partnerkompatibilität zu überprüfen. Bitte gewähren Sie die Berechtigung in den Einstellungen.',
      'openSettings': 'Einstellungen öffnen',
      'settings': 'Einstellungen',
      'contactsPermissionDenied': 'Kontaktberechtigung verweigert',
      'permissionDenied': 'Berechtigung verweigert: {status}',
      'errorLoadingContacts': 'Fehler beim Laden der Kontakte: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Laden...',
      'loadingContactsFromDevice': 'Kontakte vom Gerät lesen...',
      'loadingContactsProgress': '{current} von {total}',
      'aboutTitle': 'Über',
      'aboutText':
          'Jede Person hat ein Telefon (oder mehr)\n\njedes Telefon hat die letzten 6 Ziffern\n\njede 6 Ziffern haben eine Farbe (im Hexadezimalcode)\n\njede Farbe hat eine Person (?)\n\nEs gibt keinen Zufall!\n\nDiese App bietet eine einzigartige Gelegenheit, die Welt der Telefonnummern, die zu bestimmten Personen gehören, anders zu betrachten. Gehen Sie durch alle möglichen Kombinationen und finden Sie heraus, dass Zufall nicht existiert.\n\nPasst es oder nicht?',
      'heartIconDescription': 'Kontakt als Favorit markieren',
      'chartIconDescription':
          'Kontakte nach Anzahl der Übereinstimmungen sortieren',
      'trashIconDescription': 'Kontakt löschen',
      'tetrisIconDescription': "Spiele Tetris mit deinen Farben",
      'plasmaIconDescription': 'Plasma in deinen Farben ansehen',
      'tetrisLinkCopied': "Link kopiert",
      'deleteAllContacts': 'Alle Kontakte löschen',
      'deleteAllContactsConfirm':
          'Sind Sie sicher, dass Sie alle Kontakte löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.',
      'pickYourselfTitle': 'Wähle dich selbst',
      'pickYourselfMessage':
          'Wähle deinen Kontakt, um mit deinen Farben zu starten. iOS kann dies nicht automatisch erkennen.\n\nDu kannst auch einen Kontakt in einem der Fenster gedrückt halten, um dich als "ich" festzulegen.',
      'pickYourselfButton': 'Kontakt wählen',
      'notNow': 'Nicht jetzt',
      'pickYourselfNotInList':
          '{contactName} wurde in deinen geladenen Kontakten nicht gefunden. Wähle jemanden, der in der Liste ist.',
      'setMeWithLongPressHint':
          'Halte einen Kontakt in diesem Fenster gedrückt, um dich als "ich" festzulegen.',
      'selfContactSelectedToast':
          '{contactName} ist jetzt als "ich" ausgewählt.',
      'doubleTapSelfDescription':
          'Doppeltippen auf ein Fenster, um zu dir zu scrollen',
      'longPressSelfDescription':
          'Kontakt gedrückt halten, um ein neues "ich" zu wählen',
      'upgradeToPro': 'Auf PRO upgraden',
      'restorePurchases': 'Käufe wiederherstellen',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Alle Kontakte vom Gerät laden ist eine PRO-Funktion. Upgrade, um dein gesamtes Adressbuch auf einmal zu importieren.',
      'purchaseInProgress': 'Kauf wird durchgeführt...',
      'purchaseSuccess': 'PRO freigeschaltet! Danke für deinen Kauf.',
      'purchaseFailed': 'Kauf fehlgeschlagen. Bitte versuche es erneut.',
      'alreadyPro': 'Du hast bereits PRO.',
      'tetrisForecastWeeks': "Prognose für {weeks} Wochen",
      'tetrisNewRecord': "Neuer Rekord: {weeks} Wochen!",
      'tetrisNeedTwoContacts': "Wähle zwei Kontakte, um Tetris zu spielen",
      'plasmaNeedTwoContacts': 'Wähle zwei Kontakte, um Plasma zu öffnen',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Lava in deinen Farben ansehen',
      'lavaNeedTwoContacts': 'Wähle zwei Kontakte, um Lava zu öffnen',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Wochen: {weeks}",
      'tetrisPlayersTitle': "Ruhmeshalle",
      'tetrisNoRecords': "Noch keine Rekorde",
      'tetrisPause': "Pause",
      'tetrisResume': "Fortsetzen",
      'tetrisStartNewGame': "Neues Spiel starten",
      'tetrisNewRecordCelebration': "Neuer Rekord! {weeks} Wochen!",
    },
    'es': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Se requiere permiso de contactos',
      'contactLimitReached': 'Límite de contactos alcanzado',
      'contactLimitMessage':
          'Ha alcanzado el máximo de 10 contactos en la versión gratuita.\n\nActualice a PartnerCheck Pro para agregar contactos ilimitados.',
      'ok': 'OK',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'save': 'Guardar',
      'add': 'Agregar',
      'close': 'Cerrar',
      'selectedContactNoName': 'El contacto seleccionado no tiene nombre',
      'contactAlreadyInList': '{contactName} ya está en la lista',
      'noPhoneNumber': 'Sin número de teléfono',
      'noPhoneNumberMessage':
          '{contactName} no tiene número de teléfono. Por favor, seleccione un contacto con número de teléfono.',
      'errorPickingContact': 'Error al seleccionar contacto: {error}',
      'deleteContact': 'Eliminar contacto',
      'deleteContactConfirm':
          '¿Está seguro de que desea eliminar {contactName}?',
      'addContactManually': 'Agregar contacto manualmente',
      'editContact': 'Editar contacto',
      'name': 'Nombre',
      'enterContactName': 'Ingrese el nombre del contacto',
      'phoneNumber': 'Número de teléfono',
      'enterPhoneNumber': 'Ingrese el número de teléfono',
      'phoneNumberOptional': 'Número de teléfono (opcional)',
      'enterPhoneNumberToChangeColor':
          'Ingrese el número de teléfono para cambiar el color',
      'leavePhoneEmptyKeepColor':
          'Deje el número de teléfono vacío para mantener el color actual',
      'phoneNumberMinDigits': 'Ingrese al menos 6 dígitos',
      'addFromDevice': 'Agregar desde dispositivo',
      'searchContacts': 'Buscar contactos',
      'noDeviceContactsFound':
          'No se encontraron contactos en este dispositivo',
      'addManually': 'Agregar manualmente',
      'addContact': 'Agregar contacto',
      'vibrations': 'Vibraciones',
      'loadContacts': 'Cargar contactos',
      'loadAllContacts': 'Cargar todos los contactos',
      'permissionRequired': 'Permiso requerido',
      'permissionRequiredMessage':
          'Esta aplicación necesita acceso a sus contactos para verificar la compatibilidad de parejas. Por favor, otorgue el permiso en la configuración.',
      'openSettings': 'Abrir configuración',
      'settings': 'Configuración',
      'contactsPermissionDenied': 'Permiso de contactos denegado',
      'permissionDenied': 'Permiso denegado: {status}',
      'errorLoadingContacts': 'Error al cargar contactos: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Cargando...',
      'loadingContactsFromDevice': 'Leyendo contactos del dispositivo...',
      'loadingContactsProgress': '{current} de {total}',
      'aboutTitle': 'Acerca de',
      'aboutText':
          'Cada persona tiene un teléfono (o más)\n\ncada teléfono tiene los últimos 6 dígitos\n\ncada 6 dígitos tiene un color (en código hexadecimal)\n\ncada color tiene una persona (?)\n\n¡No hay coincidencia!\n\nEsta aplicación ofrece una oportunidad única de ver de manera diferente el mundo de los números de teléfono que pertenecen a personas específicas. Revise todas las combinaciones posibles y descubra que la coincidencia no existe.\n\n¿Coincide o no?',
      'heartIconDescription': 'Marcar contacto como favorito',
      'chartIconDescription': 'Reordenar contactos por número de coincidencias',
      'trashIconDescription': 'Eliminar contacto',
      'tetrisIconDescription': "Juega Tetris con tus colores",
      'plasmaIconDescription': 'Mira plasma con tus colores',
      'tetrisLinkCopied': "Enlace copiado",
      'deleteAllContacts': 'Eliminar todos los contactos',
      'deleteAllContactsConfirm':
          '¿Está seguro de que desea eliminar todos los contactos? Esta acción no se puede deshacer.',
      'pickYourselfTitle': 'Selecciónate',
      'pickYourselfMessage':
          'Elige tu contacto para empezar con tus colores. iOS no puede detectarlo automáticamente.\n\nTambién puedes mantener pulsado un contacto en cualquier panel para establecerte como "yo".',
      'pickYourselfButton': 'Elegir contacto',
      'notNow': 'Ahora no',
      'pickYourselfNotInList':
          '{contactName} no se encontró en tus contactos cargados. Elige a alguien que esté en la lista.',
      'setMeWithLongPressHint':
          'Mantén pulsado un contacto en este panel para establecerte como "yo".',
      'selfContactSelectedToast':
          '{contactName} ahora está seleccionado/a como "yo".',
      'doubleTapSelfDescription':
          'Toca dos veces un panel para desplazarte hasta ti',
      'longPressSelfDescription':
          'Mantén pulsado un contacto para elegir un nuevo "yo"',
      'upgradeToPro': 'Actualizar a PRO',
      'restorePurchases': 'Restaurar compras',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Cargar todos los contactos del dispositivo es una función PRO. Actualiza para importar toda tu agenda de una vez.',
      'purchaseInProgress': 'Compra en curso...',
      'purchaseSuccess': '¡PRO desbloqueado! Gracias por tu compra.',
      'purchaseFailed': 'La compra falló. Inténtalo de nuevo.',
      'alreadyPro': 'Ya tienes PRO.',
      'tetrisForecastWeeks': "Pronóstico para {weeks} semanas",
      'tetrisNewRecord': "¡Nuevo récord: {weeks} semanas!",
      'tetrisNeedTwoContacts': "Selecciona dos contactos para jugar Tetris",
      'plasmaNeedTwoContacts': 'Selecciona dos contactos para abrir plasma',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Mira un efecto lava con tus colores',
      'lavaNeedTwoContacts': 'Selecciona dos contactos para abrir lava',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Semanas: {weeks}",
      'tetrisPlayersTitle': "Salón de la fama",
      'tetrisNoRecords': "Aún no hay récords",
      'tetrisPause': "Pausa",
      'tetrisResume': "Reanudar",
      'tetrisStartNewGame': "Empezar nueva partida",
      'tetrisNewRecordCelebration': "¡Nuevo récord! ¡{weeks} semanas!",
    },
    'fr': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Autorisation de contacts requise',
      'contactLimitReached': 'Limite de contacts atteinte',
      'contactLimitMessage':
          'Vous avez atteint le maximum de 10 contacts dans la version gratuite.\n\nPassez à PartnerCheck Pro pour ajouter des contacts illimités.',
      'ok': 'OK',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'save': 'Enregistrer',
      'add': 'Ajouter',
      'close': 'Fermer',
      'selectedContactNoName': 'Le contact sélectionné n\'a pas de nom',
      'contactAlreadyInList': '{contactName} est déjà dans la liste',
      'noPhoneNumber': 'Aucun numéro de téléphone',
      'noPhoneNumberMessage':
          '{contactName} n\'a pas de numéro de téléphone. Veuillez sélectionner un contact avec un numéro de téléphone.',
      'errorPickingContact': 'Erreur lors de la sélection du contact : {error}',
      'deleteContact': 'Supprimer le contact',
      'deleteContactConfirm':
          'Êtes-vous sûr de vouloir supprimer {contactName} ?',
      'addContactManually': 'Ajouter un contact manuellement',
      'editContact': 'Modifier le contact',
      'name': 'Nom',
      'enterContactName': 'Entrez le nom du contact',
      'phoneNumber': 'Numéro de téléphone',
      'enterPhoneNumber': 'Entrez le numéro de téléphone',
      'phoneNumberOptional': 'Numéro de téléphone (optionnel)',
      'enterPhoneNumberToChangeColor':
          'Entrez le numéro de téléphone pour changer la couleur',
      'leavePhoneEmptyKeepColor':
          'Laissez le numéro de téléphone vide pour conserver la couleur actuelle',
      'phoneNumberMinDigits': 'Entrez au moins 6 chiffres',
      'addFromDevice': 'Ajouter depuis l\'appareil',
      'searchContacts': 'Rechercher des contacts',
      'noDeviceContactsFound': 'Aucun contact trouvé sur cet appareil',
      'addManually': 'Ajouter manuellement',
      'addContact': 'Ajouter un contact',
      'vibrations': 'Vibrations',
      'loadContacts': 'Charger les contacts',
      'loadAllContacts': 'Charger tous les contacts',
      'permissionRequired': 'Autorisation requise',
      'permissionRequiredMessage':
          'Cette application a besoin d\'accéder à vos contacts pour vérifier la compatibilité des partenaires. Veuillez accorder l\'autorisation dans les paramètres.',
      'openSettings': 'Ouvrir les paramètres',
      'settings': 'Paramètres',
      'contactsPermissionDenied': 'Autorisation de contacts refusée',
      'permissionDenied': 'Autorisation refusée : {status}',
      'errorLoadingContacts':
          'Erreur lors du chargement des contacts : {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Chargement...',
      'loadingContactsFromDevice': 'Lecture des contacts depuis l\'appareil...',
      'loadingContactsProgress': '{current} sur {total}',
      'aboutTitle': 'À propos',
      'aboutText':
          'Chaque personne a un téléphone (ou plus)\n\nchaque téléphone a les 6 derniers chiffres\n\nchaque 6 chiffres a une couleur (en code hexadécimal)\n\nchaque couleur a une personne (?)\n\nIl n\'y a pas de coïncidence !\n\nCette application offre une opportunité unique de regarder différemment le monde des numéros de téléphone appartenant à des personnes spécifiques. Parcourez toutes les combinaisons possibles et découvrez que la coïncidence n\'existe pas.\n\nEst-ce que ça correspond ou pas ?',
      'heartIconDescription': 'Marquer le contact comme favori',
      'chartIconDescription':
          'Réorganiser les contacts par nombre de correspondances',
      'trashIconDescription': 'Supprimer le contact',
      'tetrisIconDescription': "Jouez à Tetris avec vos couleurs",
      'plasmaIconDescription': 'Regardez le plasma avec vos couleurs',
      'tetrisLinkCopied': "Lien copié",
      'deleteAllContacts': 'Supprimer tous les contacts',
      'deleteAllContactsConfirm':
          'Êtes-vous sûr de vouloir supprimer tous les contacts ? Cette action ne peut pas être annulée.',
      'pickYourselfTitle': 'Sélectionnez-vous',
      'pickYourselfMessage':
          'Choisissez votre contact pour commencer avec vos couleurs. iOS ne peut pas le détecter automatiquement.\n\nVous pouvez aussi appuyer longuement sur un contact dans l\'un des panneaux pour vous définir comme « moi ».',
      'pickYourselfButton': 'Choisir un contact',
      'notNow': 'Pas maintenant',
      'pickYourselfNotInList':
          '{contactName} n\'a pas été trouvé dans vos contacts chargés. Choisissez quelqu\'un qui est dans la liste.',
      'setMeWithLongPressHint':
          'Appuyez longuement sur un contact dans ce panneau pour vous définir comme « moi ».',
      'selfContactSelectedToast':
          '{contactName} est maintenant sélectionné(e) comme « moi ».',
      'doubleTapSelfDescription':
          'Double appui sur un panneau pour défiler jusqu\'à vous',
      'longPressSelfDescription':
          'Appui long sur un contact pour choisir un nouveau « moi »',
      'upgradeToPro': 'Passer à PRO',
      'restorePurchases': 'Restaurer les achats',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Charger tous les contacts de l\'appareil est une fonctionnalité PRO. Passez à PRO pour importer tout votre carnet d\'adresses en une fois.',
      'purchaseInProgress': 'Achat en cours...',
      'purchaseSuccess': 'PRO débloqué ! Merci pour votre achat.',
      'purchaseFailed': 'L\'achat a échoué. Veuillez réessayer.',
      'alreadyPro': 'Vous avez déjà PRO.',
      'tetrisForecastWeeks': "Prévision pour {weeks} semaines",
      'tetrisNewRecord': "Nouveau record : {weeks} semaines !",
      'tetrisNeedTwoContacts': "Sélectionnez deux contacts pour jouer à Tetris",
      'plasmaNeedTwoContacts':
          'Sélectionnez deux contacts pour ouvrir le plasma',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Regardez la lave avec vos couleurs',
      'lavaNeedTwoContacts': 'Sélectionnez deux contacts pour ouvrir la lave',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Semaines : {weeks}",
      'tetrisPlayersTitle': "Temple de la renommée",
      'tetrisNoRecords': "Pas encore de records",
      'tetrisPause': "Pause",
      'tetrisResume': "Reprendre",
      'tetrisStartNewGame': "Nouvelle partie",
      'tetrisNewRecordCelebration': "Nouveau record ! {weeks} semaines !",
    },
    'hi': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'संपर्कों की अनुमति आवश्यक है',
      'contactLimitReached': 'संपर्क सीमा पूर्ण',
      'contactLimitMessage':
          'आप मुफ़्त संस्करण में अधिकतम 10 संपर्कों की सीमा पर पहुँच गए हैं।\n\nअसीमित संपर्क जोड़ने के लिए PartnerCheck Pro में अपग्रेड करें।',
      'ok': 'ठीक है',
      'cancel': 'रद्द करें',
      'delete': 'हटाएँ',
      'save': 'सहेजें',
      'add': 'जोड़ें',
      'close': 'बंद करें',
      'selectedContactNoName': 'चयनित संपर्क का कोई नाम नहीं है',
      'contactAlreadyInList': '{contactName} पहले से सूची में है',
      'noPhoneNumber': 'कोई फ़ोन नंबर नहीं',
      'noPhoneNumberMessage':
          '{contactName} का कोई फ़ोन नंबर नहीं है। कृपया फ़ोन नंबर वाला संपर्क चुनें।',
      'errorPickingContact': 'संपर्क चुनने में त्रुटि: {error}',
      'deleteContact': 'संपर्क हटाएँ',
      'deleteContactConfirm': 'क्या आप वाकई {contactName} को हटाना चाहते हैं?',
      'addContactManually': 'मैन्युअली संपर्क जोड़ें',
      'editContact': 'संपर्क संपादित करें',
      'name': 'नाम',
      'enterContactName': 'संपर्क का नाम दर्ज करें',
      'phoneNumber': 'फ़ोन नंबर',
      'enterPhoneNumber': 'फ़ोन नंबर दर्ज करें',
      'phoneNumberOptional': 'फ़ोन नंबर (वैकल्पिक)',
      'enterPhoneNumberToChangeColor': 'रंग बदलने के लिए फ़ोन नंबर दर्ज करें',
      'leavePhoneEmptyKeepColor':
          'वर्तमान रंग बनाए रखने के लिए फ़ोन नंबर खाली छोड़ें',
      'phoneNumberMinDigits': 'कम से कम 6 अंक दर्ज करें',
      'addFromDevice': 'डिवाइस से जोड़ें',
      'searchContacts': 'संपर्क खोजें',
      'noDeviceContactsFound': 'इस डिवाइस पर कोई संपर्क नहीं मिला',
      'addManually': 'मैन्युअली जोड़ें',
      'addContact': 'संपर्क जोड़ें',
      'vibrations': 'कंपन',
      'loadContacts': 'संपर्क लोड करें',
      'loadAllContacts': 'सभी संपर्क लोड करें',
      'permissionRequired': 'अनुमति आवश्यक',
      'permissionRequiredMessage':
          'साझीदार अनुकूलता की जाँच के लिए इस ऐप को आपके संपर्कों तक पहुँच चाहिए। कृपया सेटिंग में अनुमति दें।',
      'openSettings': 'सेटिंग खोलें',
      'settings': 'सेटिंग',
      'contactsPermissionDenied': 'संपर्कों की अनुमति अस्वीकार',
      'permissionDenied': 'अनुमति अस्वीकार: {status}',
      'errorLoadingContacts': 'संपर्क लोड करने में त्रुटि: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'लोड हो रहा है...',
      'loadingContactsFromDevice': 'डिवाइस से संपर्क पढ़े जा रहे हैं...',
      'loadingContactsProgress': '{current} में से {total}',
      'aboutTitle': 'के बारे में',
      'aboutText':
          'हर व्यक्ति के पास एक फ़ोन (या अधिक) होता है\n\nहर फ़ोन के अंतिम 6 अंक होते हैं\n\nहर 6 अंकों का एक रंग (हेक्साडेसimal कोड में) होता है\n\nहर रंग का एक व्यक्ति (?) होता है\n\nकोई संयोग नहीं है!\n\nयह ऐप विशिष्ट लोगों से जुड़े फ़ोन नंबरों की दुनिया को अलग नज़रिए से देखने का अनूठा अवसर देता है। सभी संभावित संयोजनों से गुज़रें और जानें कि संयोग मौजूद नहीं है।\n\nक्या यह मेल खाता है या नहीं?',
      'heartIconDescription': 'संपर्क को पसंदीदा के रूप में चिह्नित करें',
      'chartIconDescription':
          'मेल की संख्या के अनुसार संपर्कों को क्रमबद्ध करें',
      'trashIconDescription': 'संपर्क हटाएँ',
      'tetrisIconDescription': "अपने रंगों के साथ टेट्रिस खेलें",
      'plasmaIconDescription': 'अपने रंगों में प्लाज़्मा देखें',
      'tetrisLinkCopied': "लिंक कॉपी हो गया",
      'deleteAllContacts': 'सभी संपर्क हटाएँ',
      'deleteAllContactsConfirm':
          'क्या आप वाकई सभी संपर्क हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।',
      'pickYourselfTitle': 'अपना चयन करें',
      'pickYourselfMessage':
          'अपने रंगों के साथ शुरू करने के लिए अपना संपर्क चुनें। iOS इसे स्वचालित रूप से नहीं पहचान सकता।\n\nआप किसी भी पैन में संपर्क को दबाकर रखकर себ को "मैं" के रूप में भी सेट कर सकते हैं।',
      'pickYourselfButton': 'संपर्क चुनें',
      'notNow': 'अभी नहीं',
      'pickYourselfNotInList':
          '{contactName} आपके लोड किए गए संपर्कों में नहीं मिला। सूची में मौजूद किसी को चुनें।',
      'setMeWithLongPressHint':
          'इस पैन में संपर्क को दबाकर रखें और себ को "मैं" के रूप में सेट करें।',
      'selfContactSelectedToast':
          '{contactName} अब "मैं" के रूप में चुना गया है।',
      'doubleTapSelfDescription':
          'अपने तक स्क्रॉल करने के लिए पैन पर दो बार टैप करें',
      'longPressSelfDescription': 'नया "मैं" चुनने के लिए संपर्क को दबाकर रखें',
      'upgradeToPro': 'PRO में अपग्रेड करें',
      'restorePurchases': 'खरीदारी पुनर्स्थापित करें',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'डिवाइस से सभी संपर्क लोड करना PRO सुविधा है। अपनी पूरी एड्रेस बुक एक साथ आयात करने के लिए अपग्रेड करें।',
      'purchaseInProgress': 'खरीदारी प्रगति में...',
      'purchaseSuccess': 'PRO अनलॉक हो गया! आपकी खरीदारी के लिए धन्यवाद।',
      'purchaseFailed': 'खरीदारी विफल। कृपया पुनः प्रयास करें।',
      'alreadyPro': 'आपके पास पहले से PRO है।',
      'tetrisForecastWeeks': "{weeks} सप्ताह का पूर्वानुमान",
      'tetrisNewRecord': "नया रिकॉर्ड: {weeks} सप्ताह!",
      'tetrisNeedTwoContacts': "टेट्रिस खेलने के लिए दो संपर्क चुनें",
      'plasmaNeedTwoContacts': 'प्लाज़्मा खोलने के लिए दो संपर्क चुनें',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'अपने रंगों में लावा देखें',
      'lavaNeedTwoContacts': 'लावा खोलने के लिए दो संपर्क चुनें',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "सप्ताह: {weeks}",
      'tetrisPlayersTitle': "हॉल ऑफ फेम",
      'tetrisNoRecords': "अभी तक कोई रिकॉर्ड नहीं",
      'tetrisPause': "रोकें",
      'tetrisResume': "जारी रखें",
      'tetrisStartNewGame': "नया खेल शुरू करें",
      'tetrisNewRecordCelebration': "नया रिकॉर्ड! {weeks} सप्ताह!",
    },
    'it': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Autorizzazione contatti richiesta',
      'contactLimitReached': 'Limite contatti raggiunto',
      'contactLimitMessage':
          'Hai raggiunto il massimo di 10 contatti nella versione gratuita.\n\nPassa a PartnerCheck Pro per aggiungere contatti illimitati.',
      'ok': 'OK',
      'cancel': 'Annulla',
      'delete': 'Elimina',
      'save': 'Salva',
      'add': 'Aggiungi',
      'close': 'Chiudi',
      'selectedContactNoName': 'Il contatto selezionato non ha nome',
      'contactAlreadyInList': '{contactName} è già nella lista',
      'noPhoneNumber': 'Nessun numero di telefono',
      'noPhoneNumberMessage':
          '{contactName} non ha un numero di telefono. Seleziona un contatto con un numero di telefono.',
      'errorPickingContact': 'Errore nella selezione del contatto: {error}',
      'deleteContact': 'Elimina contatto',
      'deleteContactConfirm': 'Sei sicuro di voler eliminare {contactName}?',
      'addContactManually': 'Aggiungi contatto manualmente',
      'editContact': 'Modifica contatto',
      'name': 'Nome',
      'enterContactName': 'Inserisci il nome del contatto',
      'phoneNumber': 'Numero di telefono',
      'enterPhoneNumber': 'Inserisci il numero di telefono',
      'phoneNumberOptional': 'Numero di telefono (opzionale)',
      'enterPhoneNumberToChangeColor':
          'Inserisci il numero di telefono per cambiare il colore',
      'leavePhoneEmptyKeepColor':
          'Lascia il numero di telefono vuoto per mantenere il colore attuale',
      'phoneNumberMinDigits': 'Inserisci almeno 6 cifre',
      'addFromDevice': 'Aggiungi dal dispositivo',
      'searchContacts': 'Cerca contatti',
      'noDeviceContactsFound': 'Nessun contatto trovato su questo dispositivo',
      'addManually': 'Aggiungi manualmente',
      'addContact': 'Aggiungi contatto',
      'vibrations': 'Vibrazioni',
      'loadContacts': 'Carica contatti',
      'loadAllContacts': 'Carica tutti i contatti',
      'permissionRequired': 'Autorizzazione richiesta',
      'permissionRequiredMessage':
          'Questa app ha bisogno dell\'accesso ai tuoi contatti per verificare la compatibilità del partner. Concedi l\'autorizzazione nelle impostazioni.',
      'openSettings': 'Apri impostazioni',
      'settings': 'Impostazioni',
      'contactsPermissionDenied': 'Autorizzazione contatti negata',
      'permissionDenied': 'Autorizzazione negata: {status}',
      'errorLoadingContacts': 'Errore nel caricamento dei contatti: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Caricamento...',
      'loadingContactsFromDevice': 'Lettura contatti dal dispositivo...',
      'loadingContactsProgress': '{current} di {total}',
      'aboutTitle': 'Informazioni',
      'aboutText':
          'Ogni persona ha un telefono (o più)\n\nogni telefono ha le ultime 6 cifre\n\nogni 6 cifre ha un colore (in codice esadecimale)\n\nogni colore ha una persona (?)\n\nNon c\'è coincidenza!\n\nQuesta app offre un\'opportunità unica di guardare in modo diverso il mondo dei numeri di telefono appartenenti a persone specifiche. Esplora tutte le combinazioni possibili e scopri che la coincidenza non esiste.\n\nCorrisponde o no?',
      'heartIconDescription': 'Segna contatto come preferito',
      'chartIconDescription': 'Riordina contatti per numero di corrispondenze',
      'trashIconDescription': 'Elimina contatto',
      'tetrisIconDescription': "Gioca a Tetris con i tuoi colori",
      'plasmaIconDescription': 'Guarda il plasma con i tuoi colori',
      'tetrisLinkCopied': "Link copiato",
      'deleteAllContacts': 'Elimina tutti i contatti',
      'deleteAllContactsConfirm':
          'Sei sicuro di voler eliminare tutti i contatti? Questa azione non può essere annullata.',
      'pickYourselfTitle': 'Seleziona te stesso',
      'pickYourselfMessage':
          'Scegli il tuo contatto per iniziare con i tuoi colori. iOS non può rilevarlo automaticamente.\n\nPuoi anche tenere premuto un contatto in uno dei pannelli per impostarti come "io".',
      'pickYourselfButton': 'Scegli contatto',
      'notNow': 'Non ora',
      'pickYourselfNotInList':
          '{contactName} non è stato trovato nei contatti caricati. Scegli qualcuno presente nell\'elenco.',
      'setMeWithLongPressHint':
          'Tieni premuto un contatto in questo pannello per impostarti come "io".',
      'selfContactSelectedToast':
          '{contactName} è ora selezionato/a come "io".',
      'doubleTapSelfDescription':
          'Doppio tocco su un pannello per scorrere fino a te',
      'longPressSelfDescription':
          'Tieni premuto un contatto per selezionare un nuovo "io"',
      'upgradeToPro': 'Passa a PRO',
      'restorePurchases': 'Ripristina acquisti',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Caricare tutti i contatti dal dispositivo è una funzione PRO. Passa a PRO per importare l\'intera rubrica in una volta.',
      'purchaseInProgress': 'Acquisto in corso...',
      'purchaseSuccess': 'PRO sbloccato! Grazie per l\'acquisto.',
      'purchaseFailed': 'Acquisto non riuscito. Riprova.',
      'alreadyPro': 'Hai già PRO.',
      'tetrisForecastWeeks': "Previsione per {weeks} settimane",
      'tetrisNewRecord': "Nuovo record: {weeks} settimane!",
      'tetrisNeedTwoContacts': "Seleziona due contatti per giocare a Tetris",
      'plasmaNeedTwoContacts': 'Seleziona due contatti per aprire il plasma',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Guarda un effetto lava con i tuoi colori',
      'lavaNeedTwoContacts': 'Seleziona due contatti per aprire la lava',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Settimane: {weeks}",
      'tetrisPlayersTitle': "Sala della fama",
      'tetrisNoRecords': "Nessun record ancora",
      'tetrisPause': "Pausa",
      'tetrisResume': "Riprendi",
      'tetrisStartNewGame': "Nuova partita",
      'tetrisNewRecordCelebration': "Nuovo record! {weeks} settimane!",
    },
    'pl': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Wymagane uprawnienie do kontaktów',
      'contactLimitReached': 'Osiągnięto limit kontaktów',
      'contactLimitMessage':
          'Osiągnąłeś maksimum 10 kontaktów w wersji darmowej.\n\nZaktualizuj do PartnerCheck Pro, aby dodać nieograniczoną liczbę kontaktów.',
      'ok': 'OK',
      'cancel': 'Anuluj',
      'delete': 'Usuń',
      'save': 'Zapisz',
      'add': 'Dodaj',
      'close': 'Zamknij',
      'selectedContactNoName': 'Wybrany kontakt nie ma nazwy',
      'contactAlreadyInList': '{contactName} jest już na liście',
      'noPhoneNumber': 'Brak numeru telefonu',
      'noPhoneNumberMessage':
          '{contactName} nie ma numeru telefonu. Proszę wybrać kontakt z numerem telefonu.',
      'errorPickingContact': 'Błąd podczas wybierania kontaktu: {error}',
      'deleteContact': 'Usuń kontakt',
      'deleteContactConfirm': 'Czy na pewno chcesz usunąć {contactName}?',
      'addContactManually': 'Dodaj kontakt ręcznie',
      'editContact': 'Edytuj kontakt',
      'name': 'Nazwa',
      'enterContactName': 'Wprowadź nazwę kontaktu',
      'phoneNumber': 'Numer telefonu',
      'enterPhoneNumber': 'Wprowadź numer telefonu',
      'phoneNumberOptional': 'Numer telefonu (opcjonalny)',
      'enterPhoneNumberToChangeColor':
          'Wprowadź numer telefonu, aby zmienić kolor',
      'leavePhoneEmptyKeepColor':
          'Pozostaw numer telefonu pusty, aby zachować aktualny kolor',
      'phoneNumberMinDigits': 'Wprowadź co najmniej 6 cyfr',
      'addFromDevice': 'Dodaj z urządzenia',
      'searchContacts': 'Szukaj kontaktów',
      'noDeviceContactsFound': 'Nie znaleziono kontaktów na tym urządzeniu',
      'addManually': 'Dodaj ręcznie',
      'addContact': 'Dodaj kontakt',
      'vibrations': 'Wibracje',
      'loadContacts': 'Załaduj kontakty',
      'loadAllContacts': 'Załaduj wszystkie kontakty',
      'permissionRequired': 'Wymagane uprawnienie',
      'permissionRequiredMessage':
          'Ta aplikacja potrzebuje dostępu do Twoich kontaktów, aby sprawdzić zgodność partnerów. Proszę udzielić uprawnienia w ustawieniach.',
      'openSettings': 'Otwórz ustawienia',
      'settings': 'Ustawienia',
      'contactsPermissionDenied': 'Uprawnienie do kontaktów odrzucone',
      'permissionDenied': 'Uprawnienie odrzucone: {status}',
      'errorLoadingContacts': 'Błąd podczas ładowania kontaktów: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Ładowanie...',
      'loadingContactsFromDevice': 'Odczytywanie kontaktów z urządzenia...',
      'loadingContactsProgress': '{current} z {total}',
      'aboutTitle': 'O aplikacji',
      'aboutText':
          'Każda osoba ma telefon (lub więcej)\n\nkażdy telefon ma ostatnie 6 cyfr\n\nkażde 6 cyfr ma kolor (w kodzie szesnastkowym)\n\nkażdy kolor ma osobę (?)\n\nNie ma przypadku!\n\nTa aplikacja daje wyjątkową okazję, aby spojrzeć inaczej na świat numerów telefonów należących do konkretnych osób. Przejrzyj wszystkie możliwe kombinacje i odkryj, że przypadek nie istnieje.\n\nPasuje czy nie?',
      'heartIconDescription': 'Oznacz kontakt jako ulubiony',
      'chartIconDescription': 'Przeładuj kontakty według liczby dopasowań',
      'trashIconDescription': 'Usuń kontakt',
      'tetrisIconDescription': "Graj w Tetris swoimi kolorami",
      'plasmaIconDescription': 'Oglądaj plazmę w swoich kolorach',
      'tetrisLinkCopied': "Link skopiowany",
      'deleteAllContacts': 'Usuń wszystkie kontakty',
      'deleteAllContactsConfirm':
          'Czy na pewno chcesz usunąć wszystkie kontakty? Tej akcji nie można cofnąć.',
      'pickYourselfTitle': 'Wybierz siebie',
      'pickYourselfMessage':
          'Wybierz swój kontakt, aby zacząć od swoich kolorów. iOS nie może tego wykryć automatycznie.\n\nMożesz też przytrzymać kontakt na jednym z paneli, aby ustawić siebie jako "ja".',
      'pickYourselfButton': 'Wybierz kontakt',
      'notNow': 'Nie teraz',
      'pickYourselfNotInList':
          '{contactName} nie znaleziono w załadowanych kontaktach. Wybierz kogoś, kto jest na liście.',
      'setMeWithLongPressHint':
          'Przytrzymaj kontakt na tym panelu, aby ustawić siebie jako "ja".',
      'selfContactSelectedToast':
          '{contactName} jest teraz wybrany/a jako "ja".',
      'doubleTapSelfDescription':
          'Dotknij panelu dwukrotnie, aby przewinąć do siebie',
      'longPressSelfDescription': 'Przytrzymaj kontakt, aby wybrać nowe "ja"',
      'upgradeToPro': 'Przejdź na PRO',
      'restorePurchases': 'Przywróć zakupy',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Ładowanie wszystkich kontaktów z urządzenia to funkcja PRO. Ulepsz, aby zaimportować całą książkę adresową naraz.',
      'purchaseInProgress': 'Zakup w toku...',
      'purchaseSuccess': 'PRO odblokowane! Dziękujemy za zakup.',
      'purchaseFailed': 'Zakup nie powiódł się. Spróbuj ponownie.',
      'alreadyPro': 'Masz już PRO.',
      'tetrisForecastWeeks': "Prognoza na {weeks} tygodni",
      'tetrisNewRecord': "Nowy rekord: {weeks} tygodni!",
      'tetrisNeedTwoContacts': "Wybierz dwa kontakty, aby zagrać w Tetris",
      'plasmaNeedTwoContacts': 'Wybierz dwa kontakty, aby otworzyć plazmę',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Oglądaj efekt lawy w swoich kolorach',
      'lavaNeedTwoContacts': 'Wybierz dwa kontakty, aby otworzyć lawę',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Tygodnie: {weeks}",
      'tetrisPlayersTitle': "Galeria sław",
      'tetrisNoRecords': "Brak rekordów",
      'tetrisPause': "Pauza",
      'tetrisResume': "Wznów",
      'tetrisStartNewGame': "Nowa gra",
      'tetrisNewRecordCelebration': "Nowy rekord! {weeks} tygodni!",
    },
    'hu': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Kapcsolatok engedélye szükséges',
      'contactLimitReached': 'Kapcsolatok korlátja elérve',
      'contactLimitMessage':
          'Elérte a 10 kapcsolat maximumát az ingyenes verzióban.\n\nFrissítsen PartnerCheck Pro-ra, hogy korlátlan számú kapcsolatot adjon hozzá.',
      'ok': 'OK',
      'cancel': 'Mégse',
      'delete': 'Törlés',
      'save': 'Mentés',
      'add': 'Hozzáadás',
      'close': 'Bezárás',
      'selectedContactNoName': 'A kiválasztott kapcsolatnak nincs neve',
      'contactAlreadyInList': '{contactName} már a listán van',
      'noPhoneNumber': 'Nincs telefonszám',
      'noPhoneNumberMessage':
          '{contactName} nem rendelkezik telefonszámmal. Kérjük, válasszon egy kapcsolatot telefonszámmal.',
      'errorPickingContact': 'Hiba a kapcsolat kiválasztásakor: {error}',
      'deleteContact': 'Kapcsolat törlése',
      'deleteContactConfirm': 'Biztosan törölni szeretné {contactName}?',
      'addContactManually': 'Kapcsolat manuális hozzáadása',
      'editContact': 'Kapcsolat szerkesztése',
      'name': 'Név',
      'enterContactName': 'Adja meg a kapcsolat nevét',
      'phoneNumber': 'Telefonszám',
      'enterPhoneNumber': 'Adja meg a telefonszámot',
      'phoneNumberOptional': 'Telefonszám (opcionális)',
      'enterPhoneNumberToChangeColor':
          'Adja meg a telefonszámot a szín megváltoztatásához',
      'leavePhoneEmptyKeepColor':
          'Hagyja üresen a telefonszámot az aktuális szín megtartásához',
      'phoneNumberMinDigits': 'Adjon meg legalább 6 számjegyet',
      'addFromDevice': 'Hozzáadás eszközről',
      'searchContacts': 'Kapcsolatok keresése',
      'noDeviceContactsFound': 'Nem találhatók kapcsolatok ezen az eszközön',
      'addManually': 'Manuális hozzáadás',
      'addContact': 'Kapcsolat hozzáadása',
      'vibrations': 'Rezgések',
      'loadContacts': 'Kapcsolatok betöltése',
      'loadAllContacts': 'Összes kapcsolat betöltése',
      'permissionRequired': 'Engedély szükséges',
      'permissionRequiredMessage':
          'Ez az alkalmazás hozzáférést igényel a kapcsolataihoz a partner kompatibilitás ellenőrzéséhez. Kérjük, adja meg az engedélyt a beállításokban.',
      'openSettings': 'Beállítások megnyitása',
      'settings': 'Beállítások',
      'contactsPermissionDenied': 'Kapcsolatok engedélye megtagadva',
      'permissionDenied': 'Engedély megtagadva: {status}',
      'errorLoadingContacts': 'Hiba a kapcsolatok betöltésekor: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Betöltés...',
      'loadingContactsFromDevice': 'Kapcsolatok olvasása az eszközről...',
      'loadingContactsProgress': '{current} / {total}',
      'aboutTitle': 'Névjegy',
      'aboutText':
          'Minden embernek van telefonja (vagy több)\n\nminden telefonnak van az utolsó 6 számjegye\n\nminden 6 számjegynek van színe (hexadecimális kódban)\n\nminden színnek van embere (?)\n\nNincs véletlen!\n\nEz az alkalmazás egyedi lehetőséget nyújt, hogy másképp nézzük meg az adott emberekhez tartozó telefonszámok világát. Tekintse át az összes lehetséges kombinációt és fedezze fel, hogy a véletlen nem létezik.\n\nEgyezik vagy nem?',
      'heartIconDescription': 'Kapcsolat megjelölése kedvencként',
      'chartIconDescription':
          'Kapcsolatok újrarendezése egyezések száma szerint',
      'trashIconDescription': 'Kapcsolat törlése',
      'tetrisIconDescription': "Játssz Tetrist a színeiddel",
      'plasmaIconDescription': 'Nézz plazmát a színeiddel',
      'tetrisLinkCopied': "Link másolva",
      'deleteAllContacts': 'Összes kapcsolat törlése',
      'deleteAllContactsConfirm':
          'Biztosan törölni szeretné az összes kapcsolatot? Ez a művelet nem vonható vissza.',
      'pickYourselfTitle': 'Válaszd ki magad',
      'pickYourselfMessage':
          'Válaszd ki a kapcsolatodat, hogy a színeiddel kezdhess. Az iOS nem tudja ezt automatikusan felismerni.\n\nBármelyik panelen nyomva tarthatod egy kapcsolatot is, hogy "én"-ként beállítsd magad.',
      'pickYourselfButton': 'Kapcsolat kiválasztása',
      'notNow': 'Most nem',
      'pickYourselfNotInList':
          'A(z) {contactName} nem található a betöltött kapcsolatok között. Válassz valakit, aki szerepel a listában.',
      'setMeWithLongPressHint':
          'Tartsd nyomva a kapcsolatot ezen a panelen, hogy "én"-ként beállítsd magad.',
      'selfContactSelectedToast':
          '{contactName} most "én"-ként van kiválasztva.',
      'doubleTapSelfDescription':
          'Dupla koppintás egy panelen, hogy magadhoz görgess',
      'longPressSelfDescription':
          'Tartsd nyomva a kapcsolatot új "én" választásához',
      'upgradeToPro': 'Frissítés PRO-ra',
      'restorePurchases': 'Vásárlások visszaállítása',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Az összes kapcsolat betöltése az eszközről PRO funkció. Frissíts, hogy egyszerre importáld a teljes címjegyzékedet.',
      'purchaseInProgress': 'Vásárlás folyamatban...',
      'purchaseSuccess': 'PRO feloldva! Köszönjük a vásárlást.',
      'purchaseFailed': 'A vásárlás sikertelen. Próbáld újra.',
      'alreadyPro': 'Már van PRO-d.',
      'tetrisForecastWeeks': "Előrejelzés {weeks} hétre",
      'tetrisNewRecord': "Új rekord: {weeks} hét!",
      'tetrisNeedTwoContacts': "Válass két névjegyet a Tetris játékhoz",
      'plasmaNeedTwoContacts': 'Válass két névjegyet a plazma megnyitásához',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Nézz lava effektet a színeiddel',
      'lavaNeedTwoContacts': 'Válass két névjegyet a lava megnyitásához',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Hetek: {weeks}",
      'tetrisPlayersTitle': "Hírességek csarnoka",
      'tetrisNoRecords': "Még nincsenek rekordok",
      'tetrisPause': "Szünet",
      'tetrisResume': "Folytatás",
      'tetrisStartNewGame': "Új játék",
      'tetrisNewRecordCelebration': "Új rekord! {weeks} hét!",
    },
    'ru': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Требуется разрешение на контакты',
      'contactLimitReached': 'Достигнут лимит контактов',
      'contactLimitMessage':
          'Вы достигли максимума в 10 контактов в бесплатной версии.\n\nОбновитесь до PartnerCheck Pro, чтобы добавить неограниченное количество контактов.',
      'ok': 'ОК',
      'cancel': 'Отмена',
      'delete': 'Удалить',
      'save': 'Сохранить',
      'add': 'Добавить',
      'close': 'Закрыть',
      'selectedContactNoName': 'У выбранного контакта нет имени',
      'contactAlreadyInList': '{contactName} уже в списке',
      'noPhoneNumber': 'Нет номера телефона',
      'noPhoneNumberMessage':
          '{contactName} не имеет номера телефона. Пожалуйста, выберите контакт с номером телефона.',
      'errorPickingContact': 'Ошибка при выборе контакта: {error}',
      'deleteContact': 'Удалить контакт',
      'deleteContactConfirm': 'Вы уверены, что хотите удалить {contactName}?',
      'addContactManually': 'Добавить контакт вручную',
      'editContact': 'Редактировать контакт',
      'name': 'Имя',
      'enterContactName': 'Введите имя контакта',
      'phoneNumber': 'Номер телефона',
      'enterPhoneNumber': 'Введите номер телефона',
      'phoneNumberOptional': 'Номер телефона (необязательно)',
      'enterPhoneNumberToChangeColor':
          'Введите номер телефона, чтобы изменить цвет',
      'leavePhoneEmptyKeepColor':
          'Оставьте номер телефона пустым, чтобы сохранить текущий цвет',
      'phoneNumberMinDigits': 'Введите не менее 6 цифр',
      'addFromDevice': 'Добавить с устройства',
      'searchContacts': 'Поиск контактов',
      'noDeviceContactsFound': 'На этом устройстве контакты не найдены',
      'addManually': 'Добавить вручную',
      'addContact': 'Добавить контакт',
      'vibrations': 'Вибрация',
      'loadContacts': 'Загрузить контакты',
      'loadAllContacts': 'Загрузить все контакты',
      'permissionRequired': 'Требуется разрешение',
      'permissionRequiredMessage':
          'Это приложение нуждается в доступе к вашим контактам для проверки совместимости партнеров. Пожалуйста, предоставьте разрешение в настройках.',
      'openSettings': 'Открыть настройки',
      'settings': 'Настройки',
      'contactsPermissionDenied': 'Разрешение на контакты отклонено',
      'permissionDenied': 'Разрешение отклонено: {status}',
      'errorLoadingContacts': 'Ошибка при загрузке контактов: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Загрузка...',
      'loadingContactsFromDevice': 'Чтение контактов с устройства...',
      'loadingContactsProgress': '{current} из {total}',
      'aboutTitle': 'О приложении',
      'aboutText':
          'У каждого человека есть телефон (или больше)\n\nу каждого телефона есть последние 6 цифр\n\nу каждых 6 цифр есть цвет (в шестнадцатеричном коде)\n\nу каждого цвета есть человек (?)\n\nСовпадений не бывает!\n\nЭто приложение предоставляет уникальную возможность по-другому взглянуть на мир телефонных номеров, принадлежащих конкретным людям. Просмотрите все возможные комбинации и узнайте, что совпадений не существует.\n\nСовпадает или нет?',
      'heartIconDescription': 'Отметить контакт как избранный',
      'chartIconDescription':
          'Переупорядочить контакты по количеству совпадений',
      'trashIconDescription': 'Удалить контакт',
      'tetrisIconDescription': "Играйте в Tetris своими цветами",
      'plasmaIconDescription': 'Смотрите плазму в ваших цветах',
      'tetrisLinkCopied': "Ссылка скопирована",
      'deleteAllContacts': 'Удалить все контакты',
      'deleteAllContactsConfirm':
          'Вы уверены, что хотите удалить все контакты? Это действие нельзя отменить.',
      'pickYourselfTitle': 'Выберите себя',
      'pickYourselfMessage':
          'Выберите свой контакт, чтобы начать со своих цветов. iOS не может определить это автоматически.\n\nВы также можете нажать и удерживать контакт на любой панели, чтобы установить себя как «я».',
      'pickYourselfButton': 'Выбрать контакт',
      'notNow': 'Не сейчас',
      'pickYourselfNotInList':
          '{contactName} не найден в загруженных контактах. Выберите кого-то из списка.',
      'setMeWithLongPressHint':
          'Нажмите и удерживайте контакт на этой панели, чтобы установить себя как «я».',
      'selfContactSelectedToast': '{contactName} теперь выбран(а) как «я».',
      'doubleTapSelfDescription':
          'Двойное нажатие на панель, чтобы прокрутить к себе',
      'longPressSelfDescription':
          'Нажмите и удерживайте контакт, чтобы выбрать новое «я»',
      'upgradeToPro': 'Перейти на PRO',
      'restorePurchases': 'Восстановить покупки',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Загрузка всех контактов с устройства — функция PRO. Обновитесь, чтобы импортировать всю записную книгу сразу.',
      'purchaseInProgress': 'Покупка выполняется...',
      'purchaseSuccess': 'PRO разблокирован! Спасибо за покупку.',
      'purchaseFailed': 'Покупка не удалась. Попробуйте снова.',
      'alreadyPro': 'У вас уже есть PRO.',
      'tetrisForecastWeeks': "Прогноз на {weeks} недель",
      'tetrisNewRecord': "Новый рекорд: {weeks} недель!",
      'tetrisNeedTwoContacts': "Выберите два контакта для игры в Tetris",
      'plasmaNeedTwoContacts': 'Выберите два контакта для открытия плазмы',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Смотрите эффект лавы в ваших цветах',
      'lavaNeedTwoContacts': 'Выберите два контакта для открытия лавы',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Недели: {weeks}",
      'tetrisPlayersTitle': "Зал славы",
      'tetrisNoRecords': "Пока нет записей",
      'tetrisPause': "Пауза",
      'tetrisResume': "Продолжить",
      'tetrisStartNewGame': "Новая игра",
      'tetrisNewRecordCelebration': "Новый рекорд! {weeks} недель!",
    },
    'pt': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Permissão de contatos necessária',
      'contactLimitReached': 'Limite de contatos atingido',
      'contactLimitMessage':
          'Você atingiu o máximo de 10 contatos na versão gratuita.\n\nAtualize para PartnerCheck Pro para adicionar contatos ilimitados.',
      'ok': 'OK',
      'cancel': 'Cancelar',
      'delete': 'Excluir',
      'save': 'Salvar',
      'add': 'Adicionar',
      'close': 'Fechar',
      'selectedContactNoName': 'O contato selecionado não tem nome',
      'contactAlreadyInList': '{contactName} já está na lista',
      'noPhoneNumber': 'Sem número de telefone',
      'noPhoneNumberMessage':
          '{contactName} não tem número de telefone. Por favor, selecione um contato com número de telefone.',
      'errorPickingContact': 'Erro ao selecionar contato: {error}',
      'deleteContact': 'Excluir contato',
      'deleteContactConfirm':
          'Tem certeza de que deseja excluir {contactName}?',
      'addContactManually': 'Adicionar contato manualmente',
      'editContact': 'Editar contato',
      'name': 'Nome',
      'enterContactName': 'Digite o nome do contato',
      'phoneNumber': 'Número de telefone',
      'enterPhoneNumber': 'Digite o número de telefone',
      'phoneNumberOptional': 'Número de telefone (opcional)',
      'enterPhoneNumberToChangeColor':
          'Digite o número de telefone para alterar a cor',
      'leavePhoneEmptyKeepColor':
          'Deixe o número de telefone vazio para manter a cor atual',
      'phoneNumberMinDigits': 'Digite pelo menos 6 dígitos',
      'addFromDevice': 'Adicionar do dispositivo',
      'searchContacts': 'Pesquisar contatos',
      'noDeviceContactsFound': 'Nenhum contato encontrado neste dispositivo',
      'addManually': 'Adicionar manualmente',
      'addContact': 'Adicionar contato',
      'vibrations': 'Vibrações',
      'loadContacts': 'Carregar contatos',
      'loadAllContacts': 'Carregar todos os contatos',
      'permissionRequired': 'Permissão necessária',
      'permissionRequiredMessage':
          'Este aplicativo precisa de acesso aos seus contatos para verificar a compatibilidade do parceiro. Por favor, conceda a permissão nas configurações.',
      'openSettings': 'Abrir configurações',
      'settings': 'Configurações',
      'contactsPermissionDenied': 'Permissão de contatos negada',
      'permissionDenied': 'Permissão negada: {status}',
      'errorLoadingContacts': 'Erro ao carregar contatos: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Carregando...',
      'loadingContactsFromDevice': 'Lendo contatos do dispositivo...',
      'loadingContactsProgress': '{current} de {total}',
      'aboutTitle': 'Sobre',
      'aboutText':
          'Cada pessoa tem um telefone (ou mais)\n\ncada telefone tem os últimos 6 dígitos\n\ncada 6 dígitos tem uma cor (em código hexadecimal)\n\ncada cor tem uma pessoa (?)\n\nNão há coincidência!\n\nEste aplicativo oferece uma oportunidade única de olhar de forma diferente para o mundo dos números de telefone pertencentes a pessoas específicas. Percorra todas as combinações possíveis e descubra que a coincidência não existe.\n\nCombina ou não?',
      'heartIconDescription': 'Marcar contato como favorito',
      'chartIconDescription':
          'Reordenar contatos por número de correspondências',
      'trashIconDescription': 'Excluir contato',
      'tetrisIconDescription': "Jogue Tetris com as suas cores",
      'plasmaIconDescription': 'Veja plasma com as suas cores',
      'tetrisLinkCopied': "Link copiado",
      'deleteAllContacts': 'Excluir todos os contatos',
      'deleteAllContactsConfirm':
          'Tem certeza de que deseja excluir todos os contatos? Esta ação não pode ser desfeita.',
      'pickYourselfTitle': 'Selecione-se',
      'pickYourselfMessage':
          'Escolha seu contato para começar com suas cores. O iOS não pode detectar isso automaticamente.\n\nVocê também pode tocar e segurar um contato em qualquer painel para se definir como "eu".',
      'pickYourselfButton': 'Escolher contato',
      'notNow': 'Agora não',
      'pickYourselfNotInList':
          '{contactName} não foi encontrado nos seus contatos carregados. Escolha alguém que esteja na lista.',
      'setMeWithLongPressHint':
          'Toque e segure um contato neste painel para se definir como "eu".',
      'selfContactSelectedToast':
          '{contactName} agora está selecionado(a) como "eu".',
      'doubleTapSelfDescription':
          'Toque duas vezes em um painel para rolar até você',
      'longPressSelfDescription':
          'Toque e segure um contato para selecionar um novo "eu"',
      'upgradeToPro': 'Atualizar para PRO',
      'restorePurchases': 'Restaurar compras',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Carregar todos os contactos do dispositivo é uma funcionalidade PRO. Atualize para importar toda a sua agenda de uma vez.',
      'purchaseInProgress': 'Compra em curso...',
      'purchaseSuccess': 'PRO desbloqueado! Obrigado pela sua compra.',
      'purchaseFailed': 'A compra falhou. Tente novamente.',
      'alreadyPro': 'Já tem PRO.',
      'tetrisForecastWeeks': "Previsão para {weeks} semanas",
      'tetrisNewRecord': "Novo recorde: {weeks} semanas!",
      'tetrisNeedTwoContacts': "Selecione dois contactos para jogar Tetris",
      'plasmaNeedTwoContacts': 'Selecione dois contactos para abrir plasma',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Veja um efeito lava com as suas cores',
      'lavaNeedTwoContacts': 'Selecione dois contactos para abrir lava',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Semanas: {weeks}",
      'tetrisPlayersTitle': "Hall da fama",
      'tetrisNoRecords': "Ainda não há recordes",
      'tetrisPause': "Pausa",
      'tetrisResume': "Retomar",
      'tetrisStartNewGame': "Novo jogo",
      'tetrisNewRecordCelebration': "Novo recorde! {weeks} semanas!",
    },
    'ua': {
      'appTitle': 'Partner Check',
      'contactsPermissionRequired': 'Потрібен дозвіл на контакти',
      'contactLimitReached': 'Досягнуто ліміт контактів',
      'contactLimitMessage':
          'Ви досягли максимуму в 10 контактів у безкоштовній версії.\n\nОновіться до PartnerCheck Pro, щоб додавати необмежену кількість контактів.',
      'ok': 'OK',
      'cancel': 'Скасувати',
      'delete': 'Видалити',
      'save': 'Зберегти',
      'add': 'Додати',
      'close': 'Закрити',
      'selectedContactNoName': 'У вибраного контакта немає імені',
      'contactAlreadyInList': '{contactName} уже в списку',
      'noPhoneNumber': 'Немає номера телефону',
      'noPhoneNumberMessage':
          '{contactName} не має номера телефону. Будь ласка, оберіть контакт з номером телефону.',
      'errorPickingContact': 'Помилка при виборі контакта: {error}',
      'deleteContact': 'Видалити контакт',
      'deleteContactConfirm': 'Ви впевнені, що хочете видалити {contactName}?',
      'addContactManually': 'Додати контакт вручну',
      'editContact': 'Редагувати контакт',
      'name': 'Ім\'я',
      'enterContactName': 'Введіть ім\'я контакта',
      'phoneNumber': 'Номер телефону',
      'enterPhoneNumber': 'Введіть номер телефону',
      'phoneNumberOptional': 'Номер телефону (необов\'язково)',
      'enterPhoneNumberToChangeColor':
          'Введіть номер телефону, щоб змінити колір',
      'leavePhoneEmptyKeepColor':
          'Залиште номер телефону порожнім, щоб зберегти поточний колір',
      'phoneNumberMinDigits': 'Введіть щонайменше 6 цифр',
      'addFromDevice': 'Додати з пристрою',
      'searchContacts': 'Пошук контактів',
      'noDeviceContactsFound': 'На цьому пристрої контакти не знайдено',
      'addManually': 'Додати вручну',
      'addContact': 'Додати контакт',
      'vibrations': 'Вібрація',
      'loadContacts': 'Завантажити контакти',
      'loadAllContacts': 'Завантажити всі контакти',
      'permissionRequired': 'Потрібен дозвіл',
      'permissionRequiredMessage':
          'Цей застосунок потребує доступу до ваших контактів для перевірки сумісності партнерів. Будь ласка, надайте дозвіл у налаштуваннях.',
      'openSettings': 'Відкрити налаштування',
      'settings': 'Налаштування',
      'contactsPermissionDenied': 'Дозволу на контакти відхилено',
      'permissionDenied': 'Дозволу відхилено: {status}',
      'errorLoadingContacts': 'Помилка при завантаженні контактів: {error}',
      'partnerCheckFree': 'PartnerCheck Free',
      'loading': 'Завантаження...',
      'loadingContactsFromDevice': 'Читання контактів із пристрою...',
      'loadingContactsProgress': '{current} з {total}',
      'aboutTitle': 'Про застосунок',
      'aboutText':
          'Кожна людина має телефон (або більше)\n\nкожен телефон має останні 6 цифр\n\nкожні 6 цифр мають колір (у шістнадцятковому коді)\n\nкожен колір має людину (?)\n\nЗбігів не буває!\n\nЦей застосунок надає унікальну можливість по-іншому поглянути на світ телефонних номерів, що належать конкретним людям. Перегляньте всі можливі комбінації та переконайтеся, що збігів не існує.\n\nЗбігається чи ні?',
      'heartIconDescription': 'Позначити контакт як обраний',
      'chartIconDescription': 'Перевпорядкувати контакти за кількістю збігів',
      'trashIconDescription': 'Видалити контакт',
      'tetrisIconDescription': "Грайте в Tetris своїми кольорами",
      'plasmaIconDescription': 'Дивіться плазму у ваших кольорах',
      'tetrisLinkCopied': "Посилання скопійовано",
      'deleteAllContacts': 'Видалити всі контакти',
      'deleteAllContactsConfirm':
          'Ви впевнені, що хочете видалити всі контакти? Цю дію неможливо скасувати.',
      'pickYourselfTitle': 'Оберіть себе',
      'pickYourselfMessage':
          'Оберіть свій контакт, щоб почати зі своїх кольорів. iOS не може визначити це автоматично.\n\nВи також можете натиснути та утримувати контакт на будь-якій панелі, щоб установити себе як «я».',
      'pickYourselfButton': 'Обрати контакт',
      'notNow': 'Не зараз',
      'pickYourselfNotInList':
          '{contactName} не знайдено в завантажених контактах. Оберіть когось зі списку.',
      'setMeWithLongPressHint':
          'Натисніть і утримуйте контакт на цій панелі, щоб установити себе як «я».',
      'selfContactSelectedToast': '{contactName} тепер обрано(а) як «я».',
      'doubleTapSelfDescription':
          'Подвійне натискання на панель, щоб прокрутити до себе',
      'longPressSelfDescription':
          'Натисніть і утримуйте контакт, щоб обрати нове «я»',
      'upgradeToPro': 'Перейти на PRO',
      'restorePurchases': 'Відновити покупки',
      'proVersion': 'PartnerCheck Pro',
      'proFeatureLoadAllContacts':
          'Завантаження всіх контактів із пристрою — функція PRO. Оновіться, щоб імпортувати всю адресну книгу одразу.',
      'purchaseInProgress': 'Покупка виконується...',
      'purchaseSuccess': 'PRO розблоковано! Дякуємо за покупку.',
      'purchaseFailed': 'Покупку не вдалося здійснити. Спробуйте ще раз.',
      'alreadyPro': 'У вас уже є PRO.',
      'tetrisForecastWeeks': "Прогноз на {weeks} тижнів",
      'tetrisNewRecord': "Новий рекорд: {weeks} тижнів!",
      'tetrisNeedTwoContacts': "Оберіть два контакти для гри в Tetris",
      'plasmaNeedTwoContacts': 'Оберіть два контакти для відкриття плазми',
      'plasmaTitle': '{name1} · {name2}',
      'lavaIconDescription': 'Дивіться лаву у ваших кольорах',
      'lavaNeedTwoContacts': 'Оберіть два контакти для відкриття лави',
      'lavaTitle': '{name1} · {name2}',
      'tetrisWeeks': "Тижні: {weeks}",
      'tetrisPlayersTitle': "Зал слави",
      'tetrisNoRecords': "Записів поки немає",
      'tetrisPause': "Пауза",
      'tetrisResume': "Продовжити",
      'tetrisStartNewGame': "Нова гра",
      'tetrisNewRecordCelebration': "Новий рекорд! {weeks} тижнів!",
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final languageCode =
        AppLocalizations.normalizeLanguageCode(locale.languageCode);
    return [
      'en',
      'ar',
      'he',
      'cs',
      'sk',
      'zh',
      'ja',
      'nl',
      'de',
      'es',
      'fr',
      'hi',
      'it',
      'pl',
      'hu',
      'ru',
      'pt',
      'ua',
    ].contains(languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final languageCode =
        AppLocalizations.normalizeLanguageCode(locale.languageCode);
    return AppLocalizations(Locale(languageCode));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
