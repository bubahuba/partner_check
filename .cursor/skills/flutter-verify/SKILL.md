---
name: flutter-verify
description: Runs Flutter analyze, format, and tests for Partner Check after code changes. Use when verifying Dart changes, fixing lints, or before committing Flutter work.
---

# Flutter Verify

Run after editing `lib/` or `test/` files.

## Commands

From project root (`partner_check/`):

```bash
# 1. Format changed Dart files (or all lib/)
dart format lib/

# 2. Static analysis — must pass with no errors
flutter analyze

# 3. Tests (widget test is currently stale/broken — expect failure until fixed)
flutter test
```

## Common fixes

| Lint | Fix |
|------|-----|
| `use_build_context_synchronously` | Add `if (!mounted) return;` immediately before `context` use after `await` |
| Deprecated `withOpacity` | Use `Color.withValues(alpha: x)` |
| Missing import | Prefer relative imports for `lib/` internals |

## Pre-commit checklist

- [ ] `flutter analyze` — no errors
- [ ] New strings follow `add-localization` skill
- [ ] New prefs added via `ContactStorageService` methods
- [ ] Pro limits use `pro_gate.dart` helpers
- [ ] iOS/Android self-contact behavior preserved if touching contacts flow

## Note on tests

`test/widget_test.dart` still references a counter app — do not assume green `flutter test` until updated. Prefer adding unit tests for `lib/utils/` when changing match/color logic.
