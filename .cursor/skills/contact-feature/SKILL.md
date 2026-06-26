---
name: contact-feature
description: Implements contact-related features in Partner Check — add/edit/delete contacts, device picker, self-contact pick, favorites, dual-pane scroll, match detection. Use when modifying contacts_page, contact_card, settings import, or self-contact flow.
---

# Contact Feature Development

## Architecture map

| Concern | File |
|---------|------|
| Main dual-pane UI | `lib/screens/contacts_page.dart` |
| Settings / bulk import | `lib/screens/settings_screen.dart` |
| Persistence | `lib/services/contact_storage_service.dart` |
| Model | `lib/models.dart` (`StoredContact`) |
| Device picker + permissions | `lib/services/contacts_permission.dart` |
| Pro limits | `lib/utils/pro_gate.dart` |
| Self-contact find/match | `lib/utils/self_contact_finder.dart` |
| Hold gesture | `lib/widgets/self_contact_hold_detector.dart` |
| Contact card UI | `lib/widgets/contact_card.dart` |

## Adding a contact

1. Gate with `ensureCanAddContact(context, _contacts.length)`
2. Request permission: `ensureContactsReadPermission()`
3. Pick: `pickContactWithNameAndPhone()` or manual dialog
4. Derive color: `PhoneUtils.colorFromPhoneNumber(phone)`
5. Persist: `_storageService.saveContacts(...)` via screen's save helper
6. Show feedback with l10n snackbars

## Self-contact flow

**Android:** After bulk import, `FlutterContacts.profile.get()` → save via `ContactStorageService.saveSelfContact` → scroll pane.

**iOS:** Set `pending_self_contact_pick`; on `ContactsPage` load show intro dialog → user picks from loaded list or device.

**Runtime:**
- Short hold (500ms) on list → `_goToSelfContact`
- Long hold (950ms) → `_pickSelfContact`
- Match stored self: `SelfContactFinder.findIndexForStoredSelf`

## Match / color logic

Do not duplicate in screens:

```
PhoneUtils.colorFromPhoneNumber → base color
ColorUtils.overlayColorFromValue → overlay strip
MatchCalculator → hue match (~30°), haptics trigger
```

## Editing contacts_page.dart

File is ~2600+ lines. Prefer:
- Extract new logic to `lib/utils/` or `lib/widgets/`
- Targeted method edits over large rewrites
- Callback props on widgets instead of inline build methods

## UI integration patterns

- Wrap list areas with `SelfContactHoldDetector` when hold-to-self is needed
- Pass `selfContactColor` to Settings/About for `SelfContactAnimatedBackground`
- Scroll to index: existing `_scrollPaneToSelfIndex` pattern with `ScrollController`

## Platform check template

```dart
import 'dart:io' show Platform;

if (Platform.isAndroid) {
  // profile auto-detect
} else if (Platform.isIOS) {
  // manual pick + pending flag
}
```
