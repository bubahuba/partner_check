---
name: dev-ios
description: Run Partner Check on iOS simulator or device (debug). Invoke explicitly when the user wants to dev-run on iOS.
disable-model-invocation: true
---

# Dev — iOS

Run from project root (`partner_check/`):

```bash
./scripts/dev_ios.sh
```

Pass extra Flutter args after the script:

```bash
./scripts/dev_ios.sh -d "iPhone 16"
```

## Prerequisites

- macOS with Xcode
- CocoaPods (`cd ios && pod install` if pods are stale; or run `./fix_ios_build.sh`)
- `flutter doctor` shows Xcode OK

## Notes

- Runs `flutter pub get` then `flutter run -d ios`
- Bundle ID: `cz.shadowHub.partnerCheck`
- Team: automatic signing via Xcode (`DEVELOPMENT_TEAM` in project)
