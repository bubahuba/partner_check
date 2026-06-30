---
name: dev-android
description: Run Partner Check on Android (debug). Invoke explicitly when the user wants to dev-run on Android.
disable-model-invocation: true
---

# Dev — Android

Run from project root (`partner_check/`):

```bash
./scripts/dev_android.sh
```

Pass extra Flutter args after the script (e.g. a device id):

```bash
./scripts/dev_android.sh -d emulator-5554
```

## Prerequisites

- Android SDK + emulator or USB device
- `flutter doctor` shows Android toolchain OK

## Notes

- Runs `flutter pub get` then `flutter run -d android`
- Use `flutter devices` to list available targets
