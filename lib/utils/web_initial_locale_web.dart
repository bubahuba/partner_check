import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

const _langAliases = <String, String>{
  'cz': 'cs',
  'iw': 'he',
  'uk': 'ua',
};

Locale? getWebInitialLocale() {
  final raw = Uri.base.queryParameters['lang'];
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final code = _langAliases[raw.toLowerCase().split('-').first] ??
      raw.toLowerCase().split('-').first;

  for (final supported in AppLocalizations.supportedLocales) {
    if (supported.languageCode == code) {
      return supported;
    }
  }
  return null;
}
