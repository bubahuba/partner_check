---
name: match-color-logic
description: Modifies Partner Check color derivation and compatibility matching logic. Use when changing hue matching, overlay colors, phone-to-color conversion, match flash, or vibration triggers.
---

# Match & Color Logic

## Pipeline

```
phone number
  → PhoneUtils.colorFromPhoneNumber()     # last 6 digits as hex
  → ColorUtils.overlayColorFromValue()    # reversed hex digits
  → MatchCalculator                       # hue comparison, cross-match
  → ContactCard flash + haptic feedback
```

## Files

| File | Responsibility |
|------|----------------|
| `lib/utils/phone_utils.dart` | Extract digits, derive `Color` from phone |
| `lib/utils/color_utils.dart` | Overlay color, hue distance, `areColorsMatching` |
| `lib/utils/match_calculator.dart` | Base/overlay/cross match orchestration |
| `lib/widgets/contact_card.dart` | Visual flash on match |

## Rules

- Keep hue threshold and match types centralized in utils — screens call helpers, don't reimplement
- `StoredContact` stores `name` + `color` (int value) — color is derived at add/edit time
- Changing color derivation affects existing stored contacts only when phone is edited

## Verification

After logic changes:

```bash
flutter analyze
```

Consider adding unit tests under `test/` for pure functions in `color_utils.dart` and `match_calculator.dart` (no tests exist yet).

## Related UI

- Overlay height ratio: `_overlayHeight` on `ContactsPage` (default 0.2), adjusted by vertical drag on cards
- Match reorder: locked pane + `ordering_contact` prefs in `ContactStorageService`
