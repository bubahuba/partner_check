---
name: build-android-prod
description: Build signed Android App Bundle (release) for Play Store. Invoke explicitly for production Android builds.
disable-model-invocation: true
---

# Production build — Android (signed AAB)

Run from project root (`partner_check/`):

```bash
./scripts/build_android_prod.sh
```

## Signing setup (one-time)

1. Create or locate your upload keystore (`.jks`)
2. Copy `android/key.properties.example` → `android/key.properties` (gitignored)
3. Fill in `storeFile`, `storePassword`, `keyAlias`, `keyPassword`

Example `android/key.properties`:

```properties
storeFile=../upload-keystore.jks
storePassword=...
keyPassword=...
keyAlias=upload
```

Release builds use the `release` signing config when `key.properties` exists; otherwise Gradle falls back to debug keys.

## Output

`build/app/outputs/bundle/release/app-release.aab`

## Optional

APK instead of bundle:

```bash
flutter build apk --release
```
