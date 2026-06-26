---
name: add-localization
description: Adds user-visible strings to Partner Check's hand-maintained l10n system across all 17 locales. Use when adding UI text, dialog messages, snackbars, new l10n keys, or translating strings in lib/l10n/.
---

# Add Localization String

## Checklist

```
- [ ] Add key to lib/l10n/app_en.arb with @description
- [ ] Add key to all 16 other app_*.arb files
- [ ] Add getter/method in lib/l10n/app_localizations.dart
- [ ] Add entry to every language block in _localizedValues
- [ ] Use AppLocalizations.of(context)! in UI — no hardcoded strings
```

## ARB format

```json
"myNewKey": "Display text here",
"@myNewKey": {
  "description": "When/where this string appears"
}
```

Parameterized (use `{placeholder}` in value):

```json
"contactAlreadyInList": "{contactName} is already in the list"
```

## app_localizations.dart

**Simple getter:**
```dart
String get myNewKey =>
    _localizedValues[locale.languageCode]?['myNewKey'] ?? 'Display text here';
```

**Parameterized method:**
```dart
String myNewKey(String contactName) =>
    (_localizedValues[locale.languageCode]?['myNewKey'] ??
            '{contactName} is already in the list')
        .replaceAll('{contactName}', contactName);
```

**_localizedValues:** add `'myNewKey': '...'` inside each of the 17 language maps (`en`, `ar`, `he`, …).

## Locales

`en`, `ar`, `he`, `cs`, `sk`, `zh`, `ja`, `nl`, `de`, `es`, `fr`, `hi`, `it`, `pl`, `hu`, `ru`, `pt`

If translations are unavailable, use English in non-`en` ARB files and note it for the user.

## RTL note

Strings for `ar` and `he` should read naturally in RTL. Layout direction uses `AppLocalizations.isRtl` — do not bake LTR assumptions into string content.
