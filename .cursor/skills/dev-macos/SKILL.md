---
name: dev-macos
description: Run Partner Check on macOS desktop (debug). Invoke explicitly when the user wants to dev-run on macOS.
disable-model-invocation: true
---

# Dev — macOS

Run from project root (`partner_check/`):

```bash
./scripts/dev_macos.sh
```

## Prerequisites

- macOS with Xcode command-line tools
- `flutter doctor` shows macOS desktop OK

## Notes

- Runs `flutter pub get` then `flutter run -d macos`
- Bundle ID: `cz.shadowHub.partnerCheck`
