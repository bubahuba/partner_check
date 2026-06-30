---
name: partner-check-builds
description: Index of Partner Check dev-run and signed production build commands for Android, iOS, web, and macOS. Use when the user asks how to run or build the app on a platform.
---

# Partner Check — Dev & production builds

All commands run from project root (`partner_check/`). Prefer the shell scripts; skills with `disable-model-invocation` are also available as explicit slash commands.

## Dev (debug)

| Platform | Script | Slash skill |
|----------|--------|-------------|
| Android | `./scripts/dev_android.sh` | `/dev-android` |
| iOS | `./scripts/dev_ios.sh` | `/dev-ios` |
| Web (Chrome) | `./scripts/dev_web.sh` | `/dev-web` |
| macOS | `./scripts/dev_macos.sh` | `/dev-macos` |

## Production (signed / release)

| Platform | Script | Slash skill | Output |
|----------|--------|-------------|--------|
| Android AAB | `./scripts/build_android_prod.sh` | `/build-android-prod` | `build/app/outputs/bundle/release/app-release.aab` |
| iOS IPA | `./scripts/build_ios_prod.sh` | `/build-ios-prod` | `build/ios/ipa/*.ipa` |
| Web | `./scripts/build_web_prod.sh` | `/build-web-prod` | `build/web/` (`/app/` base href) |
| macOS | `./scripts/build_macos_prod.sh` | `/build-macos-prod` | `build/macos/Build/Products/Release/partner_check.app` |

## Agent workflow

1. Confirm target platform with the user if unclear
2. Run `flutter doctor` if toolchain errors appear
3. Execute the matching script via Shell tool (long-running dev commands may use background)
4. For Android prod, verify `android/key.properties` exists before building

## Related

- `./scripts/` — executable wrappers
- `android/key.properties.example` — Android release signing template
- `./build_web.sh` — web prod build (called by `build_web_prod.sh`)
- `./fix_ios_build.sh` — clean iOS pods when iOS build fails
- `flutter-verify` skill — analyze/format before release builds
